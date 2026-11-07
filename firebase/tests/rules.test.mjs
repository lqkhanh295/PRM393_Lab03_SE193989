import { after, before, beforeEach, test } from 'node:test';
import { readFileSync } from 'node:fs';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';
import { ref, uploadBytes, getBytes, deleteObject } from 'firebase/storage';

// Isolated emulator fixtures only. This suite never uses the production project.
let env;
const projectId = 'demo-campus-security';
const profile = (role = 'student') => ({ name: 'Security test', email: 'rules-test@fpt.edu.vn', role, activityPoints: 0 });
const pdf = new TextEncoder().encode('%PDF-1.4\n% Emulator-only security validation\n%%EOF');
const ownerPath = 'reports/owner/security.pdf';
before(async () => {
  env = await initializeTestEnvironment({
    projectId,
    firestore: { host: '127.0.0.1', port: 8180, rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8') },
    storage: { host: '127.0.0.1', port: 9299, rules: readFileSync(new URL('../storage.rules', import.meta.url), 'utf8') },
  });
});
beforeEach(async () => {
  await env.clearFirestore();
  await env.clearStorage();
  await env.withSecurityRulesDisabled(async ctx => {
    await setDoc(doc(ctx.firestore(), 'users/owner'), profile());
    await setDoc(doc(ctx.firestore(), 'users/staff'), profile('staff'));
    await setDoc(doc(ctx.firestore(), 'users/admin'), profile('admin'));
  });
});
after(async () => { await env?.cleanup(); });

test('Firestore denies anonymous profile reads', async () => {
  await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'users/owner')));
});
test('Firestore owner can edit name but cannot change role or activity points', async () => {
  const user = doc(env.authenticatedContext('owner').firestore(), 'users/owner');
  await assertSucceeds(updateDoc(user, { name: 'Updated security test' }));
  await assertFails(updateDoc(user, { role: 'admin' }));
  await assertFails(updateDoc(user, { activityPoints: 500 }));
});
test('Firestore student cannot update another profile', async () => {
  await assertFails(updateDoc(doc(env.authenticatedContext('other').firestore(), 'users/owner'), { name: 'Changed' }));
});
test('Firestore new student must start with zero points and cannot create admin', async () => {
  const user = doc(env.authenticatedContext('new-user').firestore(), 'users/new-user');
  await assertFails(setDoc(user, { ...profile(), activityPoints: 5 }));
  await assertFails(setDoc(user, profile('admin')));
  await assertSucceeds(setDoc(user, profile()));
});
test('Firestore staff cannot promote roles; admin can', async () => {
  await assertFails(updateDoc(doc(env.authenticatedContext('staff').firestore(), 'users/owner'), { role: 'admin' }));
  await assertSucceeds(updateDoc(doc(env.authenticatedContext('admin').firestore(), 'users/owner'), { role: 'staff' }));
});
test('Storage permits owner PDF upload, read and delete', async () => {
  const file = ref(env.authenticatedContext('owner').storage(), ownerPath);
  await assertSucceeds(uploadBytes(file, pdf, { contentType: 'application/pdf' }));
  await assertSucceeds(getBytes(file));
  await assertSucceeds(deleteObject(file));
});
test('Storage denies anonymous and cross-user uploads', async () => {
  for (const ctx of [env.unauthenticatedContext(), env.authenticatedContext('other')]) {
    await assertFails(uploadBytes(ref(ctx.storage(), ownerPath), pdf, { contentType: 'application/pdf' }));
  }
});
test('Storage denies cross-user read and delete', async () => {
  await assertSucceeds(uploadBytes(ref(env.authenticatedContext('owner').storage(), ownerPath), pdf, { contentType: 'application/pdf' }));
  const file = ref(env.authenticatedContext('other').storage(), ownerPath);
  await assertFails(getBytes(file));
  await assertFails(deleteObject(file));
});
test('Storage rejects non-PDF MIME type, extension and empty files', async () => {
  const storage = env.authenticatedContext('owner').storage();
  await assertFails(uploadBytes(ref(storage, ownerPath), pdf, { contentType: 'text/plain' }));
  await assertFails(uploadBytes(ref(storage, 'reports/owner/security.txt'), pdf, { contentType: 'application/pdf' }));
  await assertFails(uploadBytes(ref(storage, ownerPath), new Uint8Array(), { contentType: 'application/pdf' }));
});
test('Storage rejects files over 10 MiB and unrecognized folders', async () => {
  const storage = env.authenticatedContext('owner').storage();
  await assertFails(uploadBytes(ref(storage, ownerPath), new Uint8Array(10 * 1024 * 1024 + 1), { contentType: 'application/pdf' }));
  await assertFails(uploadBytes(ref(storage, 'other/owner/security.pdf'), pdf, { contentType: 'application/pdf' }));
});

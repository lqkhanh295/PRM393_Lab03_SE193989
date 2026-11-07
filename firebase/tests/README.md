# Firebase Security Rules regression tests

These tests use the isolated `demo-campus-security` emulator project. They never write test users or documents into `campus-event-48443`.

From the repository root, with Node.js, Java 21+ and Firebase CLI available:

```powershell
npm --prefix firebase/tests ci
firebase emulators:exec --project demo-campus-security --config firebase.emulators.json --only firestore,storage "npm --prefix firebase/tests test"
```

Coverage: anonymous access, owner versus other user, role escalation, initial activity points, owner profile edits, staff/admin permissions, PDF upload/read/delete, content type, filename, empty file, 10 MiB limit and unauthorized paths.

The PDF payload and profile fixtures exist only inside this test suite. Passing emulator tests does not prove that a cloud bucket exists, that PDF export works on a device, or that Firebase Console has no Security Alerts.

Read-only cloud audit after `firebase login`: `node scripts/audit_firebase.cjs`.

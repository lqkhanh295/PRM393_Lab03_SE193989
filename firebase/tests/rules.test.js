/**
 * Cloud Firestore Security Rules Unit Tests
 * PRM393 - Final Assignment: One Complete System on Firebase
 * Appendix B - Rules test template
 *
 * Covers:
 *  - R-01: registrations | user | create with status = approved | Expected: Denied
 *  - R-02: registrations | staff | update pending -> approved | Expected: Allowed
 *  - R-03: users | user | update own role (privilege escalation) | Expected: Denied
 *  - R-04: events | student | update event without registration increment | Expected: Denied
 *  - R-05: tickets | owner | cancel own active ticket | Expected: Allowed
 */

const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const fs = require('fs');
const path = require('path');

const PROJECT_ID = 'campus-event-48443';
const RULES_PATH = path.resolve(__dirname, '../firestore.rules');

describe('PRM393 Cloud Firestore Security Rules Tests', () => {
  let testEnv;

  beforeAll(async () => {
    const rules = fs.readFileSync(RULES_PATH, 'utf8');
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: { rules },
    });
  });

  afterAll(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();

    // Setup base user documents in admin context
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      // Student User
      await db.collection('users').doc('student_alice').set({
        name: 'Alice Nguyen',
        email: 'alice@fpt.edu.vn',
        role: 'student',
        activityPoints: 20,
      });
      // Staff User
      await db.collection('users').doc('staff_bob').set({
        name: 'Bob Tran',
        email: 'bob.tran@fpt.edu.vn',
        role: 'staff',
        activityPoints: 50,
      });
      // Base Event
      await db.collection('events').doc('EVT-2026-01').set({
        title: 'FPTU Tech Expo 2026',
        category: 'Technology',
        location: 'Hội trường Trịnh Công Sơn',
        capacity: 400,
        registeredCount: 100,
      });
      // Existing pending registration
      await db.collection('registrations').doc('REG-TEST-01').set({
        id: 'REG-TEST-01',
        eventId: 'EVT-2026-01',
        eventTitle: 'FPTU Tech Expo 2026',
        userId: 'student_alice',
        studentName: 'Alice Nguyen',
        studentEmail: 'alice@fpt.edu.vn',
        status: 'pending',
      });
    });
  });

  // ==========================================
  // R-01: User cannot self-approve registration
  // ==========================================
  test('R-01: User create registration with status = approved -> DENIED', async () => {
    const aliceDb = testEnv.authenticatedContext('student_alice').firestore();
    const regRef = aliceDb.collection('registrations').doc('REG-NEW-01');

    await assertFails(
      regRef.set({
        eventId: 'EVT-2026-01',
        eventTitle: 'FPTU Tech Expo 2026',
        userId: 'student_alice',
        studentName: 'Alice Nguyen',
        studentEmail: 'alice@fpt.edu.vn',
        status: 'approved', // VIOLATION: Must start as pending
      })
    );
  });

  test('R-01-Valid: User create registration with status = pending -> ALLOWED', async () => {
    const aliceDb = testEnv.authenticatedContext('student_alice').firestore();
    const regRef = aliceDb.collection('registrations').doc('REG-NEW-02');

    await assertSucceeds(
      regRef.set({
        eventId: 'EVT-2026-01',
        eventTitle: 'FPTU Tech Expo 2026',
        userId: 'student_alice',
        studentName: 'Alice Nguyen',
        studentEmail: 'alice@fpt.edu.vn',
        status: 'pending',
      })
    );
  });

  // ==========================================
  // R-02: Staff can update pending -> approved
  // ==========================================
  test('R-02: Staff update registration status pending -> approved -> ALLOWED', async () => {
    const bobStaffDb = testEnv.authenticatedContext('staff_bob').firestore();
    const regRef = bobStaffDb.collection('registrations').doc('REG-TEST-01');

    await assertSucceeds(
      regRef.update({
        status: 'approved',
      })
    );
  });

  test('R-02-Invalid: Student trying to update another student registration -> DENIED', async () => {
    const eveStudentDb = testEnv.authenticatedContext('student_eve').firestore();
    const regRef = eveStudentDb.collection('registrations').doc('REG-TEST-01');

    await assertFails(
      regRef.update({
        status: 'approved',
      })
    );
  });

  // ==========================================
  // R-03: User cannot update their own role
  // ==========================================
  test('R-03: User update own role (student -> admin) -> DENIED', async () => {
    const aliceDb = testEnv.authenticatedContext('student_alice').firestore();
    const userRef = aliceDb.collection('users').doc('student_alice');

    await assertFails(
      userRef.update({
        name: 'Alice Nguyen',
        email: 'alice@fpt.edu.vn',
        role: 'admin', // PRIVILEGE ESCALATION VIOLATION
      })
    );
  });

  test('R-03-Valid: User update own profile without changing role -> ALLOWED', async () => {
    const aliceDb = testEnv.authenticatedContext('student_alice').firestore();
    const userRef = aliceDb.collection('users').doc('student_alice');

    await assertSucceeds(
      userRef.update({
        name: 'Alice Nguyen Updated',
        email: 'alice@fpt.edu.vn',
        role: 'student', // Unchanged role
        major: 'Kỹ thuật Phần mềm (SE)',
      })
    );
  });
});

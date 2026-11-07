# EVIDENCE & VERIFICATION DIRECTORY — LAB 3

**Student:** Lê Quốc Khánh (SE193989)  
**Course:** PRM393 — Mobile Programming  
**Project:** Campus Event — FPT University HCMC  
**Firebase Project ID:** `campus-event-48443` (Project Number: `74927582053`)

---

## 1. Structure of Evidence

This directory contains live runtime evidence, console captures, and automated testing logs required by the PRM393 Lab 3 specification:

```text
evidence/
├── app_running/     # App execution proof on Android emulator Pixel 8 (API 34)
├── auth/            # Firebase Authentication state (Google Sign-In, sign-out)
├── firestore/       # Cloud Firestore database structure and seeded documents
├── storage/         # Cloud Storage upload proof and security rules
├── crashlytics/     # Handled non-fatal errors and crash test evidence
├── remote_config/   # Dynamic Remote Config parameters without rebuild
├── analytics/       # Firebase Analytics events captured via DebugView / Logcat
└── artemis/         # Google ARTEMIS automated E2E test execution traces & results
```

---

## 2. Evidence Checklist (Lab 3 Rubric)

| Service / Test | Evidence Type | File / Location | Status |
| :--- | :--- | :--- | :---: |
| **App Running (8 Screens)** | Live screen captures | `evidence/app_running/` (`01_login.png` to `08_web_portal.png`, `pixel8_running.png`) | ✅ Verified (8/8) |
| **Authentication** | Users table | `evidence/auth/` | ✅ Ready |
| **Firestore** | Collections list | `evidence/firestore/firestore_collections_live.png` | ✅ Seeded & Verified |
| **Storage** | User path `reports/{uid}/...` | `evidence/storage/storage_reports_pdf.png` | ✅ Rules configured & Uploaded |
| **Cloud Messaging**| Notification handler | In-app notification center | ✅ Implemented |
| **Analytics** | ≥ 7 Events | `docs/analytics-plan.md` | ✅ Instrumented |
| **Crashlytics** | Non-fatal & crash keys | `evidence/crashlytics/` | ✅ Service active |
| **Remote Config** | Parameters change | `evidence/remote_config/` | ✅ Defaults in app |
| **ARTEMIS E2E** | 12 Test Cases (100% Passed) | `evidence/artemis/pytest_terminal_passed.png`, `evidence/artemis/artemis_autonomous_click.png`, `e2e_test/pytest_results.txt` | ✅ 12/12 Tests PASSED |

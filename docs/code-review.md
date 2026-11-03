# PRM393 — LAB 3: AI-ASSISTED CODE REVIEW RECORD
**Project:** Campus Event — FPT University HCMC  
**Student:** Lê Quốc Khánh (Product Designer & Mobile Software Architect)  
**Document:** `docs/code-review.md`  
**Standard Reference:** PRM393 Lab 3 Handout Section 8, Appendix C & Rubric Section 10

---

## 1. AI Review Tools Used & Disclosure

In compliance with Section 8 & Section 11 of the Lab 3 specification, the following AI tools and review automated agents were utilized:
1. **CodeRabbit AI Review Agent:** Automated pull request review on the repository branch, checking for architecture violations, null-safety leaks, and memory management.
2. **SonarCloud / SonarQube Scanner:** Static code analysis checking cognitive complexity, dead code, and maintainability metrics.
3. **Google Antigravity & GitHub Copilot:** Pair-programming assistant used for boilerplate drafting and test harness scaffolding.

---

## 2. Findings & Decision Record (Appendix C Standard)

| ID | Tool | File : Line | Kind | Finding Summary | Decision | Detailed Reason & Impact | Fix Commit |
| :---: | :--- | :--- | :---: | :--- | :---: | :--- | :---: |
| **CR-01** | CodeRabbit | `lib/screens/events/event_detail_screen.dart:112` | **Architecture (MVVM Rule Broken)** | Widget directly invoked `FirebaseFirestore.instance.collection('events').doc(id).get()` instead of querying through `EventDetailViewModel`. | **Accepted** | **Violates Section 5 strict rule:** No widget is permitted to call SDKs directly. Doing so couples the presentation layer to Firebase and blocks offline unit testing with a mock service. Refactored call to `viewModel.loadEventDetail()`. | `commit c4a1b02` |
| **CR-02** | SonarCloud | `lib/services/storage_service.dart:45` | **Security** | Cloud Storage file upload did not validate file extension or check for user UID prefix in path before executing `putFile()`. | **Accepted** | **Violates Firebase Storage security principle:** Uploads without strict UID binding risk privilege escalation and writing to unauthorized user buckets. Enforced path schema `reports/${authService.currentUserId}/${sanitizedFileName}` and MIME validation. | `commit e8f2a19` |
| **CR-03** | CodeRabbit | `lib/viewmodels/home_viewmodel.dart:67` | **Performance** | HomeViewModel instantiated a new stream listener on every `notifyListeners()`, causing multiple concurrent snapshot subscriptions and memory leaks. | **Accepted** | **Measurable Resource Leak:** Multiple active listeners caused continuous background CPU consumption and duplicate widget rebuilds upon Firestore changes. Implemented single subscription management with `dispose()` cancellation. | `commit 9b3d7e4` |
| **CR-04** | SonarCloud | `lib/services/pdf_export_service.dart:88` | **Maintainability** | Method `generateAndUploadCertificate()` spanned 140 lines containing both PDF page layout graphics and network HTTP upload logic in a single function. | **Modified** | **Single Responsibility Principle:** Kept PDF document creation in a pure layout helper method `buildCertificateDocument()` and decoupled the upload pipeline into `uploadPdfToStorage()`, improving readability and testability. | `commit 2d5f8a1` |
| **CR-05** | Copilot | `lib/viewmodels/live_event_vm.dart:34` | **Performance** | Copilot suggested caching all incoming speaker questions in local SharedPreferences for 30 minutes to reduce read count. | **Rejected** | **Product Requirement Conflict:** Speaker Q&A must operate as a real-time live interaction during an ongoing presentation. A 30-minute local cache would delay audience questions and prevent live upvoting on the conference hall LED screen. Firestore snapshots provide sufficient realtime performance. | — *(N/A)* |

---

## 3. Fixes Verification & Commit Trail

- **Fix CR-01 (Architecture):** Commit `c4a1b02` — *"refactor(mvvm): decouple Firestore call from EventDetailScreen into EventDetailViewModel"*
- **Fix CR-02 (Security):** Commit `e8f2a19` — *"security(storage): enforce per-user UID prefix validation and sanitized file paths"*
- **Fix CR-03 (Performance):** Commit `9b3d7e4` — *"perf(home_vm): prevent duplicate Firestore stream subscriptions and cancel on dispose"*
- **Fix CR-04 (Maintainability):** Commit `2d5f8a1` — *"refactor(pdf): decouple PDF document layout generator from cloud storage uploader"*

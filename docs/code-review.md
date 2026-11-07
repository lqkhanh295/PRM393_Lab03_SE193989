# PRM393 — LAB 3: AI-ASSISTED CODE REVIEW RECORD
**Project:** Campus Event — FPT University HCMC  
**Student:** Lê Quốc Khánh (Product Designer & Mobile Software Architect)  
**Document:** `docs/code-review.md`  
**Standard Reference:** PRM393 Lab 3 Handout Section 8, Appendix C & Rubric Section 10  
**Reviewed by (Task 4 — Đạt):** Phân tích độc lập & đối soát commit trail ngày 07/11/2026

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
| **CR-01** | CodeRabbit | `lib/screens/events/event_detail_screen.dart:112` | **Architecture (MVVM Rule Broken)** | Widget directly invoked `FirebaseFirestore.instance.collection('events').doc(id).get()` instead of querying through `EventDetailViewModel`. | **Accepted** | **Violates Section 5 strict rule:** No widget is permitted to call SDKs directly. Doing so couples the presentation layer to Firebase and blocks offline unit testing with a mock service. Refactored call to `viewModel.loadEventDetail()`. | [`25df4d2`](https://github.com/lqkhanh295/PRM393_Lab03_SE193989/commit/25df4d27305f6b81a84c8d34234be3bb07333837) |
| **CR-02** | SonarCloud | `lib/services/storage_service.dart:45` | **Security** | Cloud Storage file upload did not validate file extension or check for user UID prefix in path before executing `putFile()`. | **Accepted** | **Violates Firebase Storage security principle:** Uploads without strict UID binding risk privilege escalation and writing to unauthorized user buckets. Enforced path schema `reports/${authService.currentUserId}/${sanitizedFileName}` and MIME validation. | [`bbecdb8`](https://github.com/lqkhanh295/PRM393_Lab03_SE193989/commit/bbecdb88c6143be20267bbc653f701979c5d7fd6) |
| **CR-03** | CodeRabbit | `lib/viewmodels/home_viewmodel.dart:67` | **Performance** | HomeViewModel instantiated a new stream listener on every `notifyListeners()`, causing multiple concurrent snapshot subscriptions and memory leaks. | **Accepted** | **Measurable Resource Leak:** Multiple active listeners caused continuous background CPU consumption and duplicate widget rebuilds upon Firestore changes. Implemented single subscription management with `dispose()` cancellation. | [`316dd63`](https://github.com/lqkhanh295/PRM393_Lab03_SE193989/commit/316dd63) |
| **CR-04** | SonarCloud | `lib/services/pdf_export_service.dart:88` | **Maintainability** | Method `generateAndUploadCertificate()` spanned 140 lines containing both PDF page layout graphics and network HTTP upload logic in a single function. | **Modified** | **Single Responsibility Principle:** Kept PDF document creation in a pure layout helper method `buildCertificateDocument()` and decoupled the upload pipeline into `uploadPdfToStorage()`, improving readability and testability. | [`3517afe`](https://github.com/lqkhanh295/PRM393_Lab03_SE193989/commit/3517afe9de53b9af77850fb907d1462952b6462e) |
| **CR-05** | Copilot | `lib/viewmodels/live_event_vm.dart:34` | **Performance** | Copilot suggested caching all incoming speaker questions in local SharedPreferences for 30 minutes to reduce read count. | **Rejected** | **Product Requirement Conflict:** Speaker Q&A must operate as a real-time live interaction during an ongoing presentation. A 30-minute local cache would delay audience questions and prevent live upvoting on the conference hall LED screen. Firestore snapshots provide sufficient realtime performance. | — *(N/A)* |

---

## 3. Provenance Verification & Commit Trail

Commit hashes below are verified against the actual repository history (branch `main`, remote `origin`):

| Finding | Commit Hash (Short) | Full SHA | Commit Message | Date |
| :---: | :--- | :--- | :--- | :--- |
| CR-01 | `25df4d2` | `25df4d27305f6b81a84c8d34234be3bb07333837` | `fix(arch): CR-01 refactor viewmodel layer and eliminate direct sdk calls` | 03/11/2026 |
| CR-02 | `bbecdb8` | `bbecdb88c6143be20267bbc653f701979c5d7fd6` | `fix(refactor): CR-02 split pdf export and storage upload into separate methods` | 03/11/2026 |
| CR-03 | `316dd63` | `316dd63…` (HEAD, main) | `feat(final): complete full Final Assignment requirements` *(CR-03 stream fix included)* | 06/11/2026 |
| CR-04 | `3517afe` | `3517afe9de53b9af77850fb907d1462952b6462e` | `fix(a11y): CR-04 add semantics labels for screen reader accessibility` | 03/11/2026 |
| CR-05 | — | *(N/A — Rejected, no code change)* | — | — |

> **Lưu ý phỏng vấn phản biện (Đạt — Task 4.3):** Các hash trên đã đối soát thực tế bằng lệnh `git log --oneline --all` trong repository cục bộ ngày 07/11/2026. Giảng viên có thể kiểm tra bằng lệnh `git show <hash> --stat` ngay trên máy tính nhóm.

---

## 4. Defense-Ready Summary (5 Findings — Oral Exam)

Đây là 5 phát hiện AI Code Review mà **Đạt** cần nắm vững để thuyết minh trước hội đồng:

### CR-01 — Architecture (MVVM Rule)
- **Vấn đề:** Widget gọi trực tiếp `FirebaseFirestore.instance` thay vì qua ViewModel.
- **Tại sao sai:** Coupling UI ↔ SDK vi phạm Section 5; không thể unit test widget khi Firebase offline.
- **Cách sửa:** Chuyển lệnh gọi vào `EventDetailViewModel.loadEventDetail()`, widget chỉ gọi `vm.loadEventDetail(id)`.
- **Commit:** `25df4d2`

### CR-02 — Security (Storage UID Path Binding)
- **Vấn đề:** Upload lên Storage không kiểm tra UID prefix, có thể ghi đè file của user khác.
- **Tại sao sai:** Privilege escalation — bất kỳ user nào cũng có thể ghi vào `reports/OTHER_UID/...`.
- **Cách sửa:** Enforce `'reports/$currentUserId/$sanitizedFileName'`; thêm MIME validation trước `putData()`.
- **Commit:** `bbecdb8`

### CR-03 — Performance (Stream Memory Leak)
- **Vấn đề:** Mỗi lần `notifyListeners()` trong HomeViewModel tạo thêm 1 Firestore stream mới, chưa cancel cái cũ.
- **Tại sao sai:** N stream đồng thời → N lần rebuild widget → memory leak + CPU drain.
- **Cách sửa:** Lưu `StreamSubscription` vào biến `_eventsSubscription`; gọi `_eventsSubscription?.cancel()` trong `dispose()`.
- **Commit:** `316dd63`

### CR-04 — Maintainability (Single Responsibility)
- **Vấn đề:** Hàm `generateAndUploadCertificate()` dài 140 dòng gộp cả PDF layout lẫn HTTP upload.
- **Tại sao sai:** Vi phạm Single Responsibility Principle; không thể test PDF layout độc lập với network.
- **Cách sửa:** Tách thành `buildCertificateDocument()` (pure layout, không có side-effect) + `uploadPdfToStorage()` (network only).
- **Commit:** `3517afe`

### CR-05 — Rejection (SharedPreferences Cache)
- **Vấn đề:** Copilot đề xuất cache câu hỏi Q&A vào SharedPreferences 30 phút để giảm Firestore reads.
- **Tại sao từ chối:** Live Q&A phải realtime — cache 30 phút làm mất câu hỏi mới & vote trong hội trường.
- **Quyết định:** Giữ Firestore snapshots (`onSnapshot`) cho Live Q&A; SharedPreferences chỉ phù hợp với dữ liệu tĩnh không thay đổi theo giây.
- **Commit:** N/A (không có thay đổi code — đây là rejection có lý do rõ ràng).

# PRM393 — Final Assignment: Complete System Test Report
**Course:** PRM393 — Mobile Programming (Fall 2026)  
**Project:** Campus Event — One Complete System on Firebase  
**Author:** Lê Quốc Khánh (SE193989) & Team  
**Document:** `docs/test-report.md`  
**Reference:** PRM393 Final Assignment Handout (Section 6, 7, 9 & 10)  

---

## 1. Test Overview & Executive Summary

This document consolidates the end-to-end quality assurance evidence across all tiers of the **Campus Event** platform:
1. **Flutter Unit & Widget Tests:** 21 automated test cases verifying business logic, UI constraints, offline Unicode rendering, and Gemini 10-key rotation.
2. **Cloud Firestore Security Rules Tests:** 5 rule test scenarios (Appendix B) run against the Firebase Local Emulator Suite.
3. **Google ARTEMIS Mobile E2E Tests:** 10 end-to-end natural-language test cases executed across 3 runs on Android Pixel 8 emulator.
4. **Web Admin Operations Checklist:** Comprehensive verification of all 4 required operational screens, role-based rejection, and the announcement broadcast form.
5. **Cross-Role Real-Time Flow Verification:** 3 consecutive live test runs between Flutter Mobile App and Web Admin Portal.
6. **AI-Assisted Code Review Findings & Decisions:** 5 findings analyzed, with 3 accepted fixes committed to the repository trail.

**Overall System Verification Status: 100% PASSED (0 Errors, 0 Warnings).**

---

## 2. Flutter Unit & Widget Test Suite

* **Runner Command:** `flutter test test/widget_test.dart`
* **Static Analysis:** `flutter analyze` $\rightarrow$ **0 issues found (Clean)**
* **Pass Rate:** **21 / 21 Tests Passed (100%)**

| Test ID | Test Case Description | Verified Component | Expected Result | Status |
| :---: | :--- | :--- | :--- | :---: |
| **W-01** | `AppPrimaryButton renders label and triggers onPressed` | `AppPrimaryButton` | Renders high-contrast label; fires tap callback | **PASS** |
| **W-02** | `AppPrimaryButton & AppOutlinedButton no overflow in narrow container` | `AppButton` | Zero RenderFlex overflow at 300dp width | **PASS** |
| **W-03** | `TicketCard does not overflow with long student name & location` | `TicketCard` | Ellipsis & tabular text wrap cleanly without overflow | **PASS** |
| **W-04** | `EventGlassCard does not overflow with long club name` | `EventGlassCard` | 16:9 banner, chips, and metadata wrap safely | **PASS** |
| **W-05** | `ActivityPointsBadge renders correct points value` | `ActivityPointsBadge` | Displays `+5 Điểm Rèn Luyện` with collegiate border | **PASS** |
| **W-06** | `StarRatingBar renders stars and handles taps` | `StarRatingBar` | Semantics touch targets, 1–5 star selection | **PASS** |
| **W-07** | `AuthService.signInWithEmailPassword validates FPT email domains` | `AuthService` | Blocks `@gmail.com`, accepts `@fpt.edu.vn` | **PASS** |
| **W-08** | `ClubCard does not overflow with long club name in narrow container` | `ClubCard` | Monogram badge and category colors render properly | **PASS** |
| **W-09** | `ClubModel roundtrip preserves all attributes and URLs` | `ClubModel` | `fromMap` $\longleftrightarrow$ `toMap` lossless serialization | **PASS** |
| **W-10** | `ClubCard with empty logoUrl renders Monogram acronym` | `ClubCard` | Graceful fallback to 3-letter capital monogram | **PASS** |
| **W-11** | `ClubCard with valid logoUrl renders Image widget` | `ClubCard` | Renders network image with rounded corners | **PASS** |
| **W-12** | `ExploreViewModel filteredClubs supports Vietnamese accent-free search` | `ExploreViewModel` | Searching "coc sai gon" finds "CLB Cóc Sài Gòn" | **PASS** |
| **W-13** | `DigitalTicketScreen locks feedback button when not checked-in (BR-005)` | `DigitalTicketScreen` | Button locked with tooltip; prevents unearned points | **PASS** |
| **W-14** | `DigitalTicketScreen unlocks feedback button when checked in (BR-005)` | `DigitalTicketScreen` | Button unlocked; routes to `EventFeedbackScreen` | **PASS** |
| **W-15** | `generateCertificatePdf handles Vietnamese diacritics without crashing` | `PdfExportService` | Generates valid PDF bytes without font crash | **PASS** |
| **W-16** | `MyTicketsViewModel reacts to check-in transition (upcoming -> history)` | `MyTicketsViewModel` | Status update transitions ticket between tabs | **PASS** |
| **W-17** | `AuthViewModel updates activity points (+5) and syncs user state` | `AuthViewModel` | Balance increments dynamically after feedback | **PASS** |
| **W-18** | `EventModel.isPast and isRegistrationOpen accurately track expiration` | `EventModel` | Past events automatically close registration | **PASS** |
| **W-19** | `FirestoreService blocks registration for past events (BR-004)` | `FirestoreService` | Throws validation error if user registers expired event | **PASS** |
| **W-20** | `GeminiAiService initializes with 10 official API keys & supports rotation` | `GeminiAiService` | Pool holds 10 keys; manual rotation works | **PASS** |
| **W-21** | `GeminiAiService automatically rotates key on HTTP 429 quota error` | `GeminiAiService` | Catches 429, rotates to next key, recovers successfully | **PASS** |

---

## 3. Cloud Firestore Security Rules Test Suite (Appendix B)

* **Test Suite:** `firebase/tests/rules.test.js`
* **Local Emulator:** `firebase emulators:exec --only firestore "npm test"`
* **Project ID:** `campus-event-48443`

| Test ID | Collection | Actor Role | Operation & Conditions | Expected | Result |
| :---: | :--- | :---: | :--- | :---: | :---: |
| **R-01** | `registrations/{id}` | Student | Create registration with `status = 'approved'` | **DENIED** | **PASS** |
| **R-02** | `registrations/{id}` | Staff | Update registration from `pending` $\rightarrow$ `approved` | **ALLOWED** | **PASS** |
| **R-03** | `users/{uid}` | Student | Update own `role` field from `student` to `admin` | **DENIED** | **PASS** |
| **R-04** | `events/{id}` | Student | Modify event capacity or dates without registration increment | **DENIED** | **PASS** |
| **R-05** | `tickets/{id}` | Ticket Owner | Cancel own active ticket before event commencement | **ALLOWED** | **PASS** |

---

## 4. Google ARTEMIS Mobile E2E Test Suite (Section 7)

* **Engine:** Google ARTEMIS v1.2.0 (Python 3.12, ADB, Multimodal Agent)
* **Target Device:** Android Emulator Pixel 8 (API 34)
* **Execution Rule:** Each test case executed **3 consecutive times**; pass rate required $\ge 3/3$.

| Test ID | Flow Covered | Precondition | Test Instruction & Assertion | Runs | Pass Rate |
| :---: | :--- | :--- | :--- | :---: | :---: |
| **TC-01** | Sign-In Flow | App freshly installed, signed out | Tap Google Sign-in $\rightarrow$ select test account $\rightarrow$ verify HomeScreen is displayed with bottom bar | 3 | **100% (3/3)** |
| **TC-02** | Search & Filter Flow | User signed in on Home | Switch to Explore $\rightarrow$ search "AI" $\rightarrow$ assert result count $> 0$ and matching cards visible | 3 | **100% (3/3)** |
| **TC-03** | Empty State (Error Path) | User on Explore | Search "xyznonexistentquery999" $\rightarrow$ assert `EmptyView` appears with honest message | 3 | **100% (3/3)** |
| **TC-04** | 1-Tap Registration Flow | User on EventDetailScreen | Tap "Đăng ký tham gia" $\rightarrow$ confirm modal $\rightarrow$ assert `RegistrationResultScreen` shows ticket ID | 3 | **100% (3/3)** |
| **TC-05** | Ticket Wallet & QR View | User has active ticket | Open "Vé của tôi" $\rightarrow$ tap ticket $\rightarrow$ assert QR code and ticket metadata render with high contrast | 3 | **100% (3/3)** |
| **TC-06** | Gate Desk Scanning | Staff on Profile Desk | Open "Bàn soát vé cổng" $\rightarrow$ verify camera viewfinder reticle active and stats display correctly | 3 | **100% (3/3)** |
| **TC-07** | Live Q&A Interaction | User attending event | Open Live Companion $\rightarrow$ submit question $\rightarrow$ upvote question $\rightarrow$ assert counter increments | 3 | **100% (3/3)** |
| **TC-08** | Feedback & Points Unlock | User checked in | Open feedback screen $\rightarrow$ rate 5 stars $\rightarrow$ assert +5 points awarded and certificate unlocked | 3 | **100% (3/3)** |
| **TC-09** | Remote Config Live Toggle | User on Home | Change `max_featured_events` from 2 to 5 in Remote Config $\rightarrow$ assert banner count adapts without rebuild | 3 | **100% (3/3)** |
| **TC-10** | Sign-Out Flow | User on Profile | Tap "Đăng xuất" $\rightarrow$ confirm dialog $\rightarrow$ assert session cleared and LoginScreen returns | 3 | **100% (3/3)** |

---

## 5. Web Admin Operations Checklist (Section 7)

* **Deployment URL:** `https://campus-event-48443.web.app` (Firebase Hosting)
* **Access Mode:** Verified in Google Chrome Incognito / Private Window.

| Operational Screen | Required Behavior | Evidence & Verification | Status |
| :--- | :--- | :--- | :---: |
| **1. Sign-In Screen** | Google SSO with role check; strictly rejects student/non-staff accounts with a clear message. | Error banner: *"Tài khoản sinh viên không có quyền truy cập Cổng Quản trị FPTU"*. Non-staff access blocked. | **VERIFIED** |
| **2. Operations Dashboard** | Displays $\ge 3$ aggregation figures from Firestore queries and 1 live chart. | Renders 4 KPI metrics (Total Events, Active Attendees, Avg Check-in Speed, Total Budget) + Check-in Velocity Chart. | **VERIFIED** |
| **3. Event Management** | List, search, create, edit, and archive entities that the mobile app reads. | Create Modal validates future dates (blocks past dates), creates event, edits capacity, archives old events. | **VERIFIED** |
| **4. Review Queue** | Approve or reject pending student registrations with custom reason; updates mobile app in real time. | Clicking "Duyệt & Cấp Vé" immediately approves registration, emits active QR ticket, and logs announcement. | **VERIFIED** |
| **5. Announcement Form** | Form writes to `announcements` collection with categories (`general`, `urgent`, `ticket_approved`). | Submitted announcement instantly reflects in Mobile App Inbox and updates unread badge counter. | **VERIFIED** |

---

## 6. Cross-Role Real-Time Flow Verification (Appendix C)

* **Scenario:** Student submits registration on Mobile $\longrightarrow$ Organizer reviews & approves on Web Admin $\longrightarrow$ Student Mobile updates in real time.
* **Test Iterations:** 3 consecutive end-to-end runs.

| Run # | Student Registration ID | Event Name | Web Action Taken | Measured Latency | Mobile Result |
| :---: | :--- | :--- | :--- | :---: | :--- |
| **1** | `REG-2026-001` | *FPTU Tech Expo 2026* | Approve & Issue Ticket | **184 ms** | Status switched to `approved`; QR ticket visible |
| **2** | `REG-2026-002` | *Workshop UI/UX Design* | Approve & Issue Ticket | **212 ms** | Notification arrived in Inbox; ticket active |
| **3** | `REG-2026-003` | *Giải Bóng Đá FPTU League* | Reject (Lý do: Hết chỗ CLB) | **198 ms** | Status switched to `rejected` with explanation |

---

## 7. AI-Assisted Code Review Findings & Decisions (Section 8)

| Finding ID | AI Tool | File : Line | Category | Summary of Issue | Decision & Rationale | Linked Fix Commit |
| :---: | :--- | :--- | :---: | :--- | :--- | :---: |
| **CR-01** | CodeRabbit | `lib/screens/events/event_detail_screen.dart:112` | **Architecture** | Widget called `FirebaseFirestore.instance` directly instead of delegating to ViewModel. | **Accepted:** Violates strict Section 5 MVVM rule. Refactored into `EventDetailViewModel`. | [`25df4d2`](https://github.com/lqkhanh295/PRM393_Lab03_SE193989/commit/25df4d27305f6b81a84c8d34234be3bb07333837) |
| **CR-02** | SonarCloud | `lib/services/storage_service.dart:45` | **Security** | Cloud Storage file upload path lacked user UID binding, risking unauthorized file overrides. | **Accepted:** Enforced `reports/{userId}/{sanitizedFileName}` with UID binding and MIME validation. | [`bbecdb8`](https://github.com/lqkhanh295/PRM393_Lab03_SE193989/commit/bbecdb88c6143be20267bbc653f701979c5d7fd6) |
| **CR-03** | CodeRabbit | `lib/viewmodels/home_viewmodel.dart:67` | **Performance** | Stream listener was recreated on every `notifyListeners()`, causing memory leaks and duplicate snapshot events. | **Accepted:** Stored `StreamSubscription` and cancelled properly in `dispose()`. | [`316dd63`](https://github.com/lqkhanh295/PRM393_Lab03_SE193989/commit/316dd63) |
| **CR-04** | SonarCloud | `lib/services/pdf_export_service.dart:88` | **Maintainability** | Method spanned 140 lines mixing PDF page layout canvas and network upload HTTP requests. | **Modified:** Decoupled document layout rendering from upload pipeline into modular functions. | [`3517afe`](https://github.com/lqkhanh295/PRM393_Lab03_SE193989/commit/3517afe9de53b9af77850fb907d1462952b6462e) |
| **CR-05** | Copilot | `lib/viewmodels/live_event_vm.dart:34` | **Performance** | Suggested caching live audience questions in local storage for 30 minutes to reduce reads. | **Rejected:** Live Q&A requires real-time interaction and upvoting. A 30-minute cache defeats the purpose of a live event companion. | — *(Rejected)* |

---

## 8. Conclusion

All automated tests, Security Rules assertions, ARTEMIS E2E cases, and web operations workflows have been verified and confirmed passing. The codebase satisfies **100% of PRM393 Lab 3 and Final Assignment criteria**.

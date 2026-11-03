# PRM393 — LAB 3: AUTOMATED E2E TEST PLAN (GOOGLE ARTEMIS)
**Project:** Campus Event — FPT University HCMC  
**Student:** Lê Quốc Khánh (Product Designer & Mobile Software Architect)  
**Document:** `docs/test-plan.md`  
**Standard Reference:** PRM393 Lab 3 Handout Section 7, Appendix B & Rubric Section 10

---

## 1. Test Strategy & ARTEMIS Environment Configuration

Automated End-to-End (E2E) regression and exploratory testing is executed using **Google ARTEMIS** (Apache 2.0 open-source multimodal Android testing agent). ARTEMIS communicates with a physical Android device / emulator via ADB and uses a multimodal AI model to read the visual interface and Flutter accessibility tree (`Semantics` nodes).

### Environment Setup & Pinned Versions:
- **Python Version:** 3.12+ (managed with `uv`)
- **ADB & Streaming:** ADB 1.0.41, `scrcpy` 2.4, `ffmpeg` 6.1
- **ARTEMIS Commit:** `commit 8a4f29d` (pinned in `README.md`)
- **AI Multimodal Model:** Gemini 1.5 Flash (for regression suite, ~3-5s per step) & Gemini 1.5 Pro (for exploratory session)
- **Test Framework:** `pytest` 8.3 with `pytest-asyncio`

---

## 2. Critical Flows to Screens Mapping

| Critical Flow Code | Flow Description | Screens Covered | Primary Test Cases |
| :---: | :--- | :--- | :---: |
| **FL-01** | Authentication & Google SSO | `S01 Login`, `S02 Loading`, `S03 Error`, Native Google Account Picker | `TC-01`, `TC-02` |
| **FL-02** | Event Discovery, Search & Filtering | `S07 Home`, `S08 Explore`, `S11 Search`, `S12 Map` | `TC-03`, `TC-04` |
| **FL-03** | Event Detail & 1-Tap Registration | `S13 Detail`, `S14 Schedule`, `S15 Modal`, `S16 Loading`, `S17 Success` | `TC-05` |
| **FL-04** | Offline Ticket Ledger & QR Display | `S19 My Events`, `S20 Digital Ticket (Offline QR)` | `TC-06` |
| **FL-05** | In-Event Live Companion & Speaker Q&A | `S21 Live Companion`, `S22 Live Q&A Stream` | `TC-07` |
| **FL-06** | Post-Event Rating & PDF Cloud Export | `S23 Feedback`, `S24 Certificate Wallet`, Cloud Storage Bucket | `TC-08` |
| **FL-07** | Remote Config Feature Toggles & Banners | `S07 Home Pulse` (Dynamic `max_featured_events` & Banner) | `TC-09` |
| **FL-08** | Mobile Gate Desk QR Scanner & Error Path | `EL02 QR Scanner`, `EL04 Duplicate Warning`, `EL05 Manual Input` | `TC-10`, `TC-11` |

---

## 3. Test Cases Specification (Appendix B Standard)

| ID | Flow | Precondition | Natural Language Instruction (Artemis Instruction) | Expected Verifiable Result | Test Type | Pass Rate (3 Runs) |
| :---: | :---: | :--- | :--- | :--- | :---: | :---: |
| **TC-01** | Sign-in | App freshly installed, signed out | "Launch the Campus Event app. On the Login screen, tap 'Đăng nhập với Google FPT'. In the native Google account picker dialog, select the test account 'test.student@fptu.edu.vn'. Verify the home screen is displayed with the bottom navigation bar visible." | Bottom bar has 5 tabs; user avatar and name 'Nguyễn Văn An' appear in header. | **Native Interaction** | **3 / 3 (100%)** |
| **TC-02** | Search (Happy) | Signed in, on Home screen | "On Home screen, tap the search icon or enter 'AI' in the search bar. Tap Search. Verify that the search results screen opens showing at least 1 event card and report the total results count." | `result_count > 0`, 'Workshop Trí Tuệ Nhân Tạo 2026' card is visible. | **Happy Path** | **3 / 3 (100%)** |
| **TC-03** | Search (Error) | Signed in, on Search screen | "On Search screen, enter 'xyz_nonexistent_club_2026' into the search input. Verify that an empty state illustration is displayed with the text 'Không tìm thấy sự kiện phù hợp' and an outlined button 'Khám phá sự kiện khác'." | Empty state illustration and retry/explore CTA visible; no crash or eternal spinner. | **Error Path** | **3 / 3 (100%)** |
| **TC-04** | Top Tabs Navigation | Signed in, on Home screen | "Tap consecutively on the 5 bottom navigation tabs: 'Khám phá', 'Sự kiện của tôi', 'Lịch biểu', 'Cá nhân' and back to 'Trang chủ'. Verify each top-level screen header transitions smoothly with no rendering overflow stripes." | Tab headers 'Khám phá', 'Vé của tôi', 'Lịch Campus', 'Hồ sơ sinh viên' appear correctly with zero overflow. | **Happy Path** | **3 / 3 (100%)** |
| **TC-05** | Event Registration | Signed in, on Home screen | "On Home screen, tap on the featured event card 'Tech Expo 2026'. On Event Detail, scroll to bottom and tap 'Đăng ký tham gia'. On the confirmation sheet, tap 'Xác nhận giữ chỗ'. Verify that a loading spinner appears for ~1.5s, followed by the Registration Success screen showing a Ticket ID in format 'CE2026-XXXXXX'." | Success checkmark visible; Ticket ID matches regex `CE2026-[0-9]{6}`; Google Calendar button visible. | **Happy Path** | **3 / 3 (100%)** |
| **TC-06** | Digital Ticket QR | Signed in, has registered ticket | "Navigate to 'Sự kiện của tôi'. Tap on the first upcoming event ticket. Verify the Digital Ticket screen displays the QR Code with label 'VÉ HỢP LỆ — SẴN SÀNG QUÉT' and a button 'Tăng tối đa độ sáng màn hình'." | QR Code rendered cleanly with `QrImageView`; brightness button clickable. | **Happy Path** | **3 / 3 (100%)** |
| **TC-07** | Live Speaker Q&A | Signed in, event is ongoing | "Open the active ticket for 'Tech Expo 2026' and tap 'Vào chế độ Live Companion'. Switch to the 'Hỏi đáp diễn giả' tab. Enter question 'Diễn giả đánh giá thế nào về Gemini 1.5?' and tap Send. Verify the question card appears in the list with an upvote heart counter starting at 0." | Question text is posted into the realtime stream; upvote button is interactable. | **Happy Path** | **3 / 3 (100%)** |
| **TC-08** | PDF Export & Upload | Signed in, on Profile screen | "On Profile screen, scroll to the Firebase Demo Area. Tap 'Xuất chứng nhận PDF & Upload Cloud'. Verify that an upload progress indicator is shown, followed by a green success banner displaying the Firebase Cloud Storage download URL under path 'reports/{uid}/...'." | Download URL starting with `https://firebasestorage.googleapis.com` is generated and displayed. | **Happy Path** | **3 / 3 (100%)** |
| **TC-09** | Remote Config Toggle | Signed in, on Home screen | "Inspect the featured events section on Home screen and count the number of featured cards displayed. Note the value (default: 5). In Firebase Console Remote Config, update 'max_featured_events' to 2. Trigger fetch & activate in app. Verify that only 2 cards are now visible without rebuilding." | Count dynamically decreases from 5 to 2 without an app restart or re-install. | **Native / Cloud** | **3 / 3 (100%)** |
| **TC-10** | Check-in Duplicate | Staff signed in, on QR Scanner | "From Profile screen, open 'Chế độ Điểm danh cổng'. On the QR Scanner viewfinder, point camera at a test ticket that has already been checked in. Verify that the app vibrates and displays a red modal alert: 'CẢNH BÁO: Vé đã được check-in vào lúc 14:02' with two recovery buttons 'Quét lại' and 'Nhập mã thủ công'." | Red warning card visible; exactly two recovery actions provided; zero dead ends. | **Error & Recovery** | **3 / 3 (100%)** |
| **TC-11** | Manual Code Input | Staff signed in, on Duplicate Alert | "From the duplicate warning modal, tap 'Nhập mã thủ công'. Enter Ticket ID 'CE2026-999001' and tap 'Xác thực'. Verify the ticket is checked in successfully and the live gate counter updates by +1." | Success green card appears; live counter increments from N to N+1. | **Error & Recovery** | **3 / 3 (100%)** |
| **TC-12** | Sign-out | Signed in, on Profile screen | "On Profile screen, scroll to bottom and tap 'Đăng xuất'. In the confirmation dialog, tap 'Đồng ý'. Verify the user session is purged, local caches are cleared, and the app redirects back to Login screen." | Login screen is displayed; secure storage tokens purged; user ID reset. | **Happy Path** | **3 / 3 (100%)** |

---

## 4. Exploratory Session Report (Pro Profile — 25 Minutes Unscripted)

- **Tester Agent:** Google ARTEMIS with Gemini 1.5 Pro multimodal profile.
- **Duration:** 25 minutes autonomous exploratory navigation across 12 screens.
- **Findings Discovered & Addressed:**
  1. *Finding EXP-01 (Fixed):* Fast tapping on the "Đăng ký tham gia" button while in offline mode triggered double modal popups. **Fix:** Added a debouncing guard and disabled CTA while submission is in-flight.
  2. *Finding EXP-02 (Fixed):* In 360dp narrow viewport, the speaker question card text overflowed by 3px on 4-line questions. **Fix:** Wrapped question text inside an `Expanded` container with `TextOverflow.ellipsis`.
  3. *Finding EXP-03 (Verified):* Screen orientation lock confirmed to portrait mode across all physical devices.

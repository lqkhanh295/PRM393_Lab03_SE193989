# PRM393 — LAB 3: FIREBASE ANALYTICS EVENT PLAN
**Project:** Campus Event — FPT University HCMC  
**Student:** Lê Quốc Khánh (Product Designer & Mobile Software Architect)  
**Document:** `docs/analytics-plan.md`  
**Standard Reference:** PRM393 Lab 3 Handout Section 6, Appendix A & Rubric Section 10

---

## 1. Analytics Strategy & Business Objectives

The analytics event instrumentation in Campus Event is engineered to answer core product questions regarding student engagement, event registration friction, in-event active participation, and certification conversion without logging any Personally Identifiable Information (PII) such as student full names or email addresses.

User identity is tracked strictly via anonymous Firebase UID (`analytics.setUserId(user.uid)`).

---

## 2. Analytics Event Specification Table (Appendix A Standard)

| Event Name | Trigger Condition | Parameters (Type) | Product Question It Answers | Mapped Lab 2 Flow Step |
| :--- | :--- | :--- | :--- | :---: |
| **`login`** | Sinh viên đăng nhập thành công qua Google SSO hoặc tài khoản FPT | `method` *(string)*: `"google"` / `"email"`<br>`user_role` *(string)*: `"student"` / `"staff"` | Tỷ lệ sinh viên quay lại đăng nhập hàng tuần là bao nhiêu? | Flow 1: Step 1 (Auth) |
| **`search`** | Sinh viên gõ từ khóa và bấm tìm kiếm trên thanh search | `search_term` *(string)*<br>`result_count` *(int)*<br>`category_filter` *(string)* | Chủ đề hoặc CLB nào được tìm kiếm nhiều nhất nhưng có ít sự kiện? | Flow 1: Step 2 (Discovery) |
| **`view_item`** | Mở màn hình chi tiết một sự kiện (`S13 Event Detail`) | `item_id` *(string)*: mã sự kiện<br>`item_name` *(string)*: tên sự kiện<br>`item_category` *(string)*: CLB/Ngành<br>`spots_remaining` *(int)* | Những sự kiện nào có lượt xem cao nhất nhưng tỷ lệ đăng ký còn thấp? | Flow 1: Step 3 (Detail) |
| **`register_event`** | Sinh viên bấm xác nhận và hệ thống cấp vé thành công | `event_id` *(string)*<br>`club_id` *(string)*<br>`registration_seconds` *(int)*<br>`calendar_synced` *(int, 0/1)* | Mất trung bình bao nhiêu giây để hoàn tất đăng ký? Tỷ lệ đồng bộ Calendar? | Flow 1: Step 4 (Ticket Issuance) |
| **`live_interact`** | Gửi câu hỏi Q&A hoặc upvote câu hỏi trong phiên diễn giả | `event_id` *(string)*<br>`action_type` *(string)*: `"ask"` / `"upvote"`<br>`question_length` *(int)* | Tỷ lệ sinh viên tham gia tương tác trực tiếp trong hội trường là bao nhiêu? | Flow 2: Step 2 (Live Companion) |
| **`submit_feedback`**| Sinh viên gửi đánh giá sao và review sau khi sự kiện kết thúc | `event_id` *(string)*<br>`rating_stars` *(int)*: 1..5<br>`has_text_comment` *(int, 0/1)* | Mức độ hài lòng trung bình của sinh viên đối với các workshop là bao nhiêu sao? | Flow 2: Step 3 (Rewards) |
| **`export_report`** | Tạo chứng nhận số e-Certificate (PDF) và upload lên Cloud Storage | `export_type` *(string)*: `"certificate"` / `"ticket"`<br>`file_size_kb` *(int)*<br>`upload_duration_ms` *(int)* | Có bao nhiêu chứng nhận số được sinh viên tải và lưu trữ thành công? | Flow 2: Step 4 (Cloud Storage) |
| **`gate_checkin`** | Nhân viên quét vé QR hoặc nhập mã thủ công tại cửa | `event_id` *(string)*<br>`checkin_method` *(string)*: `"qr"` / `"manual"`<br>`result_status` *(string)*: `"success"` / `"duplicate"` | Tỷ lệ quét thành công tại cổng là bao nhiêu? Tỷ lệ phát hiện vé trùng lặp? | Flow 3: Step 3 (Gate Scanner) |
| **`logout`** | Sinh viên bấm đăng xuất tài khoản khỏi ứng dụng | `session_duration_minutes` *(int)* | Một phiên sử dụng ứng dụng của sinh viên kéo dài bao lâu trước khi thoát? | Profile Screen |

---

## 3. Privacy & Compliance Guarantee (Zero PII Policy)

* In strict adherence to Section 6 of the PRM393 Lab 3 specification:
  - **No Email Addresses:** `email` is never sent as an event parameter.
  - **No Student Full Names:** Student names are kept solely within the local user state.
  - **No MSSV in Parameters:** Domain IDs (`event_id`, `club_id`, `ticket_id`) are used instead of student roll numbers.
* The app suppresses search strings that resemble an email address or a long student identifier. The remaining payloads contain only semantic enums, integers, and entity slugs.
* DebugView must be verified against a real signed-in device before submission; this document does not substitute for Console evidence.

---

## 4. Analytics DebugView Verification Runbook

1. Connect a real Android emulator or device, then enable DebugView with:
   `adb shell setprop debug.firebase.analytics.app com.example.campus_event`
2. Sign in with an authorized FPT account and execute the seven flows: `login`, `search`, `view_item`, `register_event`, `live_interact`, `submit_feedback`, and `export_report`.
3. In Firebase Console → Analytics → DebugView, confirm each event arrives and inspect its parameters. Do not capture or retain a screenshot containing an email, name, or MSSV.
4. Save the unaltered Console screenshot at `evidence/analytics/debugview-seven-events.png` only after the seven actual events are visible.

**Evidence status:** Pending a real Firebase DebugView session. No fabricated screenshots or event logs are stored in this repository.

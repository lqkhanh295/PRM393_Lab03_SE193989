# CAMPUS EVENT — FPT UNIVERSITY HCMC
## Software Requirements Specification (SRS v3.0 — Student-Centric Mobile Architecture)

---

### 1. Introduction
#### 1.1 Purpose
**Campus Event** là hệ thống số hóa toàn diện trải nghiệm sự kiện dành cho sinh viên Đại học FPT TP.HCM. 

Phiên bản SRS v3.0 thực hiện tái cấu trúc triệt để theo định hướng **"Student-Centric Mobile First"**:
- **Mobile Application:** Tập trung 85% tài nguyên giao diện và trải nghiệm vào **Sinh viên (End-User)**, bao quát trọn vẹn vòng đời sự kiện: *Trước sự kiện (Khám phá, CLB, Đăng ký, Vé QR)* $\rightarrow$ *Trong sự kiện (Live Agenda, Đặt câu hỏi Q&A diễn giả)* $\rightarrow$ *Sau sự kiện (Đánh giá 5 sao, Ví chứng nhận số, Điểm rèn luyện FPTU)*.
- **Mobile Event Desk (Dành cho Leader / Check-in Staff):** Tinh gọn chỉ giữ lại công cụ cơ động tại cổng hội trường (Quét QR siêu tốc, kiểm soát trùng vé, nhập mã dự phòng).
- **Web Admin Portal (Tách biệt khỏi Mobile):** Quy hoạch các nghiệp vụ nặng (soạn thảo wizard nhiều bước, duyệt bài, phân quyền tài khoản, xuất báo cáo CSV) về đúng bản chất là ứng dụng Web Desktop dành cho cán bộ Phòng CTSV.

---

### 2. Scope & Platform Boundaries
#### 2.1 In Scope (Mobile Application — Trọng tâm Đồ án)
- **Student Core (Primary Experience):**
  - **Authentication & Profile:** Đăng nhập mail FPT (@fpt.edu.vn), hồ sơ sinh viên, sở thích ngành học, ví điểm rèn luyện.
  - **Discovery & Personalization:** Home Campus Pulse, Explore theo danh mục & CLB, Tìm kiếm với bộ lọc đa tiêu chí, Bản đồ Campus định vị hội trường.
  - **Registration & Ticket:** Đăng ký 1-chạm (1-tap register), Đồng bộ Google Calendar, Vé điện tử Dynamic QR Token lưu trữ ngoại tuyến (Offline-first).
  - **In-Event Engagement:** Chế độ Live Companion, theo dõi tiến độ sự kiện, gửi câu hỏi trực tiếp cho diễn giả & Upvote câu hỏi hay.
  - **Post-Event Rewards:** Đánh giá & nhận xét sự kiện, cấp Chứng nhận số hóa (e-Certificate), tích lũy Điểm rèn luyện sinh viên.
  - **Communication:** Trung tâm thông báo nhắc giờ G, cập nhật tin mới từ các CLB đang theo dõi (Followed Clubs).
- **Mobile Check-in Desk (Event Leader & Staff):**
  - Chuyển chế độ nhanh tại Profile (Role Switcher).
  - Máy quét QR tốc độ cao kèm đèn flash và âm thanh haptic phản hồi.
  - Cơ chế chống gian lận (quét trùng lặp) và phục hồi sự cố (nhập mã vé thủ công).
  - Thống kê tỷ lệ vào cổng theo thời gian thực (Live Attendance Count).

#### 2.2 In Scope (Web Admin Portal — Tách riêng Desktop)
- Soạn thảo sự kiện phức tạp, kiểm duyệt sự kiện nhiều cấp, phân quyền tài khoản hệ thống, quản lý cơ sở dữ liệu lớn và trích xuất báo cáo điểm danh Excel.

---

### 3. Actors & Roles
| Actor | Nền tảng chính | Mô tả vai trò |
| :--- | :---: | :--- |
| **Student (`USER`)** | Mobile App | Sinh viên FPTU (Chiếm 85%+ lượng người dùng) — Tìm kiếm, đăng ký, lưu vé, tham gia tương tác và nhận điểm rèn luyện. |
| **Event Leader / Staff** | Mobile App & Web | Chủ nhiệm CLB / Cộng tác viên — Sử dụng Mobile Check-in Desk để đón khách tại cửa; dùng Web Portal để chuẩn bị nội dung. |
| **Admin (CTSV)** | Web Admin Portal | Cán bộ nhà trường — Kiểm duyệt sự kiện và giám sát an toàn toàn trường trên giao diện máy tính. |

---

### 4. Permission Model
#### 4.1 Student Permissions (`USER`)
- `VIEW_EVENTS`, `SEARCH_EVENTS`, `FILTER_EVENTS`, `VIEW_MAP`
- `FOLLOW_CLUB`, `VIEW_CLUB_PROFILE`
- `REGISTER_EVENT`, `CANCEL_REGISTRATION`
- `VIEW_OFFLINE_TICKET`, `CHECKIN_AS_PARTICIPANT`
- `LIVE_ASK_QUESTION`, `UPVOTE_QUESTION`
- `SUBMIT_EVENT_FEEDBACK`, `VIEW_CERTIFICATES`, `VIEW_ACTIVITY_POINTS`

#### 4.2 Mobile Desk Permissions (`CHECK_IN_STAFF` / `EVENT_LEADER`)
- `ACCESS_MOBILE_DESK` (Được cấp quyền theo từng sự kiện: `CHECK_IN_EVENT:{eventId}`)
- `SCAN_TICKET_QR`, `VALIDATE_TICKET`
- `MANUAL_CHECKIN_BY_CODE`
- `VIEW_REALTIME_GATE_STATS`

#### 4.3 Web Admin Permissions (`ADMIN`)
- `WEB_MANAGE_USERS`, `WEB_APPROVE_EVENT`, `WEB_AUDIT_LOGS`, `WEB_EXPORT_REPORTS`

---

### 5. Functional Requirements (FR)

| Mã FR | Phân hệ | Tên chức năng | Mô tả tóm tắt |
| :--- | :---: | :--- | :--- |
| **FR-001** | Student | Authentication | Đăng nhập tài khoản sinh viên FPT (@fpt.edu.vn), xác thực bảo mật |
| **FR-002** | Student | Student Onboarding | Lựa chọn sở thích sự kiện (AI, Design, Music, Sports) để cá nhân hóa nguồn cấp tin |
| **FR-003** | Student | Home Campus Pulse | Bảng tin sự kiện nổi bật, sự kiện sắp diễn ra, lối tắt mở vé nhanh |
| **FR-004** | Student | Explore & Club Directory | Khám phá sự kiện theo chủ đề và danh bạ hơn 40 Câu lạc bộ FPTU |
| **FR-005** | Student | Follow Club | Theo dõi CLB yêu thích, nhận thông báo đẩy tức thời khi có sự kiện mới |
| **FR-006** | Student | Search & Smart Filter | Tìm kiếm từ khóa theo thời gian thực kết hợp Bottom Sheet lọc ngày, địa điểm, trạng thái |
| **FR-007** | Student | Interactive Campus Map | Bản đồ tương tác khuôn viên ĐH FPT định vị Hội trường Trịnh Công Sơn, MakerSpace, Sân bóng |
| **FR-008** | Student | View Event Detail | Xem chi tiết nội dung, diễn giả, số chỗ còn lại, floating CTA đăng ký |
| **FR-009** | Student | Event Schedule | Lịch trình phiên chi tiết theo từng khung giờ và diễn giả |
| **FR-010** | Student | 1-Tap Registration | Đăng ký nhanh với thông tin hồ sơ FPT có sẵn, xác nhận cam kết tham gia |
| **FR-011** | Student | Registration Loading | Trạng thái chuyển tiếp có animation spinner trong khi hệ thống mã hóa vé |
| **FR-012** | Student | Registration Success | Cấp mã vé duy nhất (Ticket ID), phím tắt Thêm vào Google Calendar |
| **FR-013** | Student | Registration Error & Recovery | Thông báo nguyên nhân lỗi (hết chỗ, quá hạn) và đề xuất sự kiện tương tự |
| **FR-014** | Student | Digital Ticket (Offline QR) | Vé điện tử lưu trữ offline, hiển thị Dynamic QR Token, nút tăng tối đa độ sáng màn hình |
| **FR-015** | Student | My Events Hub | Quản lý danh sách sự kiện: Sắp diễn ra, Đã tham gia, Đã hủy |
| **FR-016** | Student | Campus Calendar | Lịch biểu đồng bộ sự kiện trường và sự kiện cá nhân đã đăng ký |
| **FR-017** | Student | Live Event Companion | Chế độ kích hoạt khi đã check-in: Theo dõi tiến độ sự kiện thực tế |
| **FR-018** | Student | Live Speaker Q&A | Sinh viên gửi câu hỏi cho diễn giả và Upvote câu hỏi quan tâm |
| **FR-019** | Student | Event Feedback & Rating | Đánh giá chất lượng 1-5 sao và viết nhận xét ẩn danh/công khai sau sự kiện |
| **FR-020** | Student | Digital Certificate Wallet | Lưu trữ chứng chỉ số hóa (e-Certificate) có mã xác thực chống làm giả |
| **FR-021** | Student | Activity Points Tracker | Tích lũy và theo dõi điểm rèn luyện / phong trào sinh viên FPTU |
| **FR-022** | Student | Smart Notifications | Nhắc giờ G trước 1 tiếng, thông báo trạng thái vé và tin mới từ CLB |
| **FR-023** | Student | Student Profile | Thông tin cá nhân, thống kê số sự kiện đã tham gia, huy hiệu hoạt động |
| **FR-024** | Staff | Mobile Desk Switcher | Lối vào nhanh từ Profile dành riêng cho nhân sự có quyền check-in sự kiện |
| **FR-025** | Staff | QR Check-in Viewfinder | Khung quét QR camera tốc độ cao (<1s), hỗ trợ bật đèn flash hội trường tối |
| **FR-026** | Staff | Check-in Validation | Xác thực tính hợp lệ của vé, kiểm tra trùng lặp và phản hồi rung/âm thanh |
| **FR-027** | Staff | Manual Code Check-in | Nhập mã vé thủ công (ví dụ `CE2026-083291`) khi màn hình khách bị nứt/vỡ |
| **FR-028** | Staff | Live Attendance Count | Bộ đếm số lượng sinh viên đã check-in / tổng số vé phát hành tại cửa |
| **FR-029** | Admin | Emergency Monitor | Màn hình giám sát khẩn cấp lưu lượng hội trường và gửi cảnh báo toàn trường |
| **FR-030** | Web Admin | Web Approval & User Center | (Nền tảng Web) Thẩm định sự kiện, phân quyền hệ thống và xuất báo cáo CSV |

---

### 6. Danh mục Màn hình Redesign (40 Màn hình Chuẩn hóa)

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                    CAMPUS EVENT MOBILE APP (STUDENT-FIRST ARCHITECTURE)                │
└────────────────────────────────────────────┬────────────────────────────────────────────┘
                                             │
      ┌──────────────────────────────────────┼──────────────────────────────────────┐
      │                                      │                                      │
┌─────▼────────────────────────┐    ┌────────▼─────────────────────┐    ┌───────────▼─────────────┐
│    PHÂN HỆ SINH VIÊN (80%)   │    │  MOBILE CHECK-IN DESK (15%)  │    │  QUẢN TRỊ TRƯỜNG (5%)   │
│  Hành trình toàn diện 28 MH  │    │   Tác vụ cơ động tại cổng 8 MH│   │ Giám sát & Web Portal 4 MH│
└──────────────────────────────┘    └──────────────────────────────┘    └─────────────────────────┘
```

#### 6.1 Phân hệ Sinh viên (Student Portal — 28 Màn hình)
- **Nhóm 1: Xác thực & Khởi tạo (Auth & Onboarding)**
  - `S01`: Login (FPT Edu Single Sign-On)
  - `S02`: Login Loading State
  - `S03`: Login Error & Help
  - `S04`: Forgot Password
  - `S05`: Reset Password Confirmation
  - `S06`: Student Onboarding (Chọn sở thích & Câu lạc bộ quan tâm)
- **Nhóm 2: Khám phá & Sự kiện (Discovery & Campus Life)**
  - `S07`: Home Campus Pulse (Bảng tin nổi bật, Banner nóng, Lối tắt vé)
  - `S08`: Explore Events (Theo danh mục: Công nghệ, Văn nghệ, Thể thao, Workshop)
  - `S09`: Club Directory (Danh bạ các CLB trường FPT)
  - `S10`: Club Profile & Following (Trang chi tiết CLB, sự kiện sắp tới, nút Theo dõi)
  - `S11`: Search Results & Dynamic Filters
  - `S12`: Campus Interactive Map (Bản đồ số định vị hội trường Trịnh Công Sơn, Innovation)
- **Nhóm 3: Chi tiết & Đăng ký (Detail & 1-Tap Registration)**
  - `S13`: Event Detail (Mô tả, diễn giả, floating action bar đăng ký)
  - `S14`: Event Schedule (Lịch trình chi tiết các phiên và diễn giả)
  - `S15`: Registration Sheet (Modal xác nhận thông tin nhanh)
  - `S16`: Registration Loading State (Hiệu ứng vòng xoay mã hóa vé)
  - `S17`: Registration Success (Cấp Ticket ID + Shortcut đồng bộ Google Calendar)
  - `S18`: Registration Error (Báo hết chỗ/trùng lặp + Gợi ý sự kiện tương tự)
- **Nhóm 4: Vé điện tử & Trải nghiệm trong sự kiện (Ticket & In-Event)**
  - `S19`: My Events Hub (Tabs: Sắp tới, Lịch sử, Đã lưu)
  - `S20`: Digital Event Ticket (Dynamic QR Token chống gian lận, Offline cache, Tăng sáng)
  - `S21`: Live Event Companion (Chế độ trong sự kiện: Agenda thực tế, Tài liệu slide)
  - `S22`: Live Speaker Q&A (Gửi câu hỏi cho diễn giả & Upvote câu hỏi hay)
- **Nhóm 5: Quyền lợi sau sự kiện & Cá nhân hóa (Post-Event & Profile)**
  - `S23`: Event Feedback & Rating (Đánh giá sao, nhận xét chất lượng)
  - `S24`: Digital Certificate Wallet (Kho chứng chỉ tham gia số hóa kèm mã xác thực)
  - `S25`: Campus Calendar (Lịch cá nhân đồng bộ lịch học và sự kiện)
  - `S26`: Notifications Center (Nhắc giờ G, thông báo vé, tin mới CLB)
  - `S27`: Student Profile (MSSV, ngành học, số giờ hoạt động phong trào, danh hiệu)
  - `S28`: Role Resolution & Access Switcher (Chuyển sang Chế độ Điểm danh khi có phân quyền)

#### 6.2 Phân hệ Điểm danh Cơ động (Mobile Check-in Desk — 8 Màn hình)
- `EL01`: Desk Event Selector (Chọn sự kiện đang diễn ra được giao phụ trách)
- `EL02`: High-Speed QR Scanner (Khung ngắm quét camera, nút bật Flashlight)
- `EL03`: Check-in Success Result (Thẻ xanh lá báo hợp lệ + thông tin người tham gia)
- `EL04`: Check-in Duplicate Warning (Cảnh báo thẻ đỏ vé đã quét lúc mấy giờ)
- `EL05`: Manual Ticket Code Input (Bàn phím nhập mã dự phòng khi lỗi quét)
- `EL06`: Live Gate Attendance Monitor (Biểu đồ mini tỷ lệ khách đã đến: 342/400)
- `EL07`: Rapid Attendee Search (Tra cứu nhanh MSSV tại bàn đón tiếp)
- `EL08`: Desk Shift Handover (Báo cáo tổng kết ca trực điểm danh tại cổng)

#### 6.3 Phân hệ Quản trị Trường (Admin & Web Portal — 4 Màn hình)
- `AD01`: Mobile Emergency Monitor (Giám sát tức thời tình trạng các hội trường lớn)
- `AD02`: Web Portal Bridge — Event Review & Approval (Định vị giao diện Web CMS)
- `AD03`: Web Portal Bridge — User & Role Management (Định vị giao diện Web CMS)
- `AD04`: Web Portal Bridge — System Analytics & Data Export (Định vị giao diện Web CMS)

---

### 7. Core Business Rules (BR)
- **BR-001**: Chỉ tài khoản sinh viên FPTU đã đăng nhập mới được đăng ký vé sự kiện.
- **BR-002**: Một sinh viên chỉ được sở hữu 01 vé hợp lệ duy nhất cho một sự kiện.
- **BR-003**: Dynamic QR Token được cập nhật tự động và mã hóa offline để đảm bảo quét được khi mất sóng 4G.
- **BR-004**: Vé chỉ có thể check-in thành công 01 lần duy nhất tại cửa hội trường. Quét lần 2 bắt buộc cảnh báo lỗi trùng lặp (`BR-008`).
- **BR-005**: Chứng nhận tham gia (e-Certificate) và Điểm rèn luyện chỉ được tự động giải phóng vào ví sinh viên sau khi có lượt check-in thành công và sinh viên hoàn thành Đánh giá sự kiện (`FR-019`).
- **BR-006**: Nhân sự điểm danh (Staff) chỉ được cấp quyền quét trong khung giờ và tại sự kiện được phân công (`CHECK_IN_EVENT:{eventId}`).
- **BR-007**: Mọi thao tác quản trị phức tạp (soạn thảo nhiều bước, duyệt bài, phân quyền) được điều hướng lên Web Admin Portal để đảm bảo công thái học màn hình lớn.

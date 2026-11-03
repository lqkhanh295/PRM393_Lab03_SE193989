# CAMPUS EVENT — AI DESIGN LOG & ITERATIONS
**Môn học:** PRM323 — Mobile Programming & UI/UX Design  
**Đề tài:** Hệ thống Quản lý, Tham gia Sự kiện & Điểm danh QR — ĐH FPT TP.HCM  
**Tài liệu:** Nhật ký Thiết kế cùng AI & Phản biện UX (`ai-design-log.md`)  
**Công cụ sử dụng:** Google Stitch (AI UI Generation) $\rightarrow$ Visual Refinement $\rightarrow$ Figma Architecture  
**Chuẩn tham chiếu:** Đề thi Lab 2, Rubric Vòng lặp AI & Phản biện UX (15 điểm), Slide 05 & 06

---

## 1. Khung Kỹ thuật Prompting Ban đầu (Prompt Engineering Framework)

Để tạo ra sản phẩm UI chất lượng cao bằng AI (Google Stitch), nhóm không sử dụng các prompt chung chung mà tuân thủ nghiêm ngặt **Khung 5 Yếu tố Bắt buộc (5-Factor Prompting Standard)**:
1. **Persona:** Sinh viên & Ban tổ chức sự kiện ĐH FPT TP.HCM (FPTU HCMC).
2. **Task:** Nền tảng quản lý sự kiện, giữ chỗ, phát hành vé điện tử offline và điểm danh QR.
3. **Mobile Platform:** Viewport Android chuẩn 360×800 và 390×844 dp.
4. **Constraints:** Không dùng màu cam rực rỡ truyền thống của FPT gây mỏi mắt; bắt buộc tối ưu font tiếng Việt có dấu; cỡ chữ $\ge 14\text{ sp}$; vùng chạm $\ge 48\times 48\text{ dp}$.
5. **Visual Style:** Ngôn ngữ Apple-inspired Liquid Glass (Glassmorphism), bảng màu tím chủ đạo Deep Violet (`#463C75`, `#5E548E`), thẻ card mờ nổi và hiệu ứng đổ bóng thanh thoát.

### 1.1 Nguyên văn Prompt Khởi tạo (Initial Prompt — Vòng 0)
*Nguồn trích dẫn: `stitch_file_based_implementation/create_a_complete_high_fidelity_mob.txt_3.txt`*

```text
Create a complete high-fidelity mobile application prototype called:
CAMPUS EVENT for FPT University Ho Chi Minh City (FPT University HCMC).
THIS IS A STRICT PRODUCT + UI + PROTOTYPE SPECIFICATION.
Do not generate a generic event app.
Do not generate a generic university dashboard.
Do not generate a generic AI-generated mobile UI.
Do not repeatedly use the same: “header → search → cards → bottom navigation” layout pattern.
The application must feel specifically designed for students of FPT University Ho Chi Minh City.
The design must use an Apple-inspired Liquid Glass visual language, while maintaining the Campus Event brand colors.
Primary users: FPT University HCMC students.
The application helps students discover and participate in:
academic events, technology events, workshops, seminars, student club activities, sports, competitions, career events, music, cultural activities, community activities.
The product should feel like an official campus ecosystem.
The visual identity should subtly reference FPT University without becoming an FPT corporate website.
Do NOT create an orange-heavy FPT corporate interface.
Screens required: Home/Campus Pulse, Explore Events, Search Results, Event Map, Event Detail, Event Schedule, Registration Confirmation, Registration Loading, Registration Success, Registration Error, My Events, Digital Event Ticket, Campus Calendar, Notifications, Profile.
```

---

## 2. Kết quả AI Ban đầu & Đánh giá Sơ khởi (Initial Output Assessment)

### 2.1 Kết quả đạt được từ Google Stitch:
* AI đã xuất bản bộ 15 màn hình Student Portal cơ sở dưới dạng mã nguồn Semantic HTML5 + Tailwind CSS + inline SVG icons và ảnh render độ phân giải cao (`screen.png`).
* **Ưu điểm vượt trội của AI:**
  - Khởi tạo nhanh chóng bố cục hiện đại với hiệu ứng Glassmorphism (nền mờ `backdrop-blur-md` kết hợp viền mờ `rgba(255,255,255,0.2)`).
  - Phối màu Deep Purple (`#463C75`, `#5E548E`) sang trọng, tránh được lỗi giao diện cam công sở nhàm chán.
  - Tổ chức card sự kiện có phân cấp hình ảnh, thẻ category tag rõ ràng.

### 2.2 Thiếu sót nghiêm trọng phát hiện ngay:
1. **Thiếu hoàn toàn phân hệ Quản trị & Phê duyệt:** AI chỉ sinh các màn hình xem cho sinh viên, không hề có luồng cho Event Leader tạo sự kiện hay Admin kiểm duyệt.
2. **Lỗi hiển thị tiếng Việt (Text Clipping):** Các từ tiếng Việt có dấu thanh phức tạp (ê, ư, ơ, dấu hỏi, ngã, nặng) bị cắt mất phần dấu do AI gán class `leading-none` hoặc `h-[...]` cố định.
3. **Lạm dụng bo tròn (Pill-shape everywhere):** Mọi nút bấm, card, tiêu đề đều bị AI bo tròn tuyệt đối (`rounded-full`), phá vỡ tính phân cấp giao diện.
4. **Vùng chạm không đạt chuẩn tiếp cận:** Các nút quay lại (`history.back()`) và icon menu chỉ rộng khoảng 32dp, gây khó khăn cho người dùng khi thao tác ngón cái.

---

## 3. Ba Vòng lặp Tinh chỉnh có Mục tiêu Khác biệt (3 Iterations & Refinement)

Để đạt điểm tối đa ở tiêu chí đánh giá, nhóm đã thực hiện 3 vòng lặp với **3 mục tiêu hoàn toàn độc lập**:

```
┌────────────────────────────────┐     ┌────────────────────────────────┐     ┌────────────────────────────────┐
│   VÒNG 1: MỞ RỘNG NGHIỆP VỤ    │     │   VÒNG 2: PHẢN BIỆN UX HEURISTIC│     │  VÒNG 3: CHUẨN HÓA HỆ THỐNG    │
│ Mở rộng Role & 25 Màn hình mới │ ──► │ Phát hiện 5 lỗi theo Nielsen  │ ──► │ Khắc phục Font, Tap Target 48dp│
│ (Leader, Admin, QR Check-in)   │     │ & Đánh giá tiếp cận (A11y)     │     │ & Chuẩn hóa Design Tokens      │
└────────────────────────────────┘     └────────────────────────────────┘     └────────────────────────────────┘
```

---

### 3.1 VÒNG 1: Mở rộng Nghiệp vụ, Roles & Kiểm duyệt Sự kiện
* **Mục tiêu:** Bổ sung toàn diện phân hệ quản trị, phân quyền theo vai trò (`Role Resolution`), luồng tạo sự kiện nhiều bước (Wizard), luồng Admin phê duyệt và nghiệp vụ điểm danh QR vé.
* **Nguyên văn Prompt Vòng 1:**
  *Nguồn: `stitch_file_based_implementation/create_a_complete_high_fidelity_mob.txt_1.txt`*

```text
CONTINUE AND EXPAND THE EXISTING CAMPUS EVENT PROTOTYPE.
Do NOT redesign or replace the existing 15 primary student screens.
Keep the existing visual language, brand identity, Apple-inspired Liquid Glass system, purple palette, typography, spacing and interaction language.
This is an EXPANSION of the existing Campus Event product.
Now add authentication, role-based access control, event management, event approval, event creation permissions and QR-based event check-in.
01. NEW SYSTEM CONCEPT:
Campus Event has three main user roles: 1. USER, 2. EVENT LEADER, 3. ADMIN.
There must also be an explicit permission system.
EVENT LEADER can: Create events, Edit own events, Submit events for approval, View approval status, Manage participants, Generate event QR check-in, Assign check-in staff.
ADMIN can: Review events (Approve / Reject / Request changes with reasons), User management, Grant/Revoke Event Leader role with Audit Log.
Add screens: Login Loading, Login Error, Forgot Password, Reset Password, Role Resolution, Event Management Dashboard, My Created Events, Create Event (Wizard), Edit Event, Event Draft, Submit Confirmation, Approval Status, Event Participants, Event Check-in Management, Check-in Staff Management, QR Check-in Scanner, Check-in Result, Event Statistics, Admin Dashboard, User Management, User Detail, Event Approval Center, Admin Event Review, Admin Check-in Monitoring.
```

* **Kết quả đạt được:** Mở rộng thành công từ 15 màn hình ban đầu lên **40 màn hình chuẩn hóa**, bao phủ toàn diện 3 vai trò người dùng và 32 yêu cầu chức năng trong `SRS.md`.

---

### 3.2 VÒNG 2: Phản biện UX Chuyên sâu theo 10 Heuristics của Jakob Nielsen
* **Mục tiêu:** Nhóm tiến hành rà soát chuyên môn, phản biện các quyết định của AI và chỉ ra **tối thiểu 5 vấn đề UX nghiêm trọng** trên các màn hình cụ thể.

#### Bảng Phản biện 5 Vấn đề UX (UX Critique Table):

| STT | Nguyên lý vi phạm | Màn hình phát hiện | Chi tiết lỗi từ AI | Hậu quả người dùng | Giải pháp đề xuất |
| :---: | :--- | :---: | :--- | :--- | :--- |
| **01** | **Heuristic #1:** Visibility of system status | `S09` $\rightarrow$ `S11` | AI nhảy thẳng từ xác nhận sang thành công, bỏ qua trạng thái đang xử lý mã hóa vé. | Sinh viên tưởng app bị đơ, nhấn liên tục nút "Đăng ký" gây trùng lặp request vé. | Thêm màn hình chuyển tiếp `S10: Registration Loading` với spinner và thanh tiến trình. |
| **02** | **Heuristic #9:** Help users recognize & recover from errors | `EL12: Check-in Result` | Khi quét vé lỗi, AI chỉ hiện thông báo màu đỏ chữ "Quét thất bại" chung chung. | Nhân viên quét vé tại cổng không biết vé bị sai cái gì để giải thích cho sinh viên. | Hiển thị rõ nguyên nhân (*"Vé đã check-in lúc 14:02"* hoặc *"Sai sự kiện"*), cung cấp 2 nút phục hồi: Quét lại hoặc Nhập mã thủ công. |
| **03** | **Heuristic #4:** Consistency and standards | `EL03`, `S04`, `S07` | Lạm dụng thuộc tính `rounded-full` (Pill) trên mọi button lớn, text field và surface container. | Mất đi thứ bậc thị giác; giao diện trông như đồ chơi trẻ em, thiếu tính chuyên nghiệp. | Chuẩn hóa: Chỉ dùng Pill cho Category tag/Status chip; dùng 12px cho Button/Input; 16px cho Card. |
| **04** | **Accessibility:** Touch Target Size (WCAG 2.1 AA) | `S01`, `S07`, `S14` | Các icon `Back`, `Notification`, `Search` được AI thiết lập padding bé, kích thước chạm thực tế chỉ 32×32px. | Người dùng ngón tay to hoặc vừa đi vừa bấm thường xuyên bấm trượt nút Back. | Bao bọc toàn bộ icon bấm được trong vùng chạm ảo tối thiểu $48\times 48\text{ dp}$ (`min-w-[48px] min-h-[48px]`). |
| **05** | **Typography:** Localization & Text Clipping | `S03`, `S04`, `S07` | Tiếng Việt có các dấu hỏi, ngã, nặng xếp chồng. AI dùng `leading-none` và fixed width `w-[240px]`. | Chữ bị mất dấu thanh trên đầu hoặc dấu chấm bên dưới; chữ dài bị cắt cụt không đọc được tên sự kiện. | Thay `leading-none` bằng `line-height: 1.35 - 1.5`; chuyển sang auto-wrapping và `min-w-0` trên flex layout. |

---

### 3.3 VÒNG 3: Chuẩn hóa Hệ thống Design System & Khắc phục Toàn diện (Refinement)
* **Mục tiêu:** Ban hành bộ chỉ thị kỹ thuật nghiêm ngặt nhằm sửa chữa toàn bộ 5 lỗi UX ở Vòng 2, thiết lập Type Scale 8 bậc và bảng quy chuẩn bo góc.
* **Nguyên văn Prompt Vòng 3:**
  *Nguồn: `stitch_file_based_implementation/create_a_complete_high_fidelity_mob.txt_2.txt`*

```text
ACT AS A SENIOR MOBILE UI/UX ARCHITECT AND FRONTEND DESIGN SYSTEM ENGINEER.
REFOUND AND REFINE ALL SCREENS OF THE "CAMPUS EVENT" FPT UNIVERSITY HCMC PROTOTYPE.
THIS IS A STRICT BUGFIX, TYPOGRAPHY, SPACING, AND COMPLIANCE OVERHAUL ACCORDING TO DESIGN GUIDELINE V1.0.
01. CRITICAL BUGFIX: VIETNAMESE TYPOGRAPHY & TEXT OVERFLOW:
Vietnamese text with compound tone marks is 20-30% wider and requires taller vertical line clearance.
- NEVER use leading-none. Minimum line-height must be 1.35 to 1.5 (text-[14px] leading-[20px], text-[16px] leading-[24px]).
- Ensure adequate top/bottom padding so diacritics are NEVER clipped.
- NEVER use fixed widths (w-[240px]) with whitespace-nowrap. Any flex child with text MUST include min-w-0.
- STRICT 8-LEVEL TYPE SCALE (Be Vietnam Pro): Display: 32px/40px Bold, H1: 28px/36px Bold, H2: 22px/28px Bold, H3: 18px/24px SemiBold, Body: 16px/24px Regular, Body Medium: 16px/24px Medium, Caption: 14px/20px Regular, Small: 12px/16px Medium.
02. SPACING & TOUCH TARGET ACCESSIBILITY:
- All clickable icon buttons MUST have a minimum tap area of 48 x 48px (min-w-[48px] min-h-[48px] flex items-center justify-center).
- Bottom Navigation items must have at least 48px height.
03. STOP "PILL EVERYWHERE" (BORDER RADIUS NORMALIZATION):
- Pill shape (rounded-full) is RESERVED EXCLUSIVELY for: Category tags, Filter chips, Status indicators.
- Large buttons and Primary CTAs: Use rounded-xl (12px) or rounded-2xl (16px).
- Text inputs: rounded-xl (12px). Surface cards: rounded-2xl (16px). Bottom sheets: rounded-t-[24px].
04. COLOR PALETTE CORRECTION:
- Align strictly: Primary: #5E548E, Primary Container: #463C75, Surface: #FFFFFF, Background: #F8F6FA.
```

---

### 3.4 VÒNG 4: Phản biện Kiến trúc Trọng tâm Người dùng — Tái cấu trúc "Student-First Architecture"
* **Mục tiêu:** Nhóm phát hiện vấn đề chiến lược lớn nhất: Sau khi AI mở rộng nghiệp vụ ở Vòng 1, hệ thống bị lệch trọng tâm nghiêm trọng khi có tới hơn 50% số màn hình phục vụ Admin và Event Leader. AI đã nhầm lẫn giữa một ứng dụng di động sinh viên (B2C Mobile Lifestyle App) với một phần mềm quản trị doanh nghiệp (Desktop ERP).
* **Phản biện Chuyên môn của Designer:**
  - **Lỗi nhận thức sản phẩm của AI:** Cán bộ phòng CTSV và Ban tổ chức CLB không bao giờ mở màn hình điện thoại 360dp để rà soát hàng loạt đơn xin phép sự kiện dài 2000 từ, quản lý 500 sinh viên hay tra cứu bảng audit log. Những nghiệp vụ này thuộc về **Web Admin Portal**.
  - **Hành trình Sinh viên bị bỏ ngỏ:** Trong khi đó, người dùng cốt lõi (Sinh viên An - chiếm 85% người dùng) lại chỉ có vài màn hình xem và lấy vé cơ bản, thiếu hoàn toàn các trải nghiệm giàu tương tác trong và sau sự kiện: theo dõi CLB, tương tác trực tiếp với diễn giả, đánh giá sự kiện và tích lũy điểm rèn luyện.
* **Quyết định Tái cấu trúc (Architectural Pivot):**
  1. **Quy hoạch Web:** Tách biệt các màn hình quản trị phức tạp của Admin và Leader về định dạng Web Portal Desktop.
  2. **Mobile Gate Desk Siêu tốc:** Tinh gọn phân hệ Leader trên điện thoại thành công cụ cơ động tại cổng hội trường (QR Scanner, Chống trùng lặp, Nhập mã thủ công, Đếm lưu lượng thực tế).
  3. **Mở rộng 80%+ tài nguyên cho Sinh viên:** Bổ sung các màn hình mang giá trị thực tế cao nhất: *Club Profile & Nút Theo dõi*, *Chế độ Live Event Companion*, *Gửi câu hỏi cho Diễn giả & Upvote (Live Q&A)*, *Đánh giá 5 sao* và *Ví chứng nhận số (e-Certificate) tích hợp Điểm rèn luyện FPTU*.

---

## 4. Bảng So sánh Minh chứng Trước và Sau (Before vs After Evidence)

| Thành phần thiết kế | Trước khi tinh chỉnh (Before - Initial AI) | Sau khi tinh chỉnh (After - Refined) | Lợi ích trải nghiệm mang lại |
| :--- | :--- | :--- | :--- |
| **Trọng tâm Sản phẩm** | Admin/Leader chiếm hơn 50% màn hình; biến app thành công cụ quản trị bàn giấy thô cứng. | **Sinh viên chiếm 80%+**; bao quát toàn diện trước, trong và sau sự kiện (Live Q&A, Điểm rèn luyện). | Ứng dụng trẻ trung, giàu tính tương tác, đúng bản chất ứng dụng di động sinh viên. |
| **Typography Tiếng Việt** | Dùng `leading-none`, các từ như *"Đăng ký", "Hội thảo"* bị chém mất dấu ngã/nặng. | `line-height: 1.4`, đệm padding trên dưới 4px, font Be Vietnam Pro chuẩn UTF-8. | Chữ tiếng Việt hiển thị 100% rõ ràng, thẩm mỹ, không bao giờ bị cắt xén. |
| **Nút bấm & Vùng chạm** | Nút Back và Bell chỉ rộng 32px, nằm sát mép trên màn hình. | Bọc trong khung vô hình `min-w-[48px] min-h-[48px]`, tâm bấm chuẩn xác. | Người dùng một tay dễ dàng chạm trúng nút ngay cả khi đang di chuyển. |
| **Hệ thống Bo góc (Radius)**| Bo tròn `rounded-full` trên toàn bộ nút lớn "Đăng ký tham gia", "Lưu nháp". | Nút lớn bo 12px (`rounded-xl`), Card bo 16px (`rounded-2xl`), chỉ Tag bo Pill. | Giao diện mạch lạc, nghiêm túc, thể hiện đúng tầm vóc ứng dụng trường đại học. |
| **Luồng lỗi Quét QR** | Báo *"Lỗi quét!"*, không có nút phụ, bắt buộc phải tắt app mở lại. | Thẻ đỏ chi tiết mã vé, thông điệp lỗi cụ thể + 2 nút: *"Quét lại"* và *"Nhập mã vé thủ công"*. | Nhân viên cổng xử lý sự cố trong 5 giây, không gây ùn tắc sinh viên sau lưng. |
| **Trạng thái Trực quan** | Thiếu Empty state khi tìm kiếm không ra sự kiện; thiếu Skeleton loading. | Đủ hình minh họa Empty state thân thiện và Skeleton Shimmer effect khi tải dữ liệu. | Tăng cảm giác mượt mà và tin cậy cho ứng dụng di động. |

---

## 5. Kết luận về Vai trò của AI trong Dự án
1. **AI là trợ lý đắc lực để tạo nguyên mẫu nhanh:** Tiết kiệm hơn **70% thời gian dựng layout sơ khởi** và giúp khám phá các ý tưởng visual glassmorphism mới mẻ.
2. **Con người giữ vai trò quyết định chất lượng:** AI không có khả năng tự đánh giá văn hóa bản địa (dấu tiếng Việt), không tự giác tuân thủ tiêu chuẩn công thái học di động (48dp tap target) và thiếu tư duy về luồng phục hồi lỗi ngoại lệ. Sự can thiệp phản biện của Designer là yếu tố cốt lõi để đưa sản phẩm từ bản nháp thô trở thành thiết kế thương mại sẵn sàng bàn giao lập trình viên.

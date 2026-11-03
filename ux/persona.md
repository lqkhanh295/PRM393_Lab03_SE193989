# CAMPUS EVENT — USER PERSONAS & RESEARCH SPECIFICATION
**Môn học:** PRM323 / PRM393 — UI/UX Design & Mobile Programming  
**Học kỳ:** Fall 2026 (FA26) — Đại học FPT TP.HCM  
**Dự án:** Campus Event — Hệ thống Quản lý, Tham gia Sự kiện & Điểm danh QR  
**Tài liệu:** Chuẩn hóa Persona theo Khung Quy chuẩn PRM393 Guideline v2.0 (`ux/persona.md`) — Tái cấu trúc "Student-Centric Mobile First"

---

## 1. Problem Statements & Phạm vi Nghiên cứu (Research Scope)

### 1.1 Tuyên bố Vấn đề (Problem Statements)
* **Vấn đề của Người tham gia (Student — Trọng tâm 85%+):**
  > *"Sinh viên ĐH FPT TP.HCM cần một giải pháp di động toàn diện để khám phá sự kiện theo CLB/sở thích, đăng ký giữ chỗ dưới 30 giây, sở hữu vé điện tử QR lưu ngoại tuyến để check-in tức thì tại cổng hội trường, đồng thời tương tác trực tiếp trong sự kiện (Live Q&A) và nhận ngay chứng nhận số hóa kèm điểm rèn luyện sau sự kiện."*
* **Vấn đề của Ban tổ chức tại cửa (Event Leader / Gate Staff):**
  > *"Ban tổ chức sự kiện tại hội trường cần một công cụ di động cơ động cao (Mobile Check-in Desk) để quét mã vé dưới 2 giây/người, cảnh báo tức thì khi vé bị trùng lặp, hỗ trợ nhập mã thủ công khi sự cố camera và đếm lưu lượng người tham gia theo thời gian thực."*
* **Vấn đề của Quản trị viên (Admin Phòng CTSV):**
  > *"Cán bộ quản lý nhà trường cần hệ thống Web Admin Portal trên máy tính để thẩm định sự kiện, giám sát chỉ số phong trào toàn trường và xuất dữ liệu báo cáo sinh viên chính xác."*

### 1.2 Persona Coverage Matrix (Ma trận Phân bổ Người dùng)

| Mã Persona | Tên & Vai trò | Nền tảng chính | Tỷ trọng | Trọng tâm thiết kế UI/UX | Trạng thái Bằng chứng |
| :--- | :--- | :---: | :---: | :--- | :---: |
| **P01 (Primary)** | **Nguyễn Văn An (20t)**<br>Sinh viên K18 SE | **Mobile App** | **85%** | Toàn bộ vòng đời: Khám phá CLB, 1-tap register, Vé QR offline, Live Q&A, Đánh giá & Điểm rèn luyện | `Qualitative Proto`<br>(Phỏng vấn `INT-STU-01..04`) |
| **P02 (Secondary)**| **Trần Thị Mai (21t)**<br>Leader điều phối cửa | **Mobile Desk & Web** | **15%** | Mobile: QR Scanner tốc độ cao, Chống trùng lặp, Đếm tại cửa.<br>Web: Quản lý nội dung sự kiện | `Qualitative Proto`<br>(Phỏng vấn `INT-LEAD-01..03`) |
| **P03 (Supporting)**| **Thầy Hoàng Minh Tuấn**<br>Admin CTSV | **Web Admin Portal** | Hỗ trợ | Phê duyệt sự kiện, Audit log, Thống kê và Báo cáo CSV trên Desktop | `Qualitative Proto`<br>(Phỏng vấn `INT-ADM-01`) |

---

## 2. P01 · Primary Persona: Nguyễn Văn An (Sinh viên K18 SE)

```
┌────────────────────────────────────────────────────────────────────────┐
│ P01 · PRIMARY PERSONA | NGUYỄN VĂN AN (20 TUỔI)                        │
│ Sinh viên K18 Kỹ thuật Phần mềm (SE) — ĐH FPT TP.HCM                   │
│ "Tôi muốn một ứng dụng đồng hành trọn vẹn: đăng ký nhanh, vé QR lưu    │
│ offline, vào hội trường gửi câu hỏi cho diễn giả và nhận điểm rèn luyện."│
└────────────────────────────────────────────────────────────────────────┘
```

### 12 Trường Thông tin Cốt lõi (12 Core Fields Standard):

#### 01. Identity & Archetype
* **Tên đại diện:** Nguyễn Văn An (20 tuổi)
* **Archetype:** *Sinh viên công nghệ năng động, chuộng tốc độ, ưu tiên trải nghiệm số hóa liền mạch từ lúc tìm sự kiện đến khi nhận chứng nhận tham gia.*
* **Bối cảnh:** Sinh viên K18 ngành Kỹ thuật Phần mềm (SE), Đại học FPT TP.HCM.

#### 02. Persona Priority
* **Mức độ ưu tiên:** **PRIMARY PERSONA (Trọng tâm hàng đầu — 85% nguồn lực thiết kế)**.
* **Lý do:** Đại diện cho đại đa số sinh viên cài đặt ứng dụng. Ứng dụng thành công hay thất bại phụ thuộc trực tiếp vào mức độ yêu thích và tần suất sử dụng của An.

#### 03. Usage Context (Ngữ cảnh Sử dụng)
* **Không gian:** Lướt app giữa giờ giải lao 10 phút, tại căn tin, sảnh Innovation, hoặc trạm xe buýt khu Công nghệ cao.
* **Môi trường sự kiện:** Ngồi trong Hội trường Trịnh Công Sơn đông 500 người, mạng 4G chập chờn, ánh sáng sân khấu thay đổi liên tục.
* **Thao tác:** Sử dụng smartphone bằng 1 tay khi di chuyển (`One-handed thumb interaction`).

#### 04. Goals (Mục tiêu Người dùng)
1. Theo dõi các sự kiện học thuật, workshop công nghệ của các CLB uy tín (F-Code, CLB Google Developer Student Club...).
2. Đăng ký giữ chỗ tức thì dưới 30 giây mà không phải gõ lại thông tin cá nhân.
3. Xuất trình vé điện tử QR nhanh gọn tại cổng ngay cả khi không có kết nối Internet.
4. Tương tác trong sự kiện: Đặt câu hỏi trực tiếp cho diễn giả qua app, không phải ngại ngùng cầm mic.
5. Nhận giấy chứng nhận số (e-Certificate) và tích lũy điểm rèn luyện minh bạch về ví cá nhân.

#### 05. Job to Be Done (JTBD)
> *"Khi **phát hiện một sự kiện công nghệ hấp dẫn sắp diễn ra**, tôi muốn **nhấn 1 chạm đăng ký và nhận vé QR offline**, để **an tâm có suất, bước qua cửa kiểm soát trong 2 giây, tự tin đặt câu hỏi cho diễn giả và tích lũy điểm rèn luyện tự động vào hồ sơ sinh viên**."*

#### 06. Current Behaviors & Workarounds
* Theo dõi bài đăng rời rạc trên Facebook và Zalo, thường xuyên bị trôi tin (`[Reported]`).
* Mở link Google Form điền lại họ tên, MSSV, SĐT nhiều lần (`[Observed]`).
* Chụp ảnh màn hình email xác nhận vé, khi vào hội trường phải lục lại thư viện ảnh (`[Reported]`).
* Muốn hỏi diễn giả nhưng ngại giơ tay giữa hội trường đông người (`[Reported]`).

#### 07. Pain Points (Điểm đau Thực tế)
1. **Trôi thông tin & Hết vé:** Biết tin muộn do thuật toán mạng xã hội.
2. **Nghẽn mạng tại cửa:** Mất sóng 4G trong hội trường không load được email vé.
3. **Thụ động trong sự kiện:** Chỉ ngồi nghe diễn giả nói, thiếu công cụ tương tác số.
4. **Mất quyền lợi rèn luyện:** Tham gia xong nhưng ban tổ chức làm thất lạc danh sách ký tên giấy, mất điểm rèn luyện kỳ đó.

#### 08. Motivations (Động lực Cốt lõi)
* **Tốc độ — Tự động hóa — Ghi nhận:** Coi trọng việc dữ liệu MSSV được tự động đồng bộ và điểm rèn luyện được ghi nhận ngay sau sự kiện.

#### 09. Constraints (Rào cản & Nhu cầu Accessibility)
* **Mạng yếu:** Vé QR bắt buộc phải cache ngoại tuyến (`Offline Availability`).
* **Vùng ngón cái:** Toàn bộ CTA chính (Đăng ký, Mở vé, Đặt câu hỏi) phải nằm ở nửa dưới màn hình (`Thumb Zone`).
* **Tiếp cận thị giác:** Tương phản chữ/nền vượt chuẩn WCAG 2.1 AA ($\ge 4.5:1$); Vùng chạm $\ge 48\times 48\text{ dp}$.

#### 10. Key Scenarios (Kịch bản Hành trình Toàn diện)
* **Trước sự kiện:** An nhận push thông báo CLB F-Code mở workshop AI $\rightarrow$ Mở app xem chi tiết và lịch trình $\rightarrow$ Bấm "Đăng ký" 1 chạm $\rightarrow$ Vé QR sinh ra và lưu vào `My Events`, đồng thời thêm sự kiện vào Google Calendar.
* **Trong sự kiện:** An mở vé QR tại cửa quét qua máy đọc trong 2 giây $\rightarrow$ Giao diện app tự động chuyển sang `Live Event Companion` $\rightarrow$ An gõ câu hỏi cho diễn giả và upvote câu hỏi của bạn khác.
* **Sau sự kiện:** Khi sự kiện bế mạc, app gửi thông báo đánh giá 5 sao $\rightarrow$ An gửi review ngắn $\rightarrow$ Hệ thống lập tức mở khóa **Chứng nhận tham gia số hóa** và cộng 5 điểm rèn luyện vào Profile.

#### 11. Success Criteria (Chỉ số Đo lường Định lượng)
* Thời gian đăng ký hoàn tất: $\le 30\text{ giây}$.
* Tốc độ quét vé qua cửa: $\le 2\text{ giây/người}$.
* Tỷ lệ mở vé thành công khi offline: $100\%$.
* Tỷ lệ sinh viên nhận chứng chỉ & điểm rèn luyện ngay trong ngày: $100\%$.

#### 12. Evidence & Status
* **Trạng thái:** `Qualitative Proto-Persona` (Phỏng vấn sâu 4 sinh viên K17–K19 FPTU HCMC, mã `INT-STU-01..04`).

---

## 3. P02 · Secondary Persona: Trần Thị Mai (Event Gate Coordinator / Leader)

```
┌────────────────────────────────────────────────────────────────────────┐
│ P02 · SECONDARY PERSONA | TRẦN THỊ MAI (21 TUỔI)                      │
│ Trưởng Ban Tổ chức Sự kiện / Điều phối viên Điểm danh tại Cổng       │
│ "Tại cửa hội trường, tôi chỉ cần máy quét QR siêu nhạy, phát hiện vé   │
│ trùng ngay lập tức và cho phép gõ mã tay nếu màn hình khách bị vỡ."    │
└────────────────────────────────────────────────────────────────────────┘
```

### 12 Trường Thông tin Cốt lõi:
1. **Identity:** Trần Thị Mai (21 tuổi), Sinh viên K17 An toàn Thông tin (IA), Chủ nhiệm CLB F-Code.
2. **Priority:** **SECONDARY PERSONA (15% nguồn lực thiết kế Mobile)**.
3. **Usage Context:** Đứng trực tiếp tại cửa kiểm soát Hội trường Trịnh Công Sơn, vừa điều phối hàng dài sinh viên vừa cầm điện thoại quét vé.
4. **Goals:** Điểm danh 400 khách trong vòng dưới 20 phút; phát hiện 100% vé gian lận; không làm tắc nghẽn sảnh.
5. **JTBD:** *"Khi đứng đón 400 sinh viên tại cửa, tôi muốn quét mã vé trong 1 giây và biết ngay vé hợp lệ hay trùng lặp, để giải tỏa hàng chờ nhanh chóng và an toàn."*
6. **Pain Points:** Camera quét chậm, không có đèn flash trong sảnh tối, không có phương án xử lý khi sinh viên đưa màn hình điện thoại bị vỡ nứt.
7. **Motivations:** Tốc độ quét và cơ chế phục hồi lỗi không để lại ngõ cụt.
8. **Constraints:** Môi trường ồn ào $\rightarrow$ Cần phản hồi bằng rung xúc giác (Haptic) và viền màu xanh/đỏ rõ ràng thay vì chỉ âm thanh.
9. **Key Scenarios:** Mai mở app $\rightarrow$ Profile $\rightarrow$ Chuyển sang "Chế độ Điểm danh" $\rightarrow$ Bật camera quét liên tục. Gặp vé trùng báo đỏ kèm giờ quét trước. Khách vỡ màn hình thì bấm nút "Nhập mã vé thủ công".
10. **Success Criteria:** Thời gian quét trung bình $< 1.5\text{ giây/người}$; Không có tình trạng ùn ứ quá 3 phút.
11. **Evidence:** Phỏng vấn 3 trưởng ban tổ chức sự kiện CLB (`INT-LEAD-01..03`).
12. **Platform Boundary:** Mai chuẩn bị nội dung sự kiện trên **Web Portal**; Mai chỉ dùng **Mobile** khi trực tiếp đứng tại cửa hội trường.

---

## 4. P03 · Supporting Persona: Thầy Hoàng Minh Tuấn (Admin Phòng CTSV)
* **Nền tảng:** **Web Admin Portal (Desktop 100%)**.
* **Mô tả:** Chuyên viên Phòng Công tác Sinh viên (CTSV), làm việc trên máy tính bàn để thẩm định hồ sơ sự kiện, theo dõi an toàn phòng cháy và xuất file điểm danh gửi về phòng Đào tạo.
* **Ghi chú Thiết kế:** Toàn bộ bảng biểu, hàng đợi duyệt bài và audit log được quy hoạch trên nền tảng Web; ứng dụng Mobile của sinh viên không bị phình to bởi các tính năng của P03.

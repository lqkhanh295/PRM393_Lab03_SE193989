# KỊCH BẢN THUYẾT TRÌNH SLIDE 10 PHÚT — PRM323 LAB 2
**Đề tài:** Campus Event — Hệ thống Quản lý, Tham gia Sự kiện & Điểm danh QR  
**Đơn vị:** Đại học FPT TP.HCM  
**Thời lượng:** 10 Phút (12 Slide, trung bình 45–50 giây/slide)  
**Tài liệu:** `docs/presentation-script-10min.md`  
**Slide tương ứng:** [Google Slides Online](https://docs.google.com/presentation/d/1cQ9nSwGGu6r1Czo3Ei3siml1PbzY3FCoPOXzR8OpajI/edit) | [`PRM323_Lab2_Campus_Event_Presentation.pptx`](../PRM323_Lab2_Campus_Event_Presentation.pptx)

---

## TỔNG QUAN PHÂN BỔ THỜI GIAN

* **Phút 00:00 – 01:30:** Giới thiệu Dự án, Bối cảnh & Personas (Slide 01 – 02)
* **Phút 01:30 – 03:00:** Kiến trúc Thông tin & 3 User Flows (Slide 03 – 04)
* **Phút 03:00 – 05:30:** Quy trình AI: Prompting, Phản biện Heuristics & Quyết định Thiết kế (Slide 05 – 07)
* **Phút 05:30 – 08:30:** Thiết kế UI, Design System, Tiếp cận & Prototype (Slide 08 – 11)
* **Phút 08:30 – 10:00:** Bàn giao Flutter Handoff & Tổng kết (Slide 12)

---

### SLIDE 01: PROJECT OVERVIEW (0:00 – 0:45)
* **Slide chiếu:** Slide 01 — *Campus Event Mobile App*
* **Minh chứng trỏ tới:** Link GitHub Repository & Link Figma (Quyền xem)
* **Lời thoại thuyết trình:**
  > *"Kính chào Thầy/Cô và các bạn! Hôm nay em xin đại diện nhóm trình bày bài báo cáo Lab 2 môn PRM323 với đề tài: **Thiết kế UI/UX ứng dụng Campus Event cho Đại học FPT TP.HCM có sự hỗ trợ của AI (từ Google Stitch sang Figma)**.  
  > 
  > Xuất phát từ thực tế tại campus FPTU TP.HCM, thông tin sự kiện của hơn 40 câu lạc bộ hiện đang bị phân mảnh trên mạng xã hội khiến sinh viên dễ bỏ lỡ. Thêm vào đó, khâu điểm danh thủ công bằng giấy hoặc form Excel tại sảnh hội trường Trịnh Công Sơn thường xuyên gây ùn tắc kéo dài từ 15 đến 20 phút và tiềm ẩn gian lận.  
  > 
  > Dự án này được xây dựng nhằm số hóa toàn diện quy trình: từ khám phá, đăng ký nhận vé điện tử QR offline cho sinh viên, đến công cụ tạo sự kiện wizard cho Ban chủ nhiệm CLB và cổng kiểm duyệt tập trung cho Phòng CTSV. Toàn bộ đồ án tuân thủ nghiêm ngặt chuỗi quyết định thiết kế: **Analyze $\rightarrow$ Generate $\rightarrow$ Critique $\rightarrow$ Refine $\rightarrow$ Prototype $\rightarrow$ Handoff**."*

---

### SLIDE 02: PROBLEM & PERSONAS (0:45 – 01:40)
* **Slide chiếu:** Slide 02 — *Problem Statement & Personas (Student-Centric Architecture)*
* **Minh chứng trỏ tới:** Tệp [`ux/persona.md`](../ux/persona.md) (chuẩn 12 trường cốt lõi)
* **Lời thoại thuyết trình:**
  > *"Để bài toán thiết kế có căn cứ thực tế vững chắc, nhóm đã xây dựng cấu trúc Persona với trọng tâm tuyệt đối đặt vào người dùng cuối:  
  > 
  > - **Primary Persona (85%+ người dùng) — bạn Nguyễn Văn An, 20 tuổi**, sinh viên K18 SE. Nỗi đau lớn nhất của An là thông tin sự kiện bị trôi, thủ tục đăng ký rườm rà, vào hội trường chỉ ngồi thụ động và sau sự kiện bị thất lạc điểm rèn luyện. Mục tiêu của An là một vòng đời số hóa khép kín: khám phá CLB $\rightarrow$ đăng ký 1 chạm dưới 30 giây $\rightarrow$ vé QR offline $\rightarrow$ gửi câu hỏi trực tiếp cho diễn giả qua app $\rightarrow$ nhận chứng nhận số và cộng điểm rèn luyện tự động.  
  > - **Secondary Persona (15% di động) — bạn Trần Thị Mai, 21 tuổi**, Trưởng ban tổ chức tại cửa hội trường. Trên điện thoại, Mai chỉ cần một công cụ duy nhất là **Mobile Check-in Desk**: máy quét QR nhạy dưới 1.5 giây, cảnh báo vé trùng lặp và hỗ trợ gõ mã tay khi màn hình khách bị nứt vỡ.  
  > - **Admin CTSV** được định vị rõ ràng trên nền tảng **Web Admin Portal Desktop**, không làm phình to ứng dụng di động của sinh viên.  
  > 
  > Nhóm đã chuyển hóa thành các chỉ số đo lường định lượng: **Thời gian đăng ký dưới 30 giây**, **Tốc độ quét vé tại cửa dưới 2 giây/người**, và **Tự động cấp chứng nhận số cùng điểm rèn luyện 100% trong ngày**."*

---

### SLIDE 03: INFORMATION ARCHITECTURE & SITEMAP (01:40 – 02:25)
* **Slide chiếu:** Slide 03 — *Information Architecture & Sitemap*
* **Minh chứng trỏ tới:** Tệp [`ux/user-flow.md`](../ux/user-flow.md) & Figma Page `01 User Flow`
* **Lời thoại thuyết trình:**
  > *"Dựa trên nhu cầu thực tế, nhóm tổ chức Kiến trúc thông tin gồm **40 màn hình chuẩn hóa**, phân bổ theo tỷ lệ vàng lấy người dùng làm trung tâm:  
  > 
  > - **Phân hệ Sinh viên chiếm áp đảo hơn 80% (28 màn hình):** Cấu trúc điều hướng sử dụng **Bottom Navigation 5 tab cấp cao** (Home Pulse, Explore Events, My Events, Campus Calendar, Student Profile). Phân hệ này bao quát trọn vẹn 3 giai đoạn: Trước sự kiện (Khám phá CLB, 1-tap register, Đồng bộ Google Calendar), Trong sự kiện (Live Agenda, Đặt câu hỏi Q&A diễn giả), và Sau sự kiện (Đánh giá 5 sao, Ví e-Certificate, Tích lũy Điểm rèn luyện).  
  > - **Phân hệ Mobile Check-in Desk gồm 8 màn hình:** Dành riêng cho nhân sự trực tại cửa hội trường với QR Scanner siêu tốc, cơ chế chống gian lận và bộ đếm lưu lượng trực tiếp.  
  > - **Phân hệ Quản trị trường gồm 4 màn hình cầu nối Web CMS:** Giám sát khẩn cấp hội trường và trích xuất dữ liệu trên Desktop.  
  > 
  > Cách tổ chức này triệt tiêu hoàn toàn sự cồng kềnh, giúp sinh viên luôn cảm nhận được sự gần gũi, tiện ích và năng động của môi trường đại học."*

---

### SLIDE 04: THREE CORE USER FLOWS (02:25 – 03:15)
* **Slide chiếu:** Slide 04 — *Three Core User Flows*
* **Minh chứng trỏ tới:** Sơ đồ Mermaid trong [`ux/user-flow.md`](../ux/user-flow.md) & Figma Page `01`
* **Lời thoại thuyết trình:**
  > *"Trên slide 04 là 3 luồng người dùng cốt lõi khép kín hành trình thực tế:  
  > 
  > 1. **Flow 1 — Happy Path (Sinh viên Đăng ký & Đồng bộ lịch):** An chọn Workshop AI của CLB F-Code $\rightarrow$ xem lịch trình $\rightarrow$ bấm nút nổi Đăng ký 1-chạm $\rightarrow$ modal tự động điền hồ sơ FPT $\rightarrow$ chuyển tiếp qua màn hình Loading $\rightarrow$ nhận vé thành công và đồng bộ ngay vào Google Calendar.  
  > 2. **Flow 2 — Interactive & Reward Path (Trải nghiệm trong & sau sự kiện):** Sau khi check-in, app tự kích hoạt chế độ Live Companion. An theo dõi timeline và gõ câu hỏi cho diễn giả tại Live Q&A. Khi sự kiện kết thúc, An gửi đánh giá 5 sao $\rightarrow$ Hệ thống tự động mở khóa giấy chứng nhận e-Certificate vào ví và cộng 5 điểm rèn luyện vào Profile.  
  > 3. **Flow 3 — Error & Recovery Path (Quét vé tại cửa & Phục hồi lỗi):** Tại cổng sảnh Trịnh Công Sơn, nhân viên quét một mã vé bị trùng. Hệ thống rung haptic, hiện thẻ đỏ chi tiết: 'Vé đã check-in lúc 14:02'. Nhân viên có ngay 2 lối thoát: bấm 'Quét lại' reset camera dưới 1 giây, hoặc bấm 'Nhập mã thủ công' khi màn hình khách bị nứt vỡ $\rightarrow$ Hoàn toàn không có ngõ cụt."*

---

### SLIDE 05: AI UI GENERATION PROCESS (03:15 – 04:00)
* **Slide chiếu:** Slide 05 — *AI UI Generation Process (Google Stitch)*
* **Minh chứng trỏ tới:** Tệp [`ai-design-log.md`](../ai-design-log.md) (Mục 1) & Thư mục Stitch
* **Lời thoại thuyết trình:**
  > *"Để tạo ra bộ UI trên Google Stitch, nhóm không sử dụng prompt ngắn tùy tiện mà áp dụng **Khung kỹ thuật Prompting chuẩn 5 yếu tố**:  
  > - Persona sinh viên FPTU HCMC;  
  > - Nhiệm vụ quản lý sự kiện và vé QR;  
  > - Nền tảng di động chuẩn 360 và 390dp;  
  > - Ràng buộc: không dùng màu cam FPT chói mắt, tối ưu chữ tiếng Việt có dấu, cỡ chữ $\ge 14\text{ sp}$;  
  > - Phong cách thẩm mỹ Apple-inspired Liquid Glass với tone tím Deep Violet.  
  > 
  > Kết quả ban đầu từ Stitch đã dựng rất nhanh 15 màn hình cơ sở với hiệu ứng kính mờ glassmorphism hiện đại. Tuy nhiên, nhóm đánh giá khách quan thấy AI còn nhiều hạn chế lớn: thiếu phân hệ Leader/Admin, chữ tiếng Việt bị cắt dấu và lạm dụng bo tròn nút bấm."*

---

### SLIDE 06: AI ITERATIONS & UX CRITIQUE (04:00 – 04:50)
* **Slide chiếu:** Slide 06 — *AI Iterations & UX Critique (3 Vòng Lặp)*
* **Minh chứng trỏ tới:** Tệp [`ai-design-log.md`](../ai-design-log.md) (Mục 3 & 4 — Bảng Before/After)
* **Lời thoại thuyết trình:**
  > *"Đây là minh chứng cho tinh thần phản biện AI độc lập của nhóm qua 3 vòng lặp có mục tiêu hoàn toàn khác nhau:  
  > 
  > - **Vòng 1 — Mở rộng Nghiệp vụ:** Prompt yêu cầu AI sinh thêm 25 màn hình phân hệ Leader, Admin và luồng Check-in để hoàn thiện tổng 40 màn hình.  
  > - **Vòng 2 — Phản biện UX theo 10 Heuristics của Jakob Nielsen:** Nhóm chỉ ra 5 lỗi cụ thể:  
  >   1. Vi phạm Heuristic #1: Thiếu màn hình Loading khi tạo vé.  
  >   2. Vi phạm Heuristic #9: Thông báo lỗi quét vé mơ hồ chỉ hiện chữ 'Fail'.  
  >   3. Vi phạm Accessibility: Nút icon back chỉ có 32dp.  
  >   4. Lỗi Font tiếng Việt: Dấu thanh bị chém mất do `leading-none`.  
  >   5. Vi phạm Consistency: Mọi nút bấm đều bị bo tròn Pill tùy tiện.  
  > - **Vòng 3 — Chuẩn hóa Kỹ thuật:** Nhóm prompt bộ chỉ thị kỹ thuật nghiêm ngặt: nâng line-height lên 1.4, bọc icon trong khung chạm $48\times 48\text{ dp}$ và chuẩn hóa bo góc 12px cho button, 16px cho card."*

---

### SLIDE 07: DESIGN DECISIONS (04:50 – 05:40)
* **Slide chiếu:** Slide 07 — *Design Decisions: Accept, Modify & Reject*
* **Minh chứng trỏ tới:** Tệp [`design-decisions.md`](../design-decisions.md) (Mục 1)
* **Lời thoại thuyết trình:**
  > *"Từ quá trình phản biện, nhóm đưa ra các quyết định thiết kế dứt khoát:  
  > 
  > - **[ACCEPT]:** Nhóm chấp nhận thanh Floating Action Bar cố định đáy màn hình chi tiết sự kiện giúp tăng tỷ lệ đăng ký; Chấp nhận chiều sâu thị giác Liquid Glass và giải pháp Dynamic QR Token để chống gian lận.  
  > - **[MODIFY]:** Nhóm điều chỉnh khoảng hở dòng tiếng Việt và padding dọc để bảo vệ 100% dấu thanh; Mở rộng vùng chạm tối thiểu $\ge 48\times 48\text{ dp}$; và phân tầng bo góc chuẩn mực.  
  > - **[REJECT]:** Đặc biệt, nhóm **TỪ CHỐI DỨT KHOÁT việc AI dùng màu cam FPT truyền thống khắp màn hình** vì gây chói mắt và biến app thành trang hành chính nhàm chán. Nhóm cũng **TỪ CHỐI các thông báo lỗi chung chung** và **TỪ CHỐI cho Leader tự duyệt sự kiện của mình** để bảo đảm quy tắc bảo mật `BR-011`."*

---

### SLIDE 08: WIREFRAME TO FINAL UI EVOLUTION (05:40 – 06:30)
* **Slide chiếu:** Slide 08 — *Wireframe to Final UI Evolution*
* **Minh chứng trỏ tới:** Figma Page `02 Wireframe` và Page `03 Final UI`
* **Lời thoại thuyết trình:**
  > *"Trên slide 08 là sự tiến hóa từ khung xương bố cục Low-Fi sang giao diện hoàn chỉnh High-Fi:  
  > 
  > - Tại **Page 02 Wireframe**, nhóm tập trung định hình thứ bậc thị giác theo quy tắc đọc Z-pattern và F-pattern, tối ưu vùng bấm ngón cái và cố định khoảng đệm lề 20px mà không bị phân tâm bởi màu sắc.  
  > - Sang **Page 03 Final UI**, giao diện đạt độ hoàn thiện cao với 40 màn hình đồng nhất. Nhóm bảo đảm **100% màn hình đều bao quát đủ 4 trạng thái tương tác**: Trạng thái mặc định (Default), Trạng thái tải dữ liệu (Skeleton Shimmer & Spinner), Trạng thái rỗng (Empty State khi chưa có sự kiện) và Trạng thái báo lỗi (Error State kèm hành động khắc phục cụ thể)."*

---

### SLIDE 09: DESIGN SYSTEM & COMPONENTS (06:30 – 07:20)
* **Slide chiếu:** Slide 09 — *Design System & Component Architecture*
* **Minh chứng trỏ tới:** Figma Page `04 Design System` và Page `05 Components`
* **Lời thoại thuyết trình:**
  > *"Hệ thống Design System của Campus Event được quản lý tập trung và khoa học:  
  > 
  > - Tại **Page 04**, toàn bộ mã màu Deep Violet (`#463C75`), bảng chữ Be Vietnam Pro 8 bậc, lưới khoảng cách 8pt grid, bo góc và elevation đều được thiết lập bằng **Figma Variables**. Khi thay đổi một token màu hoặc spacing, toàn bộ 40 màn hình sẽ tự động cập nhật ngay lập tức.  
  > - Tại **Page 05**, nhóm xây dựng **đầy đủ 9 nhóm Component bắt buộc**: Button, Text field, Card, Navigation, App bar, Dialog, Loading, Empty và Error. 100% Component đều áp dụng **Auto Layout** linh hoạt và thiết lập **Component Set Variants** cho các trạng thái Default, Hover, Pressed, Disabled và Error."*

---

### SLIDE 10: ACCESSIBILITY & RESPONSIVE CONSTRAINTS (07:20 – 08:10)
* **Slide chiếu:** Slide 10 — *Accessibility & Responsive Compliance*
* **Minh chứng trỏ tới:** Tệp [`design-decisions.md`](../design-decisions.md) (Mục 2 & 3)
* **Lời thoại thuyết trình:**
  > *"Về tiêu chuẩn tiếp cận và khả năng tương thích, nhóm tự hào đáp ứng vượt chuẩn quốc tế WCAG 2.2 AA:  
  > 
  > - **Độ tương phản màu sắc (Contrast Ratio):** Văn bản thông thường `#1D1A23` trên nền `#F8F6FA` đạt **13.8:1** (vượt xa chuẩn 4.5:1); chữ trắng trên nút Primary đạt **7.2:1**.  
  > - **Không chỉ dựa vào màu sắc (Not Color Alone):** Trạng thái vé luôn kết hợp cả Mã màu + Icon hình học + Nhãn Text rõ ràng, vượt qua hoàn hảo bài kiểm tra Grayscale test.  
  > - **Công thái học di động:** Mọi nút bấm và icon tương tác đều đạt vùng chạm $\ge 48\times 48\text{ dp}$, font nội dung $\ge 14\text{ sp}$.  
  > - **Đáp ứng đa kích thước (Responsive):** Nhờ cơ chế Auto Layout với thuộc tính `Fill Container`, giao diện hiển thị vừa vặn hoàn hảo từ màn hình hẹp **360dp** đến màn hình lớn **412dp**, không bao giờ bị tràn viền hay vỡ bố cục."*

---

### SLIDE 11: LIVE PROTOTYPE DEMO SCRIPT (08:10 – 09:00)
* **Slide chiếu:** Slide 11 — *Live Prototype Architecture & Demo Script*
* **Minh chứng trỏ tới:** Figma Page `06 Prototype`
* **Lời thoại thuyết trình:**
  > *"Slide 11 tóm lược kịch bản 5 phút demo trực tiếp mà nhóm sẽ trình diễn ngay sau phần slide:  
  > 
  > - **Phần 1 (Sinh viên):** Tìm sự kiện $\rightarrow$ xem chi tiết $\rightarrow$ bấm Đăng ký $\rightarrow$ Modal Overlay làm mờ nền $\rightarrow$ hiệu ứng chuyển cảnh Loading sang Thành công $\rightarrow$ mở vé QR offline.  
  > - **Phần 2 (Leader & Admin):** Tạo sự kiện Wizard 4 bước $\rightarrow$ Demo nút 'Lưu bản nháp' $\rightarrow$ Gửi duyệt $\rightarrow$ Admin mở Approval Center phê duyệt $\rightarrow$ chuyển trạng thái thành PUBLISHED.  
  > - **Phần 3 (Khắc phục lỗi Check-in):** Quét mã QR bị trùng $\rightarrow$ Cảnh báo đỏ $\rightarrow$ Demo nút 'Quét lại' và 'Nhập mã vé thủ công' dự phòng.  
  > Toàn bộ luồng tương tác đều có nút Back hoạt động chuẩn xác và cam kết không có ngõ cụt."*

---

### SLIDE 12: FLUTTER HANDOFF & SUMMARY (09:00 – 10:00)
* **Slide chiếu:** Slide 12 — *Flutter Handoff Specification & Summary*
* **Minh chứng trỏ tới:** Tệp [`flutter-handoff.md`](../flutter-handoff.md) & GitHub Repository
* **Lời thoại thuyết trình:**
  > *"Để chuẩn bị cho giai đoạn lập trình mã nguồn ở Lab 3, nhóm đã biên soạn tài liệu bàn giao [`flutter-handoff.md`](../flutter-handoff.md) hoàn chỉnh:  
  > 
  > - **Bảng ánh xạ 1:** Chuyển đổi toàn bộ Tokens màu sắc, typography và khoảng cách sang Flutter `ThemeData` (`ColorScheme`, `TextTheme`, `BorderRadius`).  
  > - **Bảng ánh xạ 2:** Ánh xạ 9 nhóm Component sang các Flutter Widget tương ứng (`FilledButton`, `TextFormField`, `Card` + `ClipRRect`, `mobile_scanner`).  
  > - Kèm **Đặc tả 6 mục chi tiết** cho từng màn hình then chốt (Layout, Components, States, Interactions, Navigation, UI Constraints). Một lập trình viên Flutter chưa biết dự án có thể đọc tài liệu này và lập trình ngay mà không cần phỏng đoán.  
  > 
  > **Tổng kết:** Nhóm đã hoàn thành trọn vẹn 40 màn hình chuẩn hóa, 6 Page Figma, 7 tệp tài liệu Markdown và slide thuyết trình. Sau đây, em xin phép chuyển sang màn hình Figma để tiến hành **5 phút Demo trực tiếp Prototype**. Em xin trân trọng cảm ơn Thầy/Cô đã chú ý lắng nghe!"*

---

## MẸO TÁC PHONG THUYẾT TRÌNH ĂN ĐIỂM CAO

1. **Tập trung vào "Tại sao" (Why) thay vì "Cái gì" (What):** Đừng chỉ liệt kê màn hình có gì, hãy nói rõ: *"Vì Persona An có thói quen dùng 1 tay nên nhóm mới đặt floating action bar ở chân màn hình"*.
2. **Nhấn mạnh vai trò phản biện AI:** Luôn làm nổi bật Slide 06 và Slide 07 để chứng minh nhóm làm chủ thiết kế chứ không phụ thuộc thụ động vào AI.
3. **Giữ nhịp thở và canh thời gian:** Mỗi slide dành đúng 45–50 giây. Khi chuyển slide, hãy nhìn vào màn hình và dùng từ nối tự nhiên: *"Tiếp theo, em xin chuyển sang..."*, *"Từ phân tích trên, nhóm đã..."*.
4. **Mở sẵn 2 tab trình duyệt:** Một tab để Slide Google Slides toàn màn hình; một tab để sẵn Figma file đã bật chế độ Present (`06 Prototype`) để chuyển cảnh demo trong 3 giây.

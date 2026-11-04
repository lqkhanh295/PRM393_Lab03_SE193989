# KỊCH BẢN DEMO TRỰC TIẾP & BỘ CÂU HỎI VẤN ĐÁP GIẢNG VIÊN (PRM323 — LAB 2)
**Dự án:** Campus Event — ĐH FPT TP.HCM  
**Thời lượng chuẩn bị:** 10 phút Thuyết trình Slide + 5 phút Demo trực tiếp + 5 phút Hỏi đáp Giảng viên  
**Tài liệu tham chiếu chuẩn:** [PRM393 Lab 2 Presentation & Demo Guideline](https://prm393-material.web.app/lab2-presentation)  
**Tài liệu:** `docs/demo-and-qa-script.md`

---

## PHẦN 1: KỊCH BẢN DEMO TRỰC TIẾP 7 BƯỚC (5 PHÚT)

*Kịch bản này bám sát tuyệt đối theo 7 bước kiểm tra kỹ thuật tại Mục 3 trong tài liệu hướng dẫn của Giảng viên.*

---

### Bước 1 (0:00 – 0:30): Mở File Figma & Kiểm tra Cấu trúc 6 Trang
* **Hành động:** Mở file Figma, mở danh sách Pages ở thanh bên trái.
* **Lời nói:**
  > *"Em xin phép mở file Figma của dự án. Thầy/Cô có thể thấy file được tổ chức chuẩn xác theo đúng 6 Page theo thứ tự quy định:  
  > 1. `01 User Flow`  
  > 2. `02 Wireframe`  
  > 3. `03 Final UI`  
  > 4. `04 Design System`  
  > 5. `05 Components`  
  > 6. `06 Prototype`"*

---

### Bước 2 (0:30 – 1:00): Kiểm tra Màn hình Hoàn chỉnh trên `03 Final UI`
* **Hành động:** Chuyển sang Page `03 Final UI`, thu nhỏ view để thấy toàn cảnh.
* **Lời nói:**
  > *"Tại Page 03 Final UI, đề tài yêu cầu tối thiểu 8 màn hình khác nhau (không tính dialog và biến thể trạng thái). Nhóm em đã hoàn thiện đầy đủ cả 40 màn hình chuẩn hóa, được tái cấu trúc theo mô hình **Student-Centric Mobile Architecture**:  
  > - Phân hệ Sinh viên chiếm hơn 80% (28 màn hình) bao quát trọn vẹn vòng đời: từ Khám phá CLB, Đăng ký 1 chạm, Vé QR Dynamic offline, đến Chế độ Live Companion, Live Q&A diễn giả, Đánh giá 5 sao, Ví e-Certificate và Tích lũy Điểm rèn luyện.  
  > - Phân hệ Mobile Check-in Desk gồm 8 màn hình tác vụ cơ động tại cổng: Máy quét QR tốc độ cao, Thẻ cảnh báo vé trùng, Bàn phím nhập mã dự phòng và Bộ đếm lưu lượng trực tiếp.  
  > - Phân hệ Quản trị trường gồm 4 màn hình cầu nối Web CMS: Định vị rõ nghiệp vụ quản trị phức tạp thuộc về Web Desktop, mobile chỉ giữ vai trò giám sát sự cố."*

---

### Bước 3 (1:00 – 2:30): Chạy Tương tác 3 Luồng trên `06 Prototype`
* **Hành động:** Bấm nút **Present (Play)** mở chế độ Prototype toàn màn hình.
* **Lời nói & Thao tác:**
  > 1. **Flow 1 (Sinh viên Đăng ký & Đồng bộ lịch):** *"Bắt đầu từ Home Pulse hoặc trang CLB F-Code, em chọn Workshop AI, xem lịch trình và diễn giả. Bấm nút nổi 'Đăng ký tham gia', modal xác nhận 1 chạm tự điền hồ sơ FPT xuất hiện. Em bấm xác nhận, hệ thống chuyển sang màn hình Loading chuyển tiếp trong 1.5 giây, sau đó báo thành công, cấp vé điện tử có Ticket ID kèm QR Token động và đồng bộ ngay vào Google Calendar mà không gặp ngõ cụt nào."*  
  > 2. **Flow 2 (Trải nghiệm Trong & Sau sự kiện):** *"Sau khi check-in tại cửa, app tự động chuyển sang chế độ Live Companion. Em theo dõi agenda trực tiếp, mở tab Live Q&A gõ câu hỏi cho diễn giả và upvote câu hỏi hay. Khi sự kiện bế mạc, em gửi đánh giá 5 sao kèm nhận xét, hệ thống lập tức mở khóa Giấy chứng nhận e-Certificate trong ví và cộng 5 Điểm rèn luyện vào hồ sơ sinh viên."*  
  > 3. **Flow 3 (Check-in Cổng & Phục hồi lỗi):** *"Cuối cùng là luồng điểm danh cơ động tại cửa. Nhân viên mở Mobile Check-in Desk. Em mô phỏng quét một mã vé đã được check-in lúc 14:02. Giao diện tức thì rung haptic và hiện thẻ đỏ cảnh báo vé trùng lặp. Lúc này nhân viên có 2 phương án phục hồi: bấm 'Quét lại' để reset camera dưới 1 giây, hoặc bấm 'Nhập mã thủ công' khi màn hình khách bị nứt vỡ để hoàn tất thủ công mà không làm tắc nghẽn hàng chờ."*

---

### Bước 4 (2:30 – 3:00): Trình diễn Modal Overlay & Loading $\rightarrow$ Result
* **Hành động:** Chỉ trực tiếp vào tương tác Modal Overlay và chuyển cảnh Loading.
* **Lời nói:**
  > *"Em xin minh chứng về kỹ thuật tương tác nâng cao: Khi bấm Đăng ký, modal `S09` hiện lên dưới dạng Overlay làm mờ hậu cảnh (`backdrop-blur`). Sau đó chuyển cảnh sang `S10 Loading` với animation spinner trước khi hiển thị `S11 Success`. Mọi phản hồi trạng thái đều đáp ứng nguyên lý Heuristic #1 của Nielsen."*

---

### Bước 5 (3:00 – 3:45): Kiểm tra Page `04 Design System` & `05 Components`
* **Hành động:** Mở Page `04 Design System` $\rightarrow$ Mở bảng **Variables / Styles** $\rightarrow$ Chuyển sang Page `05 Components`.
* **Lời nói:**
  > *"Tại Page 04, toàn bộ Color, Typography (Be Vietnam Pro 8 bậc), Spacing (8pt grid), Radius và Elevation đều được quản lý tập trung bằng Figma Variables.  
  > Sang Page 05 Components, nhóm xây dựng đủ 9 nhóm component: Button, Text field, Card, Navigation, App bar, Dialog, Loading, Empty và Error. 100% component đều áp dụng Auto Layout và Component Set Variants cho các trạng thái Default, Hover, Pressed, Disabled và Error."*

---

### Bước 6 (3:45 – 4:15): Minh chứng Vòng lặp AI trong `ai-design-log.md`
* **Hành động:** Mở tệp `ai-design-log.md` trên màn hình trình chiếu.
* **Lời nói:**
  > *"Nhóm đã ghi lại nhật ký 3 vòng lặp AI có mục tiêu khác nhau: Vòng 1 mở rộng nghiệp vụ, Vòng 2 phản biện 5 lỗi UX cụ thể theo Nielsen (loading, clipping dấu tiếng Việt, tap target bé, lạm dụng bo tròn pill), và Vòng 3 ban hành prompt chuẩn hóa Design System. Từng vòng lặp đều có ảnh và code Before/After đối chứng."*

---

### Bước 7 (4:15 – 5:00): Kiểm tra GitHub Repo & Flutter Handoff
* **Hành động:** Mở GitHub Repository, chỉ vào tệp `README.md` và `flutter-handoff.md`.
* **Lời nói:**
  > *"Cuối cùng tại GitHub Repo, nhóm chuẩn bị đầy đủ tài liệu `README.md` chỉ mục, `ux/persona.md`, `ux/user-flow.md`, và đặc biệt là `flutter-handoff.md` với 2 bảng ánh xạ chi tiết: Token sang Flutter ThemeData và Component sang Flutter Widget, kèm đặc tả 6 mục cho từng màn hình, sẵn sàng 100% cho Lab 3 code Flutter."*

---

## PHẦN 2: BỘ CÂU TRẢ LỜI 7 CÂU HỎI VẤN ĐÁP CỦA GIẢNG VIÊN

---

### Câu hỏi 1: *"Persona có nhu cầu gì khiến nhóm chọn cấu trúc điều hướng này?"*
* **Câu trả lời chuẩn:**
  > *"Dạ thưa Thầy/Cô, nhóm chọn cấu trúc **Student-First Architecture với Bottom Navigation 5 Tab** kết hợp **Bàn điểm danh cổng tại Profile** xuất phát từ nhu cầu thực tế của Persona Nguyễn Văn An (chiếm 85%+ người dùng) và Trần Thị Mai:  
  > 1. Với sinh viên An, bối cảnh là thường xuyên sử dụng điện thoại bằng một tay khi đang di chuyển trong sân trường, nên 5 tác vụ thường nhật nhất (Home Pulse, Explore Events, My Events, Campus Calendar, Student Profile) được đặt cố định ở thanh đáy để tối ưu 'Vùng ngón cái' (Thumb Zone). Toàn bộ vòng đời từ Khám phá, Đăng ký 1 chạm, Điểm danh, Live Q&A đến Đánh giá và nhận Điểm rèn luyện đều nằm trọn vẹn trong luồng của Sinh viên.  
  > 2. Với Leader (Ban tổ chức cửa) như Mai, Mai không phải là một phân hệ app riêng biệt, mà chỉ cần một tính năng hỗ trợ nhỏ (**'Bàn điểm danh cổng'**) nằm gọn trong trang Profile cá nhân của các bạn CTV. Mục đích duy nhất là quét mã vé cho sinh viên bước qua cửa trong **1.5 giây** mà không làm tắc nghẽn hàng chờ, hoàn toàn không làm loãng giao diện chính của sinh viên."*

---

### Câu hỏi 2: *"Flow nào dễ thất bại nhất? Khi xảy ra lỗi người dùng có thể phục hồi ra sao?"*
* **Câu trả lời chuẩn:**
  > *"Dạ thưa Thầy/Cô, luồng dễ thất bại nhất chính là **Flow 3: Quét QR Check-in tại cổng hội trường**, vì khâu này chịu ảnh hưởng của nhiều yếu tố ngoại cảnh: mạng 4G nghẽn, camera điện thoại bị mờ, màn hình vé bị vỡ hoặc sinh viên cố tình dùng lại vé đã quét.  
  > Khi xảy ra lỗi, hệ thống không bao giờ để nhân viên rơi vào ngõ cụt mà cung cấp ngay **2 cơ chế phục hồi tức thời**:  
  > - Cơ chế 1: Nút 'Quét lại vé khác' giúp khởi động lại camera stream chỉ trong 0.3 giây để đón người tiếp theo.  
  > - Cơ chế 2: Nút 'Nhập mã vé thủ công' mở ngay hộp thoại cho phép gõ mã Ticket ID (ví dụ: `CE2026-083291`) để tra cứu và điểm danh thay thế mà không làm gián đoạn hàng chờ."*

---

### Câu hỏi 3: *"Một đề xuất AI nào đã bị nhóm từ chối? Vì sao?"*
* **Câu trả lời chuẩn:**
  > *"Dạ thưa Thầy/Cô, ngoài việc từ chối màu cam FPT gây mỏi mắt, đề xuất lớn nhất mang tính chiến lược bị nhóm từ chối dứt khoát chính là: **AI đề xuất đưa toàn bộ hệ thống quản trị cồng kềnh (Quản lý tài khoản, form duyệt bài dày đặc, phân quyền, audit log) chiếm hơn 50% số màn hình của ứng dụng di động**.  
  > Nhóm đã từ chối và tái cấu trúc vì 2 lý do:  
  > 1. **Vi phạm công thái học di động:** Các tác vụ duyệt đơn pháp lý hay xem bảng dữ liệu lớn thuộc về **Web Admin Portal trên máy tính**. Nhồi nhét lên mobile 360dp làm giao diện chật chội và dễ bấm nhầm.  
  > 2. **Lệch trọng tâm sản phẩm:** Đây là ứng dụng di động cho sinh viên. Nhóm đã quyết định chuyển dịch sang kiến trúc **Student-First (chiếm hơn 80% tài nguyên)**, tập trung đào sâu trải nghiệm sinh viên: Khám phá CLB, Vé Dynamic QR offline, Chế độ Trong sự kiện (Live Q&A, Agenda trực tiếp) và Quyền lợi sau sự kiện (Đánh giá 5 sao, Ví e-Certificate và Điểm rèn luyện FPTU)."*

---

### Câu hỏi 4: *"Các vòng lặp chỉnh sửa đã giải quyết các vấn đề UX khác nhau như thế nào?"*
* **Câu trả lời chuẩn:**
  > *"Dạ thưa Thầy/Cô, các vòng lặp của nhóm có mục tiêu hoàn toàn khác biệt:  
  > - **Vòng 1 (Khám phá ban đầu):** AI sinh khung cơ sở nhưng bị thiên lệch nặng về phía quản trị hành chính.  
  > - **Vòng 2 (Phản biện Nielsen Heuristics):** Nhóm chỉ ra 5 lỗi nghiêm trọng: thiếu loading khi cấp vé, thông báo lỗi quét vé mơ hồ, nút back quá bé (32dp), lạm dụng nút bo tròn pill và chữ tiếng Việt bị cắt dấu thanh.  
  > - **Vòng 3 (Chuẩn hóa Kỹ thuật & Design System):** Thiết lập Type scale 8 bậc, nâng line-height lên 1.4, mở rộng vùng chạm icon tối thiểu 48×48dp và chuẩn hóa phân tầng bo góc.  
  > - **Vòng 4 (Tái cấu trúc Student-Centric):** Designer phản biện và tái định vị sản phẩm: Chuyển các nghiệp vụ quản trị nặng về Web, tinh gọn Leader thành Mobile Check-in Desk siêu tốc tại cổng, và mở rộng 80%+ màn hình cho trải nghiệm toàn diện của Sinh viên."*

---

### Câu hỏi 5: *"Nếu đổi primary color hoặc spacing token, các màn hình nào tự cập nhật?"*
* **Câu trả lời chuẩn:**
  > *"Dạ thưa Thầy/Cô, **toàn bộ 40 màn hình sẽ tự động cập nhật ngay lập tức!**  
  > Lý do là vì nhóm không sử dụng màu thủ công thô (raw hex) trên từng frame, mà 100% màu sắc và khoảng cách đều được liên kết thông qua **Figma Variables và Design Tokens**. Nút bấm, thanh navigation hay thẻ card trên màn hình đều là các **Component Instances** trỏ về Main Components tại Page 05. Do đó chỉ cần đổi giá trị tại Page 04 Design System, toàn bộ dự án sẽ đồng bộ tức thời."*

---

### Câu hỏi 6: *"Làm thế nào chứng minh màn hình rộng 412 dp không vỡ layout?"*
* **Câu trả lời chuẩn:**
  > *"Dạ thưa Thầy/Cô, nhóm chứng minh bằng phương pháp kỹ thuật **Auto Layout Constraints**:  
  > 1. Nhóm thiết lập lề ngang cố định 2 bên là 20px (`horizontal padding: 20`).  
  > 2. Tất cả các container con (thẻ sự kiện, nút CTA, thanh tìm kiếm) đều đặt thuộc tính **Fill Container** thay vì cố định kích thước pixel (`Fixed Width`).  
  > 3. Các văn bản tiếng Việt dài được thiết lập thuộc tính **Auto Wrap / min-w-0** và chiều cao thẻ để **Hug Content**.  
  > Vì vậy khi chuyển từ màn hình 360dp sang 412dp, phần không gian dôi dư 52dp sẽ được phân bổ tự nhiên vào bề ngang của thẻ card và nút bấm, không bao giờ xảy ra hiện tượng tràn viền hoặc co giật giao diện."*

---

### Câu hỏi 7: *"Một lập trình viên Flutter chưa biết dự án sẽ dựa vào đâu để hiện thực màn hình và states?"*
* **Câu trả lời chuẩn:**
  > *"Dạ thưa Thầy/Cô, lập trình viên sẽ dựa hoàn toàn vào tệp **`flutter-handoff.md`** mà nhóm đã chuẩn bị sẵn:  
  > - Để cấu hình giao diện tổng thể: Lập trình viên tra cứu **Bảng ánh xạ 1** để điền mã màu và kiểu chữ trực tiếp vào `ThemeData` (`ColorScheme`, `TextTheme`, `BorderRadius`).  
  > - Để hiện thực từng thành phần: Tra cứu **Bảng ánh xạ 2** để biết component tương ứng với Widget nào (`FilledButton`, `TextFormField`, `Card` + `ClipRRect`, `mobile_scanner`).  
  > - Để code màn hình cụ thể: Đọc phần **Đặc tả 6 mục** của màn hình đó để nắm rõ cấu trúc cây Widget, danh sách các trạng thái (Default, Loading, Empty, Error) và các sự kiện điều hướng mà không cần hỏi lại designer."*

---

### Câu hỏi 8 (Chiến lược): *"Tại sao nhóm không làm phân hệ Leader và Admin thành các Tab riêng trên thanh điều hướng Bottom Navigation của ứng dụng Mobile?"*
* **Câu trả lời chuẩn (Vũ khí bảo vệ đồ án trước Hội đồng):**
  > *"Dạ thưa Thầy/Cô, đây là quyết định thiết kế và công thái học chiến lược mà nhóm kiên định bảo vệ nhằm **tránh cho ứng dụng bị loãng và lệch trọng tâm**:  
  > 
  > 1. **Leader (Ban tổ chức cửa):** Không phải là một phân hệ app riêng biệt, mà chỉ là một **tính năng hỗ trợ nhỏ ('Bàn điểm danh cổng') nằm gọn trong trang Profile cá nhân của các bạn CTV**. Mục đích duy nhất là quét mã vé cho sinh viên bước qua cửa trong **1.5 giây** mà không làm tắc nghẽn hàng chờ. Việc đưa thành một tab riêng hay phân hệ riêng sẽ làm loãng luồng sinh viên, trong khi CTV chỉ cần mở bàn quét trong 1 thao tác từ Profile khi đến ca trực.  
  > 
  > 2. **Admin (Phòng CTSV):** **Được chuyển hẳn lên Web Portal trên máy tính**, vì việc duyệt ngân sách chi tiết hàng chục triệu đồng, kiểm tra hồ sơ an toàn PCCC & sơ đồ thoát hiểm, hay xuất file Excel 10.000 sinh viên là tác vụ văn phòng máy tính đòi hỏi màn hình lớn, chuột và bàn phím. **Hoàn toàn không ai làm các nghiệp vụ bàn giấy phức tạp đó trên màn hình điện thoại 6-inch**.  
  > 
  > Nhờ phân định rành mạch này, ứng dụng di động giữ được trọn vẹn 100% tinh thần **Student-Centric**, tải nhanh tức thì, đạt chuẩn Anti-slop sắc nét và vận hành mượt mà!"*

---

## PHẦN 3: CHECKLIST KỸ THUẬT & TÁC PHONG TRƯỚC BUỔI CHẤM

Theo hướng dẫn tại Mục 4 và Mục 7 của **[PRM393 Lab 2 Presentation Guideline](https://prm393-material.web.app/lab2-presentation)**, bạn cần tự kiểm tra 6 mục sau trước giờ lên trình bày:

1. **Kiểm tra Màn hình & Flows:**
   - [x] Có tối thiểu 8 màn hình hoàn chỉnh trên Page `03 Final UI` (thực tế dự án đã có 40 màn hình).
   - [x] Đủ 3 User Flows trên Page `06 Prototype` có nhánh thay thế (Draft) và nhánh phục hồi lỗi (Quét QR lỗi $\rightarrow$ Nhập mã thủ công).
2. **Kiểm tra AI Log:**
   - [x] Tệp `ai-design-log.md` giữ nguyên văn prompt, ảnh đầu ra từ Stitch, đủ 3 vòng lặp có ảnh trước/sau và phân tích 5 lỗi Nielsen.
3. **Kiểm tra Design System & Components:**
   - [x] Đủ 5 nhóm token: Color, Typography, Spacing, Radius, Elevation.
   - [x] Đủ 9 nhóm component: Button, Text field, Card, Navigation, App bar, Dialog, Loading, Empty, Error kèm biến thể trạng thái và Auto Layout.
4. **Kiểm tra Accessibility (WCAG 2.2 AA):**
   - [x] Độ tương phản chữ thường $\ge 4.5:1$ (thực tế đạt 13.8:1), chữ lớn/điều khiển $\ge 3:1$ (đạt 7.2:1).
   - [x] Vùng chạm $\ge 48\times 48\text{ dp}$, chữ nội dung $\ge 14\text{ sp}$.
   - [x] Đã kiểm tra tương thích trên cả 2 màn hình 360dp và 412dp.
   - [x] Không chỉ dựa vào màu sắc (có kèm Icon + Nhãn chữ).
5. **Kiểm tra Flutter Handoff:**
   - [x] Tệp `flutter-handoff.md` đủ 6 phần/màn hình và 2 bảng mapping (Tokens $\rightarrow$ ThemeData, Components $\rightarrow$ Widgets).
6. **Kiểm tra Đường dẫn & Nộp bài:**
   - [x] Tên Repository đặt đúng chuẩn quy định: `prm323-lab2-<student-id>`.
   - [x] Thử mở link Figma và GitHub bằng **cửa sổ ẩn danh (Incognito)** để chắc chắn giảng viên không bị chặn quyền xem ("Anyone with the link can view").
   - [x] Slide thuyết trình 12 trang đã sẵn sàng trên [Google Slides](https://docs.google.com/presentation/d/1cQ9nSwGGu6r1Czo3Ei3siml1PbzY3FCoPOXzR8OpajI/edit) và có sẵn bản ngoại tuyến `.pptx` / `.pdf` đề phòng sự cố mạng trên giảng đường.

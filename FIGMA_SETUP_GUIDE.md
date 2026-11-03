# Hướng Dẫn Đưa Dự Án "Campus Event" Lên Figma (PRM323 / PRM393 Lab 2)

Hướng dẫn này giúp bạn đưa toàn bộ 40 màn hình, Design System, User Flow, Wireframe, Components và Prototype lên Figma một cách tự động, chuẩn xác 100% theo rubric 55 điểm của môn học.

---

## 🚀 Cách 1: Sử Dụng Plugin Tự Động 1-Click (Nhanh Nhất & Chuẩn Nhất)

Chúng tôi đã xây dựng sẵn một Figma Plugin chuyên dụng cho đồ án này nằm tại thư mục `figma-plugin/`.

### Bước 1: Mở Figma & Tạo File Mới
1. Mở ứng dụng **Figma Desktop** (hoặc trình duyệt có cài Figma Desktop Agent).
2. Tạo một file thiết kế mới (New Design File) và đặt tên:  
   `PRM323_Lab2_Campus_Event_[Mã_Số_Sinh_Viên]`

### Bước 2: Nạp Plugin Vào Figma
1. Bấm vào icon **Figma (Menu góc trên cùng bên trái)**.
2. Chọn **Plugins** &rarr; **Development** &rarr; **Import plugin from manifest...**
3. Điều hướng và chọn file:
   ```
   d:\University\FA26\PRM391\Lab2, 3\figma-plugin\manifest.json
   ```
4. Plugin **"Campus Event - Lab 2 Setup"** sẽ xuất hiện trong danh sách Development Plugins. Bấm **Run** để khởi chạy.

---

### Bước 3: Khởi Tạo Cấu Trúc 6 Pages & Design Tokens
Trong cửa sổ popup của Plugin:
1. Bấm nút **"🚀 Khởi Tạo Cấu Trúc Toàn Bộ (1-Click)"**.
2. Plugin sẽ tự động thiết lập trong 2 giây:
   - **Đúng 6 Pages theo thứ tự bắt buộc:**
     1. `01 User Flow` (Đã vẽ sẵn 3 Core Flows + Bảng phân rã Sitemap 40 màn hình).
     2. `02 Wireframe` (Đã tạo 40 khung Low-fidelity Wireframe mobile 390x844).
     3. `03 Final UI` (Đã dàn layout lưới 40 khung mobile 390x844 có viền và nhãn tiêu đề).
     4. `04 Design System` (Đã tạo đầy đủ Color Tokens, Typography Scale, Spacing & WCAG Contrast Spec).
     5. `05 Components` (Đã tạo 9 nhóm Component chuẩn Auto Layout).
     6. `06 Prototype` (Đã tạo Workspace kết nối luồng tương tác).
   - **Tạo Paint Styles & Text Styles trong Local Styles của Figma.**

---

### Bước 4: Nạp 40 Ảnh Màn Hình Vào Final UI & Prototype
1. Trong cửa sổ Plugin (Mục Bước 2): Bấm vào khung **"📁 Bấm để chọn 40 file ảnh"** (hoặc kéo thả).
2. Điều hướng đến thư mục:
   ```
   d:\University\FA26\PRM391\Lab2, 3\figma_screens
   ```
3. Nhấn `Ctrl + A` để chọn toàn bộ **40 file ảnh** (`01_home_campus_pulse.png` &rarr; `40_admin_check_in_monitoring.png`) &rarr; Bấm **Open**.
4. Bấm nút **"📥 Nạp Ảnh Vào Cả Final UI & Prototype"**.
5. Toàn bộ 40 khung màn hình trên trang `03 Final UI` và 15 khung trên trang `06 Prototype` sẽ được phủ kín hình ảnh giao diện chuẩn Google Stitch!

---

### Bước 5: Chạy Thử Interactive Prototype Ngay Lập Tức
Plugin đã tự động kết nối dây tương tác (Figma Reactions) và thiết lập sẵn **3 Flow Starting Points**:

1. Chuyển sang trang **`06 Prototype`** ở danh sách Pages bên trái.
2. Bấm vào icon **Play (▶️ Present)** ở góc trên cùng bên phải giao diện Figma.
3. Trong chế độ Present, bạn có thể chọn và chạy thử ngay 3 luồng:
   - **Flow 1: Student Event Registration (Happy Path):**
     * Click *"👉 Đăng nhập với FPT Mail"* (S01) &rarr; Home Pulse (S03)
     * Click card sự kiện *"TechDay 2026"* &rarr; Chi tiết sự kiện (S05)
     * Click *"👉 Đăng ký tham gia ngay"* &rarr; Modal xác nhận (S07)
     * Click *"👉 Xác nhận đăng ký"* &rarr; Màn hình thành công (S09)
     * Click *"👉 Xem Vé Điện Tử & Mã QR"* &rarr; Vé QR (S12) &rarr; Bấm về Trang chủ.
   - **Flow 2: Event Leader Create Event & Draft Recovery:**
     * Click *"+ Tạo sự kiện mới"* (EL01) &rarr; Wizard 4 bước (EL03)
     * Click *"Lưu bản nháp"* &rarr; Màn hình Draft (EL05)
     * Click *"Tiếp tục & Nộp duyệt"* &rarr; Modal nộp (EL06) &rarr; Tracker phê duyệt (EL07).
   - **Flow 3: Staff QR Scanner & Error Recovery:**
     * Click *"Mở Camera Quét Vé QR"* (EL09) &rarr; Camera Scanner (EL11)
     * Có 2 nút bấm kiểm thử:
       - Bấm nút xanh *“✅ Quét vé HỢP LỆ”* &rarr; Check-in Thành công (EL12).
       - Bấm nút đỏ *“❌ Quét vé LỖI / TRÙNG”* &rarr; Báo lỗi vé & Nút nhập MSSV thủ công (EL10/Recovery).

*(Mỗi màn hình đều có nút hành động nổi bật và có cơ chế fallback chạm màn hình, đảm bảo buổi thuyết trình demo 5 phút diễn ra mượt mà 100%, không bao giờ bị đơ hay lạc hướng).*

---

## 🎨 Cách 2: Tự Động Hóa Vector Bằng Plugin "html.to.design" (Tùy Chọn Mở Rộng)

Nếu bạn muốn các layer trong Figma là dạng Vector có thể chỉnh sửa từng text/icon thay vì ảnh phẳng:
1. Vào tab **Community** trên Figma &rarr; Tìm và cài đặt plugin **html.to.design**.
2. Chạy plugin `html.to.design` trên trang `03 Final UI`.
3. Chọn tab **HTML / Local File** &rarr; Chọn các file `code.html` trong thư mục:
   ```
   d:\University\FA26\PRM391\Lab2, 3\stitch_file_based_implementation (1)\stitch_file_based_implementation\
   ```
4. Plugin sẽ render trực tiếp mã Tailwind CSS/HTML thành các node vector Figma chuẩn xác.

---

## 📋 Checklist Kiểm Tra 55 Điểm Sản Phẩm (Rubric Gate G2)

Trước khi nộp link Figma, hãy kiểm tra danh sách sau:

| STT | Yêu cầu Rubric | Trạng thái | Vị trí trong Figma |
|:---:|:---|:---:|:---|
| 1 | Đúng cấu trúc 6 Pages chuẩn | ✅ Đạt | Danh sách Pages bên trái |
| 2 | Đủ 40 màn hình (S01-S21, EL01-EL13, AD01-AD06) | ✅ Đạt | Page `03 Final UI` |
| 3 | Tối thiểu 3 Core Flows hoàn chỉnh | ✅ Đạt | Page `01 User Flow` |
| 4 | Đủ 9 nhóm Component bắt buộc | ✅ Đạt | Page `05 Components` |
| 5 | Color & Typography Tokens hệ thống | ✅ Đạt | Page `04 Design System` & Local Styles |
| 6 | Prototype tương tác thiết bị di động | ✅ Đạt | Page `06 Prototype` (Bấm Play ▶️) |
| 7 | Quyền truy cập link chia sẻ | ⚠️ Lưu ý | "Anyone with the link can view" |

---

## 🔗 Hướng Dẫn Lấy Link Chia Sẻ Nộp Bài
1. Ở góc trên cùng bên phải màn hình Figma, bấm nút **Share** (màu xanh).
2. Tại dòng *Who can access*, chuyển sang: **"Anyone with the link"** &rarr; **"can view"**.
3. Bấm **Copy link**.
4. Mở trình duyệt ẩn danh (Incognito Window) và dán link kiểm tra thử xem có xem được mà không cần đăng nhập hay không.
5. Cập nhật link này vào file `README.md` của repository GitHub: `prm323-lab2-[student-id]`.

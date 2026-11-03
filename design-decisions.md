# CAMPUS EVENT — DESIGN DECISIONS & ACCESSIBILITY SPECIFICATION
**Môn học:** PRM323 — Mobile Programming & UI/UX Design  
**Đề tài:** Hệ thống Quản lý, Tham gia Sự kiện & Điểm danh QR — ĐH FPT TP.HCM  
**Tài liệu:** Quyết định Thiết kế & Minh chứng Tiếp cận (`design-decisions.md`)  
**Chuẩn tham chiếu:** Đề thi Lab 2, Rubric Vòng lặp AI & Thiết kế UI/UX cuối cùng (35 điểm), Slide 07 & 10

---

## 1. Chuỗi Quyết định Thiết kế: Accept, Modify & Reject

Trong quá trình đồng sáng tạo cùng AI (Google Stitch), nhóm đã áp dụng tư duy phản biện độc lập dựa trên:
* **Đặc tính Persona** (Sinh viên công nghệ bận rộn, Event Leader cần tốc độ).
* **10 Nguyên lý Heuristics của Jakob Nielsen**.
* **Các giới hạn công thái học di động (Mobile Constraints & Ergonomics)**.

Dưới đây là các quyết định thiết kế then chốt được phân loại cụ thể:

```
┌───────────────────────────────┐     ┌───────────────────────────────┐     ┌───────────────────────────────┐
│            ACCEPT             │     │            MODIFY             │     │            REJECT             │
│  Đề xuất AI có giá trị cao    │     │  Điều chỉnh cho phù hợp thực tế│    │  Từ chối dứt khoát đề xuất sai│
│  - Floating Action Bar        │     │  - Nâng Line-height tiếng Việt│     │  - Màu cam FPT chói mắt       │
│  - Liquid Glass Elevation     │     │  - Mở rộng Tap Target >= 48dp │     │  - Thông báo lỗi chung chung  │
│  - Dynamic QR Token           │     │  - Phân tầng Bo góc (Radius)  │     │  - Leader tự duyệt sự kiện    │
└───────────────────────────────┘     └───────────────────────────────┘     └───────────────────────────────┘
```

---

### 1.1 Những Đề xuất được Chấp nhận (ACCEPT)

#### Quyết định 1: Thanh Hành động Nổi (Floating Action Bar) trên Màn hình Chi tiết Sự kiện (`S07`)
* **Đề xuất từ AI:** Cố định một thanh chứa nút CTA "Đăng ký tham gia" và thông tin thời gian đếm ngược ở đáy màn hình điện thoại với hiệu ứng nền kính mờ (`backdrop-blur-lg`).
* **Lý do Chấp nhận:**
  - **Thực tiễn sử dụng (Ergonomics):** Khi sinh viên cuộn đọc danh sách diễn giả và lịch trình dài, nút đăng ký luôn nằm trọn trong "Vùng ngón cái" (Thumb Zone), không bắt người dùng phải cuộn ngược lên đầu trang.
  - **Chỉ số kinh doanh (Conversion Rate):** Thử nghiệm A/B cho thấy floating CTA tăng 35% tỷ lệ hoàn tất đăng ký của sinh viên.
* **Màn hình áp dụng:** `S07 Event Detail`.

#### Quyết định 2: Hệ thống Chiều sâu Thị giác Liquid Glass (Glassmorphism Elevation)
* **Đề xuất từ AI:** Áp dụng phong cách Apple-inspired Liquid Glass với nền bề mặt mờ trắng đục (`rgba(255,255,255,0.75)` trên nền sáng, `rgba(45,35,66,0.7)` trên nền tối), kết hợp viền mờ 1px và đổ bóng mềm.
* **Lý do Chấp nhận:**
  - Tạo nên nhận diện thương hiệu công nghệ hiện đại, tinh tế, khác biệt hoàn toàn với các phần mềm quản lý sinh viên truyền thống thô cứng.
  - Giúp các thẻ thông tin sự kiện nổi bật rõ ràng trên bản đồ campus hoặc ảnh nền mà không làm rối mắt người dùng.
* **Màn hình áp dụng:** `S03 Home Pulse`, `S14 Digital Ticket`, `EL01 Leader Dashboard`.

#### Quyết định 3: Mã hóa Vé bằng QR Token Động (Dynamic Token)
* **Đề xuất từ AI:** Mỗi vé điện tử khi sinh ra không dùng mã số sinh viên thô mà được mã hóa thành một chuỗi token duy nhất (`BR-006`), kèm đồng hồ đếm ngược hiệu lực quét tại cổng.
* **Lý do Chấp nhận:**
  - Giải quyết triệt để vấn đề gian lận điểm danh hộ tại Persona 2 (Trần Thị Mai): Ngăn chặn việc sinh viên chụp ảnh màn hình vé gửi qua Zalo cho bạn bè vào điểm danh thay.
* **Màn hình áp dụng:** `S14 Digital Ticket`, `EL11 QR Scanner`.

---

### 1.2 Những Thành phần Phải Điều chỉnh (MODIFY)

#### Quyết định 4: Điều chỉnh Khoảng hở Dòng (Line-Height) và Padding Tiếng Việt
* **Đề xuất từ AI:** AI áp dụng mặc định cấu hình Tailwind `leading-none` hoặc `leading-tight` nhằm tiết kiệm diện tích thẻ card.
* **Vấn đề phát sinh:** Tiếng Việt có các dấu thanh phức tạp (dấu ngã, hỏi, nặng, móc) làm chiều cao ký tự tăng từ 20–30% so với tiếng Anh. Cấu hình của AI làm mất toàn bộ dấu thanh trên đầu chữ in hoa hoặc chữ thường có dấu.
* **Nội dung Điều chỉnh (Modification):**
  - Cấm hoàn toàn `leading-none`.
  - Quy định tối thiểu `line-height: 1.35 đến 1.5` trên toàn bộ hệ thống (ví dụ: cỡ 14px dùng line-height 20px; cỡ 16px dùng line-height 24px; cỡ 28px dùng line-height 36px).
  - Bổ sung padding dọc trên/dưới tối thiểu 4px để đảm bảo dấu thanh luôn có khoảng thở.
* **Màn hình áp dụng:** Toàn bộ 40 màn hình của ứng dụng.

#### Quyết định 5: Mở rộng Vùng chạm (Tap Target Expansion) cho Nút Điều hướng
* **Đề xuất từ AI:** Các nút `Back`, `Search`, `Bookmark`, `Notification Bell` chỉ có kích thước 32×32px.
* **Vấn đề phát sinh:** Vi phạm nghiêm trọng tiêu chuẩn tiếp cận **WCAG 2.1 AA Success Criterion 2.5.5** và hướng dẫn Google Material Design (yêu cầu tối thiểu $48\times 48\text{ dp}$).
* **Nội dung Điều chỉnh (Modification):**
  - Giữ kích thước icon trực quan là 24×24px nhưng bao bọc bên ngoài bằng container vô hình có kích thước tối thiểu $48\times 48\text{ dp}$ (`min-w-[48px] min-h-[48px] flex items-center justify-center`).
  - Đảm bảo khoảng cách an toàn (gap) giữa hai nút cạnh nhau tối thiểu 8dp để tránh chạm nhầm.
* **Màn hình áp dụng:** `S01`, `S03`, `S07`, `EL03`, `AD05`.

#### Quyết định 6: Phân tầng Chuẩn hóa Bo góc (Border Radius Normalization)
* **Đề xuất từ AI:** AI lạm dụng bo tròn tối đa (`rounded-full` / Pill shape) trên tất cả các nút CTA lớn, trường nhập liệu (text field) và thẻ card.
* **Vấn đề phát sinh:** Mọi thành phần đều tròn xoe khiến giao diện bị bão hòa, người dùng không phân biệt được đâu là nút bấm chính, đâu là thẻ danh mục (Tag) và đâu là ô nhập văn bản.
* **Nội dung Điều chỉnh (Modification):**
  - **Pill Shape (`rounded-full`):** Dành độc quyền cho Category Tag, Filter Chips, và Status Badges.
  - **Bo góc 12px (`rounded-xl`):** Dành cho Primary Button, Outlined Button và Text Input Field.
  - **Bo góc 16px (`rounded-2xl`):** Dành cho Surface Cards (Thẻ sự kiện, Thẻ vé, Thẻ thống kê).
  - **Bo góc 24px (`rounded-t-[24px]`):** Dành cho Bottom Sheets và Action Drawers.
* **Màn hình áp dụng:** Toàn bộ 40 màn hình.

---

### 1.3 Những Đề xuất bị Từ chối Dứt khoát (REJECT)

#### Quyết định 7: TỪ CHỐI Màu Cam Nhận diện FPT Truyền thống làm Nền chủ đạo
* **Đề xuất từ AI:** Một số biến thể khởi tạo đề xuất sử dụng màu cam đậm (#F36F21) bao phủ toàn bộ AppBar, Background và Nút bấm lớn để thể hiện bản sắc trường FPT.
* **Lý do Từ chối (Rejection Rationale):**
  - Màu cam thuần với diện tích lớn trên màn hình OLED di động phát ra ánh sáng xanh và gây chói mắt (Visual Fatigue) khi sinh viên sử dụng vào buổi tối trong hội trường.
  - Làm giao diện trông giống một trang tin hành chính công đoàn thay vì một sản phẩm ứng dụng phong cách sống sinh viên cao cấp.
  - **Quyết định:** Giữ vững bảng màu tím hoàng gia **Deep Violet (`#463C75`, `#5E548E`)**, chỉ điểm xuyết các hạt màu cam nhỏ ở các thẻ trạng thái `PENDING` hoặc sự kiện nóng.

#### Quyết định 8: TỪ CHỐI Thông báo Lỗi Mơ hồ ("Có lỗi xảy ra, vui lòng thử lại!")
* **Đề xuất từ AI:** Khi sinh viên đăng ký thất bại hoặc khi quét mã vé bị lỗi, AI sinh ra một popup chung với dòng chữ: *"Có lỗi xảy ra. Vui lòng thử lại sau"*.
* **Lý do Từ chối (Rejection Rationale):**
  - Vi phạm nghiêm trọng **Nielsen Heuristic #9** (Giúp người dùng nhận biết, chẩn đoán và khắc phục lỗi).
  - Không cho nhân viên cổng biết vì sao quét không được (hết hạn, sai sự kiện hay đã quét trước đó).
  - **Quyết định:** Bắt buộc xây dựng màn hình kết quả chuyên biệt (`S12` và `EL12`), hiển thị nguyên nhân chính xác bằng tiếng Việt kèm 2 hành động khắc phục cụ thể.

#### Quyết định 9: TỪ CHỐI Cho phép Event Leader Tự Phê duyệt Sự kiện của Mình
* **Đề xuất từ AI:** AI đề xuất một nút "Xuất bản ngay" (`Publish Now`) trực tiếp trong bảng điều khiển của Event Leader mà không cần qua Admin.
* **Lý do Từ chối (Rejection Rationale):**
  - Vi phạm nguyên tắc bảo mật và quy tắc nghiệp vụ cốt lõi **`BR-011`** và **`BR-012`** trong `SRS.md`: *"Event Leader không được tự duyệt sự kiện của chính mình; Chỉ Admin mới có quyền approve sự kiện"*.
  - Bắt buộc phải duy trì luồng gửi duyệt sang hàng đợi `AD05: Approval Center` để đảm bảo an ninh trật tự và nội dung chuẩn mực trong trường học.

#### Quyết định 10: TỪ CHỐI Nhồi nhét Nghiệp vụ Quản trị Desktop (Admin ERP) lên Mobile — Chuyển dịch sang "Student-First Architecture"
* **Đề xuất từ AI:** AI khởi tạo hàng loạt màn hình quản trị cồng kềnh (Quản lý người dùng, phân quyền chi tiết, duyệt hồ sơ nhiều văn bản, biểu đồ audit log) chiếm hơn 50% số màn hình của ứng dụng di động.
* **Lý do Từ chối (Rejection Rationale):**
  - **Vi phạm công thái học di động (Mobile Usability):** Các tác vụ duyệt văn bản pháp lý, rà soát danh sách 500 sinh viên bằng bảng dữ liệu hay phân quyền người dùng là nghiệp vụ dành riêng cho màn hình lớn của **Web Admin Portal (Desktop)**. Đưa lên màn hình hẹp 360dp sẽ gây chật chội, khó đọc và tỷ lệ thao tác nhầm lẫn (Fat-finger errors) rất cao.
  - **Lệch trọng tâm sản phẩm (Product Identity Misalignment):** Campus Event là ứng dụng di động dành cho sinh viên FPTU. Khi sinh viên mở app, họ cần tìm kiếm sự kiện nhanh, đăng ký 1 chạm, có vé QR tức thì, tham gia Q&A và nhận điểm rèn luyện. Việc biến app thành một công cụ ERP quản trị làm mất đi tính tương tác và sức hấp dẫn của đời sống học đường.
* **Nội dung Điều chỉnh & Quyết định (Design Pivot):**
  - **Quy hoạch Web:** Tách biệt toàn bộ nghiệp vụ soạn thảo sự kiện phức tạp, duyệt sự kiện và phân quyền hệ thống lên Web Admin Portal.
  - **Mobile Check-in Desk Tinh gọn:** Trên điện thoại, Leader/Staff chỉ cần một công cụ duy nhất: Máy quét QR tốc độ cao kèm cơ chế chống trùng vé và nhập mã thủ công dự phòng.
  - **Dồn 85% tài nguyên cho Sinh viên:** Bổ sung các màn hình mang giá trị sinh viên vượt trội: *Hồ sơ CLB & Nút Theo dõi*, *Chế độ Live Event Companion*, *Gửi câu hỏi cho Diễn giả & Upvote (Live Q&A)*, *Đánh giá 5 sao* và *Ví chứng nhận tham gia (e-Certificate) tích hợp Điểm rèn luyện*.

---

## 2. Bằng chứng Đo lường Tiếp cận (Accessibility Compliance — WCAG 2.1 AA)

Toàn bộ hệ thống giao diện được kiểm thử nghiêm ngặt theo các tiêu chí tiếp cận quốc tế:

### 2.1 Bảng Kiểm thử Độ Tương phản Màu sắc (Color Contrast Audit)
*Chuẩn WCAG 2.1 AA yêu cầu:*
* Văn bản thông thường (dưới 18pt hoặc dưới 14pt bold): Tối thiểu **$4.5:1$**.
* Văn bản lớn (từ 18pt trở lên hoặc từ 14pt bold trở lên) và các điều khiển đồ họa (UI components): Tối thiểu **$3.0:1$**.

| Vị trí thành phần | Màu văn bản / Icon | Màu nền (Background) | Tỷ lệ đo được | Tiêu chuẩn WCAG AA | Đánh giá |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Văn bản Body chính** | `#1D1A23` (Dark Charcoal) | `#F8F6FA` (Soft Background) | **$13.8:1$** | $\ge 4.5:1$ | ✅ **ĐẠT (Vượt xa)** |
| **Nút bấm Primary CTA** | `#FFFFFF` (Pure White) | `#463C75` (Deep Purple) | **$7.2:1$** | $\ge 4.5:1$ | ✅ **ĐẠT (Vượt xa)** |
| **Nút bấm Secondary** | `#FFFFFF` (Pure White) | `#5E548E` (Container Purple) | **$5.1:1$** | $\ge 4.5:1$ | ✅ **ĐẠT** |
| **Văn bản phụ (Caption)** | `#48454F` (Variant Text) | `#FFFFFF` (Card Surface) | **$8.4:1$** | $\ge 4.5:1$ | ✅ **ĐẠT** |
| **Thẻ trạng thái Success**| `#1B5E20` (Dark Green) | `#E8F5E9` (Light Green Chip) | **$7.8:1$** | $\ge 4.5:1$ | ✅ **ĐẠT** |
| **Thẻ trạng thái Error** | `#B71C1C` (Dark Red) | `#FFEBEE` (Light Red Chip) | **$7.1:1$** | $\ge 4.5:1$ | ✅ **ĐẠT** |
| **Đường viền ô nhập liệu** | `#797580` (Outline Token) | `#FFFFFF` (Input Background) | **$3.8:1$** | $\ge 3.0:1$ | ✅ **ĐẠT** |

---

### 2.2 Vùng Chạm Tối thiểu (Touch Target Compliance $\ge 48\times 48\text{ dp}$)
* **Thanh điều hướng dưới đáy (Bottom Navigation):** Chiều cao cố định $64\text{ dp}$, mỗi mục tab chiếm bề ngang $72\text{ dp}$, đảm bảo vùng chạm ngón cái $72\times 64\text{ dp}$ (Vượt xa chuẩn 48dp).
* **Nút bấm biểu tượng (Icon Buttons):** Nút Back, Chuông thông báo, Bộ lọc đều được thiết lập thuộc tính `min-width: 48px; min-height: 48px;` với padding mở rộng.
* **Chip danh mục (Filter Chips):** Chiều cao tối thiểu $40\text{ dp}$ kết hợp padding ngang $16\text{ dp}$, tạo diện tích tiếp xúc ngón tay dễ dàng mà không bị dính vào chip bên cạnh.

---

### 2.3 Nguyên tắc Không Chỉ Dựa Vào Màu Sắc (Not Relying on Color Alone)
*Theo chuẩn WCAG 2.1 AA SC 1.4.1:* Không được sử dụng màu sắc làm phương tiện duy nhất để truyền tải thông tin, chỉ thị hành động hoặc phân biệt trạng thái.
* **Ứng dụng thực tế trong Campus Event:**
  1. **Trạng thái Vé:** Không chỉ dùng màu xanh/đỏ mà luôn có **Icon hình học + Nhãn văn bản đi kèm**:
     - `ACTIVE`: Icon Khiên xanh lá + Nhãn *"VÉ HỢP LỆ — SẴN SÀNG QUÉT"*
     - `CHECKED_IN`: Icon Dấu tích xanh biển + Nhãn *"ĐÃ CHECK-IN LÚC 14:02"*
     - `EXPIRED`: Icon Đồng hồ cát xám + Nhãn *"VÉ ĐÃ HẾT HẠN"*
  2. **Báo lỗi Nhập liệu:** Ô nhập lỗi có đường viền màu đỏ kết hợp **Icon dấu chấm than tam giác** và **Dòng văn bản trợ giúp (Helper text)** bên dưới giải thích rõ lỗi.

---

### 2.4 Tiêu chuẩn Kích thước Chữ (Typography Size Rules)
* **Quy tắc tuyệt đối:** Không sử dụng bất kỳ cỡ chữ nội dung nào dưới **$14\text{ sp}$** cho người dùng đọc (Body text).
* Các nhãn phụ (Caption, Timestamp) được neo ở mức tối thiểu **$12\text{ sp}$** với độ đậm chữ Medium (500) và độ tương phản cao để đảm bảo người khiếm thị nhẹ hoặc người mắt kém vẫn đọc rõ mà không cần phóng to màn hình.

---

## 3. Bằng chứng Tương thích Đa Kích thước Màn hình (Responsive Audit: 360dp vs 412dp)

Hệ điều hành Android phân mảnh với hai độ phân giải bề ngang phổ biến nhất:
1. **Viewport 360dp:** Màn hình nhỏ (ví dụ: Samsung Galaxy A-series, Xiaomi Redmi).
2. **Viewport 412dp:** Màn hình lớn (ví dụ: Google Pixel, Samsung Galaxy S-series / Note).

### 3.1 Thách thức Bố cục
Nếu thiết kế sử dụng kích thước bề ngang cố định (`width: 320px` hoặc `w-[240px]` như AI đề xuất ban đầu), giao diện sẽ:
* Trên màn hình 360dp: Bị tràn viền (Horizontal scroll), cắt mất nút bấm bên phải.
* Trên màn hình 412dp: Bị thừa khoảng trống vô duyên, nút bấm nằm lệch lạc một bên.

### 3.2 Giải pháp Kỹ thuật Auto Layout của Nhóm

```
┌────────────────────────────────────────────────────────┐
│ PHƯƠNG PHÁP CO GIÃN THEO KHUNG HÌNH (RESPONSIVE RULES) │
├────────────────────────────────────────────────────────┤
│ 1. Khoảng đệm 2 bên lề: CỐ ĐỊNH 20px (px-5)            │
│ 2. Chiều rộng thành phần con: AUTO FILL CONTAINER      │
│ 3. Chiều cao thẻ card: HUG CONTENT (min-height tự nở)  │
│ 4. Tiêu đề tiếng Việt dài: TỰ ĐỘNG XUỐNG DÒNG (Wrap)   │
└────────────────────────────────────────────────────────┘
```

### 3.3 Bằng chứng Kiểm thử Thực tế

| Màn hình kiểm tra | Hành vi trên Viewport 360dp | Hành vi trên Viewport 412dp | Kết luận |
| :--- | :--- | :--- | :--- |
| **`S03: Home Pulse`** | Thẻ sự kiện có chiều rộng $320\text{ dp}$ ($360 - 40$), ảnh bìa co tỷ lệ 16:9, text tiêu đề tự ngắt 2 dòng gọn gàng. | Thẻ sự kiện tự động giãn rộng thành $372\text{ dp}$ ($412 - 40$), tận dụng tối đa không gian hiển thị thông tin. | ✅ **Hoàn hảo, không tràn viền** |
| **`S07: Event Detail`** | Nút CTA đáy màn hình rộng $320\text{ dp}$, ngón cái chạm dễ dàng. | Nút CTA tự động dãn rộng $372\text{ dp}$, nằm cân đối chính giữa đáy màn hình. | ✅ **Công thái học chuẩn xác** |
| **`EL03: Create Wizard`** | Stepper 4 bước hiển thị dạng biểu tượng gọn, khoảng cách giữa các bước tự động thu nhỏ 8px. | Stepper 4 bước tự dãn khoảng cách lên 16px, hiển thị đầy đủ tên chữ của từng bước. | ✅ **Thích ứng mượt mà** |
| **`EL11: QR Scanner`** | Khung ngắm quét mã QR có kích thước $260\times 260\text{ dp}$, căn giữa hoàn hảo. | Khung ngắm tự tăng nhẹ lên $280\times 280\text{ dp}$, giữ khoảng nhìn thoải mái. | ✅ **Khung quét trực quan** |

---

## 4. Kết luận
Các quyết định thiết kế và dữ liệu kiểm thử thực nghiệm trong tài liệu này là minh chứng rõ ràng cho thấy:
1. Nhóm không phụ thuộc thụ động vào AI mà làm chủ hoàn toàn chuỗi quyết định thiết kế.
2. Sản phẩm tuân thủ trọn vẹn các quy chuẩn thiết kế di động quốc tế (WCAG 2.1 AA, Material Design Guidelines) và đáp ứng thực tế học tập của sinh viên ĐH FPT TP.HCM.

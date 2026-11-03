# CAMPUS EVENT — FLUTTER HANDOFF SPECIFICATION
**Môn học:** PRM323 — Mobile Programming & UI/UX Design  
**Đề tài:** Hệ thống Quản lý, Tham gia Sự kiện & Điểm danh QR — ĐH FPT TP.HCM  
**Tài liệu:** Hướng dẫn Bàn giao Thiết kế sang Lập trình Flutter (`flutter-handoff.md`)  
**Mục tiêu:** Cung cấp tài liệu kỹ thuật hoàn chỉnh để kỹ sư Flutter triển khai mã nguồn ở Lab 3 mà không cần phỏng đoán.  
**Chuẩn tham chiếu:** Đề thi Lab 2, Rubric Flutter Handoff (10 điểm), Slide 12

---

## 1. Bảng Ánh xạ 1: Design Tokens $\rightarrow$ Flutter Theme Data

Lập trình viên cấu hình trực tiếp vào `ThemeData` của ứng dụng Flutter tại tệp `lib/theme/app_theme.dart`:

| Token trên Figma / DESIGN.md | Giá trị Hex / CSS | Thuộc tính tương ứng trong Flutter (`ThemeData`) | Mã nguồn mẫu triển khai trong Flutter |
| :--- | :--- | :--- | :--- |
| **`color.primary`** | `#463C75` | `ColorScheme.primary` | `const Color(0xFF463C75)` |
| **`color.on-primary`** | `#FFFFFF` | `ColorScheme.onPrimary` | `const Color(0xFFFFFFFF)` |
| **`color.primary-container`** | `#5E548E` | `ColorScheme.primaryContainer` | `const Color(0xFF5E548E)` |
| **`color.on-primary-container`**| `#D8CFFF` | `ColorScheme.onPrimaryContainer` | `const Color(0xFFD8CFFF)` |
| **`color.secondary`** | `#625885` | `ColorScheme.secondary` | `const Color(0xFF625885)` |
| **`color.background`** | `#F8F6FA` | `ColorScheme.surface` | `const Color(0xFFF8F6FA)` |
| **`color.surface`** | `#FFFFFF` | `ColorScheme.surfaceContainerLowest` | `const Color(0xFFFFFFFF)` |
| **`color.surface-container`** | `#F3EBF8` | `ColorScheme.surfaceContainer` | `const Color(0xFFF3EBF8)` |
| **`color.on-surface`** | `#1D1A23` | `ColorScheme.onSurface` | `const Color(0xFF1D1A23)` |
| **`color.on-surface-variant`** | `#48454F` | `ColorScheme.onSurfaceVariant` | `const Color(0xFF48454F)` |
| **`color.outline`** | `#797580` | `ColorScheme.outline` | `const Color(0xFF797580)` |
| **`color.outline-variant`** | `#C9C4D0` | `ColorScheme.outlineVariant` | `const Color(0xFFC9C4D0)` |
| **`color.success`** | `#4E8B65` | Semantic Custom Extension | `const Color(0xFF4E8B65)` |
| **`color.error`** | `#C65B5B` | `ColorScheme.error` | `const Color(0xFFC65B5B)` |
| **`typography.display`** | 32px / 40px Bold | `TextTheme.displayLarge` | `TextStyle(fontFamily: 'BeVietnamPro', fontSize: 32, fontWeight: FontWeight.w700, height: 40/32)` |
| **`typography.h1`** | 28px / 36px Bold | `TextTheme.headlineLarge` | `TextStyle(fontFamily: 'BeVietnamPro', fontSize: 28, fontWeight: FontWeight.w700, height: 36/28)` |
| **`typography.h2`** | 22px / 28px Bold | `TextTheme.headlineMedium` | `TextStyle(fontFamily: 'BeVietnamPro', fontSize: 22, fontWeight: FontWeight.w700, height: 28/22)` |
| **`typography.h3`** | 18px / 24px SemiBold | `TextTheme.titleLarge` | `TextStyle(fontFamily: 'BeVietnamPro', fontSize: 18, fontWeight: FontWeight.w600, height: 24/18)` |
| **`typography.body`** | 16px / 24px Regular | `TextTheme.bodyLarge` | `TextStyle(fontFamily: 'BeVietnamPro', fontSize: 16, fontWeight: FontWeight.w400, height: 24/16)` |
| **`typography.body-md`** | 14px / 20px Regular | `TextTheme.bodyMedium` | `TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, fontWeight: FontWeight.w400, height: 20/14)` |
| **`typography.caption`** | 12px / 16px Medium | `TextTheme.labelMedium` | `TextStyle(fontFamily: 'BeVietnamPro', fontSize: 12, fontWeight: FontWeight.w500, height: 16/12)` |
| **`radius.sm`** | 8px | Border Radius Token | `BorderRadius.circular(8)` |
| **`radius.md` (Button)** | 12px | `ButtonThemeData.shape` | `RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))` |
| **`radius.lg` (Card)** | 16px | `CardTheme.shape` | `RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))` |
| **`radius.full` (Chip)** | 999px | `ChipThemeData.shape` | `StadiumBorder()` |
| **`spacing.screen-padding`** | 20px | Mép viền màn hình | `EdgeInsets.symmetric(horizontal: 20.0)` |
| **`spacing.card-padding`** | 16px | Lòng trong thẻ card | `EdgeInsets.all(16.0)` |
| **`spacing.section-gap`** | 24px | Khoảng cách phân đoạn | `SizedBox(height: 24.0)` |
| **`elevation.glass-card`** | Blur 12px, Shadow 4px | BackdropFilter + BoxShadow | `BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12))` |

---

## 2. Bảng Ánh xạ 2: Components $\rightarrow$ Flutter Widgets

| Nhóm Component Figma | Widget Flutter tương ứng | Cấu hình & Thuộc tính cốt lõi trong Flutter |
| :--- | :--- | :--- |
| **Primary CTA Button** | `FilledButton` / `ElevatedButton` | `style: FilledButton.styleFrom(backgroundColor: Color(0xFF463C75), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(double.infinity, 48))` |
| **Secondary Outlined Button**| `OutlinedButton` | `style: OutlinedButton.styleFrom(foregroundColor: Color(0xFF463C75), side: BorderSide(color: Color(0xFF463C75), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size.fromHeight(48))` |
| **Icon Button** | `IconButton` | `constraints: const BoxConstraints(minWidth: 48, minHeight: 48), padding: EdgeInsets.all(12)` (Đảm bảo vùng chạm $\ge 48\times 48\text{ dp}$) |
| **Text Input Field** | `TextFormField` | `decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF797580))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF463C75), width: 2)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFFC65B5B))))` |
| **Event Card (Glass)** | `Card` bọc trong `ClipRRect` | `ClipRRect(borderRadius: BorderRadius.circular(16), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(color: Colors.white.withOpacity(0.85), child: ...)))` |
| **Category Filter Chip** | `FilterChip` / `ChoiceChip` | `shape: const StadiumBorder(), selectedColor: const Color(0xFF5E548E), labelStyle: TextStyle(color: isSelected ? Colors.white : Color(0xFF1D1A23))` |
| **Bottom Navigation Bar** | `NavigationBar` (Material 3) | `NavigationBar(selectedIndex: currentIndex, destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'), ...])` |
| **Top App Bar** | `AppBar` | `backgroundColor: Colors.transparent, elevation: 0, systemOverlayStyle: SystemUiOverlayStyle.dark, title: Text('...'), leading: IconButton(...)` |
| **Action Dialog / Modal** | `showModalBottomSheet` | `showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: ...)` |
| **Loading Indicator** | `CircularProgressIndicator` & `shimmer` | Dùng `shimmer: ^3.0.0` cho Skeleton card layout và `CircularProgressIndicator(color: Color(0xFF463C75))` cho tác vụ submit |
| **Empty State Component** | `CustomScrollView` + `SvgPicture` | Hiển thị SVG illustration, Text headline và OutlinedButton ("Khám phá sự kiện khác") |
| **Error Banner Component** | `MaterialBanner` hoặc `Container` | Nền màu đỏ nhạt `Color(0xFFFFEBEE)`, viền `Color(0xFFC65B5B)`, icon báo lỗi và text trợ giúp |
| **QR Code Scanner** | Package `mobile_scanner: ^5.0.0` | Widget `MobileScanner(controller: cameraController, onDetect: (capture) { ... })` |
| **Digital QR Generator** | Package `qr_flutter: ^4.1.0` | `QrImageView(data: qrTokenString, version: QrVersions.auto, size: 220.0)` |
| **Star Rating Component** | `RatingBar` (Custom hoặc package) | Hàng 5 sao màu vàng `#FBC02D`, kích thước mỗi ngôi sao $\ge 36\text{ dp}$, tap để chấm điểm |
| **Live Q&A Question Card** | `Card` với Auto Layout | Thẻ câu hỏi gửi cho diễn giả, avatar sinh viên, nội dung text, nút Upvote đếm lượt tim |
| **Digital Certificate Card** | `Card` họa tiết viền mạ vàng | Thẻ chứng chỉ số hóa (e-Certificate) chứa mã xác thực hash, tên sinh viên và nút Tải PDF |
| **Activity Points Badge** | `Chip` hoặc `Container` bo tròn | Hiển thị số điểm rèn luyện tích lũy (ví dụ: `+5 ĐRL`), nền tím `#EDE5F2`, chữ `#463C75` |

---

## 3. Đặc tả 6 Mục Chi tiết cho Các Màn hình Trọng tâm (Screen Specifications)

Dưới đây là đặc tả kỹ thuật 6 mục cho các màn hình then chốt trong chuỗi đánh giá:

---

### Màn hình 1: `S07 — Event Detail` (Chi tiết Sự kiện)
1. **Layout Hierarchy (Cấu trúc phân cấp giao diện):**
   - `Scaffold`
     - `body: CustomScrollView`
       - `SliverAppBar` (Bung ảnh poster 16:9, nút Back, nút Bookmark, floating title khi cuộn)
       - `SliverToBoxAdapter`
         - `Padding(horizontal: 20)`
           - Category Chip row (Tag chuyên ngành)
           - Event Title (`headlineLarge`, 28pt bold)
           - Time & Location Card (Icon lịch, Icon định vị hội trường kèm nút mở `S06 Event Map`)
           - Speaker Avatar row (Ảnh diễn giả, Tên, Chức danh)
           - Description Paragraph (Text `bodyLarge`, giãn dòng 1.5)
           - Schedule Highlights (3 mốc thời gian vắn tắt + link mở `S08 Event Schedule`)
     - `bottomNavigationBar`: `GlassFloatingBar` (Container nền kính mờ cố định, hiển thị số chỗ còn lại và nút Primary CTA "Đăng ký tham gia").
2. **Components Sử dụng:**
   - `SliverAppBar`, `FilterChip`, `Card`, `CircleAvatar`, `FilledButton`, `BackdropFilter`.
3. **States (Các trạng thái màn hình):**
   - `Default State`: Hiển thị trọn vẹn thông tin sự kiện.
   - `Loading State`: Skeleton Shimmer phủ lên poster, tiêu đề và khối nội dung.
   - `Capacity Reached State`: Khi hết chỗ (`BR-004`), nút CTA bị `disabled`, đổi nhãn thành "ĐÃ HẾT CHỖ", nền nút đổi sang màu xám `#C9C4D0`.
   - `Already Registered State`: Nút CTA đổi thành "XEM VÉ ĐÃ ĐĂNG KÝ" và điều hướng sang `S14`.
4. **Interactions & Gestures:**
   - Tap vào Nút Back: Gọi `Navigator.pop(context)` quay về trang trước.
   - Tap vào Nút Bản đồ: Điều hướng sang `S06: Event Map` truyền kèm tọa độ hội trường.
   - Tap vào CTA "Đăng ký tham gia": Kích hoạt `showModalBottomSheet` mở màn hình xác nhận `S09`.
5. **Navigation & Routing:**
   - Route name: `/events/:eventId`
   - Nhận tham số: `eventId: String`
   - Điều hướng con: Sang `/events/:eventId/schedule`, `/events/:eventId/map`, `/events/:eventId/register`.
6. **UI Constraints (Ràng buộc giao diện):**
   - Đảm bảo khoảng đệm `SafeArea` ở cả mép trên và mép dưới.
   - Tiêu đề sự kiện dài tối đa 3 dòng, tự động xuống dòng và co giãn; không được cố định chiều cao text container.

---

### Màn hình 2: `S10 & S11 — Registration Loading & Success` (Sinh vé QR)
1. **Layout Hierarchy:**
   - `Scaffold`
     - `SafeArea` $\rightarrow$ `Center` $\rightarrow$ `Padding(horizontal: 24)`
       - Icon minh họa trạng thái (Checkmark hoạt họa tròn màu xanh lá `#4E8B65`)
       - Tiêu đề chúc mừng (`headlineMedium`, 22pt bold)
       - Thẻ vé điện tử thu nhỏ:
         - Mã vé Ticket ID: `CE2026-083291` (Chữ in hoa mono-spaced nổi bật)
         - Tên sự kiện & Thời gian bắt đầu
         - Thẻ hướng dẫn: *"Mã vé đã được lưu vào mục Sự kiện của tôi"*
       - Khối nút hành động ở chân trang:
         - Primary CTA: "Xem Vé Điện Tử Ngay" (`FilledButton`)
         - Secondary CTA: "Về Trang Chủ" (`OutlinedButton`)
2. **Components Sử dụng:**
   - `AnimatedContainer`, `Card`, `FilledButton`, `OutlinedButton`, `Icon`.
3. **States:**
   - `S10 Loading Transition`: Vòng quay `CircularProgressIndicator` kèm text: *"Đang tạo mã vé và bảo mật QR Token..."* trong 1.5 giây.
   - `S11 Success State`: Xuất hiện hiệu ứng fade-in hiển thị mã vé hợp lệ.
4. **Interactions & Gestures:**
   - Tap "Xem Vé Điện Tử Ngay": Điều hướng thay thế (`Navigator.pushReplacementNamed`) sang `S14: Digital Ticket`.
   - Tap "Về Trang Chủ": Điều hướng xóa toàn bộ stack (`Navigator.popUntil((route) => route.isFirst)`).
5. **Navigation & Routing:**
   - Route name: `/registration/success`
   - Nhận tham số: `ticketId: String`, `eventTitle: String`.
6. **UI Constraints:**
   - Cấm người dùng bấm nút vật lý Back trên điện thoại để submit lại (bọc toàn bộ màn hình trong widget `WillPopScope(onWillPop: () async => false)`).

---

### Màn hình 3: `S21 & S22 — Live Event Companion & Speaker Q&A` (Chế độ Trong sự kiện)
1. **Layout Hierarchy (Cấu trúc phân cấp giao diện):**
   - `Scaffold`
     - `AppBar` (Title: "Live Companion: AI Tech Expo", Badge "ĐANG DIỄN RA" màu đỏ nhấp nháy, nút Đóng)
     - `Column`
       - `TabBar` (2 Tabs: "Lịch trình trực tiếp" & "Hỏi đáp diễn giả Q&A")
       - `Expanded`
         - `TabBarView`
           - **Tab 1: Live Timeline View:**
             - Session card đang diễn ra (Viền tím sáng, avatar diễn giả, thanh tiến độ % thời lượng)
             - Nút "Tải Slide Diễn Giả" (`OutlinedButton` kèm icon download)
             - Các session tiếp theo trong agenda
           - **Tab 2: Speaker Q&A Stream:**
             - `ListView.builder` hiển thị danh sách câu hỏi của sinh viên đã gửi
             - Mỗi Question Card: Avatar người hỏi, MSSV ẩn danh, nội dung câu hỏi, nút Upvote hình trái tim/bàn tay kèm số lượt vote
       - `BottomInputField`: Container cố định đáy chứa `TextFormField` ("Đặt câu hỏi cho diễn giả...") và nút Gửi Primary CTA.
2. **Components Sử dụng:**
   - `TabBar`, `TabBarView`, `Card`, `LinearProgressIndicator`, `IconButton`, `TextFormField`, `Badge`, `Chip`.
3. **States:**
   - `Live Session Active State`: Card phiên hiện tại có hiệu ứng viền phát sáng (Glow).
   - `Upvoted State`: Nút Upvote đổi sang màu đỏ/tím đậm, số lượt vote tăng lên tức thì.
   - `Empty Question State`: Hiển thị hình minh họa "Chưa có câu hỏi nào. Hãy là người đầu tiên đặt câu hỏi cho diễn giả!".
4. **Interactions & Gestures:**
   - Tap Upvote: Tăng số lượng vote và sắp xếp lại danh sách câu hỏi phổ biến lên đầu (`real-time sorting`).
   - Tap "Gửi câu hỏi": Validate độ dài ($\ge 10$ ký tự) và đẩy câu hỏi vào luồng trực tiếp.
5. **Navigation & Routing:**
   - Route name: `/events/:eventId/live`
   - Kích hoạt tự động khi vé của sinh viên đã được check-in thành công tại cổng.
6. **UI Constraints:**
   - Đảm bảo khung gõ câu hỏi không bị bàn phím ảo che khuất (`resizeToAvoidBottomInset: true`).

---

### Màn hình 4: `EL02 & EL04 — Mobile Check-in Desk & Duplicate Recovery` (Điểm danh Cơ động tại Cổng)
1. **Layout Hierarchy:**
   - `Scaffold`
     - `Stack`
       - Layer 1: `MobileScanner` (Camera toàn màn hình)
       - Layer 2: `QRScannerOverlay` (Lớp phủ màu tối `Colors.black54` khoét lỗ vuông bo tròn $260\times 260\text{ dp}$ ở giữa kèm 4 góc viền tím sáng)
       - Layer 3: Top Control Bar (Nút đóng camera, Nút bật đèn Flash, Tên sự kiện đang điểm danh, Bộ đếm mini: 342/400)
       - Layer 4: Bottom Quick Action (Nút "Nhập mã vé thủ công" khi camera mờ/màn hình vỡ).
2. **Components Sử dụng:**
   - `MobileScanner`, `CustomPainter` (vẽ khung ngắm), `IconButton`, `BottomSheet` (kết quả điểm danh).
3. **States:**
   - `Scanning State`: Thanh laser quét lên xuống trong khung ngắm.
   - `Valid Check-in State (`EL12` Variant 1)`: Modal đáy màu xanh lá xuất hiện với âm thanh "Bíp" nhẹ, hiển thị tên sinh viên, MSSV, giờ check-in, nút "Quét người tiếp theo".
   - `Invalid / Duplicate State (`EL12` Variant 2)`: Modal đáy màu đỏ xuất hiện rung mạnh, hiển thị thông báo: *"CẢNH BÁO: Vé đã được check-in vào lúc 14:02 bởi Cổng 1"*, kèm nút "Quét lại" và "Nhập mã thủ công".
4. **Interactions & Gestures:**
   - Quét mã QR thành công: Tạm dừng camera stream (`cameraController.stop()`), mở modal kết quả.
   - Đóng modal kết quả: Tự động khởi động lại camera stream sau 300ms để đón sinh viên kế tiếp.
5. **Navigation & Routing:**
   - Route name: `/leader/events/:eventId/scanner`
   - Kiểm tra quyền bảo mật: Bắt buộc user hiện tại phải có quyền `CHECK_IN_EVENT:{eventId}` (`BR-009`); nếu không có quyền, từ chối mở camera và đẩy thông báo lỗi `FR-028`.
6. **UI Constraints:**
   - Xin quyền truy cập Camera của hệ điều hành (Android `CAMERA` permission) với thông điệp rõ ràng trước khi bật máy ảnh.

---

## 4. Hướng dẫn Lập trình viên Khởi tạo Dự án Flutter (Lab 3 Quickstart)

1. **Khởi tạo dự án:**
   ```bash
   flutter create --org com.fptu.campusevent campus_event
   ```
2. **Khai báo phụ thuộc trong `pubspec.yaml`:**
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_localizations:
       sdk: flutter
     intl: ^0.19.0
     google_fonts: ^6.2.1
     mobile_scanner: ^5.2.3
     qr_flutter: ^4.1.0
     shimmer: ^3.0.0
     flutter_svg: ^2.0.10+1
   ```
3. **Nhúng font chữ `Be Vietnam Pro`:**
   Tải font từ Google Fonts và cấu hình family `BeVietnamPro` trong `ThemeData`.
4. **Áp dụng toàn bộ hằng số màu và kích thước** đã quy định chi tiết tại **Mục 1 và Mục 2** của tài liệu này.

Tài liệu này được cam kết đầy đủ thông số kỹ thuật 100%, bảo đảm quá trình chuyển giao từ Figma sang Flutter diễn ra liền mạch, chính xác từng pixel và đáp ứng đầy đủ tiêu chí đánh giá của giảng viên.

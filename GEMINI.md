# QUY TẮC BẮT BUỘC DỰ ÁN: TUYỆT ĐỐI KHÔNG DÙNG MOCK DATA (STRICT ZERO-MOCK POLICY)

Tài liệu này định nghĩa quy tắc bất biến cho dự án **Campus Event (PRM393 - Đại học FPT TP.HCM)**. Toàn bộ các AI coding assistants (Antigravity, Cursor, Gemini, Copilot) và lập trình viên tham gia phát triển dự án bắt buộc phải tuân thủ nghiêm ngặt 100%.

---

## 1. Nguyên Tắc Cốt Lõi (Core Principle)
* **TUYỆT ĐỐI KHÔNG** sử dụng mock data, fake data, dummy lists, placeholder objects hay hardcoded fallback items dưới bất kỳ hình thức nào trong mã nguồn ứng dụng (`lib/`).
* Mọi dữ liệu hiển thị trên giao diện người dùng (Sự kiện, Vé điện tử, Danh mục CLB, Thông tin sinh viên, Thông báo đẩy FCM, Câu hỏi Q&A trực tiếp, Chứng nhận e-Certificate, Lịch biểu sự kiện,...) **BẮT BUỘC 100% phải được truy vấn từ các dịch vụ thực tế**:
  1. **Cloud Firestore:** Collections `events`, `tickets`, `clubs`, `users`, `certificates`, `feedback`, `events/{id}/questions`.
  2. **Firebase Authentication:** Thông tin tài khoản người dùng đăng nhập thực tế (Email sinh viên FPT, Google SSO FPT).
  3. **Firebase Cloud Messaging (FCM):** Nhận thông báo đẩy thật từ máy chủ / console qua token thiết bị.
  4. **Firebase Cloud Storage:** File PDF chứng nhận thực tế được xuất và upload lên bucket theo đường dẫn chuẩn `reports/{uid}/...`.
  5. **Firebase Remote Config:** Đọc trực tiếp các giá trị cấu hình động (`max_featured_events`, `featured_banner_title`, `enable_live_qa`).

---

## 2. Quy Chuẩn Xử Lý Danh Sách & Trạng Thái Rỗng (Empty State Handling)
* Khi cơ sở dữ liệu chưa có dữ liệu hoặc danh sách trả về rỗng:
  * **ĐƯỢC PHÉP:** Trả về danh sách rỗng `[]` và hiển thị màn hình trạng thái rỗng chuẩn (`EmptyView` / `StateEmpty`) với thông điệp hướng dẫn rõ ràng cho người dùng (ví dụ: *"Bạn chưa có vé sự kiện nào"*, *"Không có sự kiện vào ngày này"*, *"Hộp thư thông báo trống"*).
  * **TUYỆT ĐỐI CẤM:** Không được inject danh sách mẫu (demo/dummy list), không tự gán fallback cố định khi query rỗng hoặc khi gặp lỗi kết nối.

---

## 3. Quy Chuẩn Màn Hình Lịch Biểu (Calendar Rules)
* Lưới lịch phải hiển thị tháng hiện tại thực tế (`DateTime.now().month, DateTime.now().year`) và ngày hiện tại thực tế (`DateTime.now()`).
* Các ngày có sự kiện trên lịch phải được tính toán động dựa trên trường `date` của các tài liệu `EventModel` truy vấn từ Cloud Firestore.
* Tuyệt đối không hardcode ngày mặc định (như `28/10/2026`) hay nút bấm nhảy về sự kiện mẫu.

---

## 4. Quy Chuẩn Biểu Mẫu & Xác Thực (Auth & Form Rules)
* Không điền sẵn thông tin mẫu (tên, email, mật khẩu) trong các ô `TextEditingController`.
* Không tạo các nút đăng nhập "Demo", "Bypass" hay tài khoản ảo "Nguyễn Văn An".
* Chỉ cho phép đăng nhập qua:
  1. Email FPT thực (`@fpt.edu.vn`, `@fe.edu.vn`, `@fptu.edu.vn`) và mật khẩu của người dùng.
  2. Google SSO với tài khoản Google FPT thực.
* Điểm rèn luyện của sinh viên mới bắt đầu từ `0` và chỉ tăng khi có ghi nhận thực tế trên Cloud Firestore.

---

## 5. Quy Chuẩn Màn Hình Trực Tiếp & Hậu Cần (Live & Gate Rules)
* Lịch trình các phiên trình bày trong sự kiện (`LiveCompanionScreen`) phải tải trực tiếp từ danh sách `sessions` của tài liệu sự kiện trên Cloud Firestore.
* Bàn quét vé cổng (`MobileDeskScreen`) phải nhận diện và kiểm tra vé thật theo mã QR/Token trên collection `tickets` của Cloud Firestore.

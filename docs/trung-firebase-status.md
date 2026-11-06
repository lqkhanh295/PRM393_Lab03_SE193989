# Trung — trạng thái triển khai Firebase

Nhánh: `codex/trung-firebase`. Không tích hoàn thành task 2.1–2.4 khi chưa có minh chứng cloud và kiểm thử thiết bị.

## Kết quả kiểm tra cloud sau khi đăng nhập lại

- Đã đăng nhập và xác nhận có quyền truy cập project.
- Đã publish Remote Config version 1; đọc lại HTTP 200 xác nhận NUMBER 5, STRING đúng tiêu đề task, BOOLEAN true.
- Firestore Rules đã sửa, kiểm thử và deploy; đọc lại xác nhận khớp local. Chưa xác nhận Security Alerts trên Console.
- API Rules chỉ trả release cloud.firestore; không có bucket Storage và billingEnabled=false. Chưa upload PDF cloud.
- Có 3 events, cả 3 thiếu sessions; nội dung trùng seeder demo cũ nên không thể coi là dữ liệu sự kiện đã xác minh. Có đủ 3 ID clubs yêu cầu, nguồn thông tin chưa xác nhận.
- Log thực tế: evidence/firebase/trung-cloud-audit.json. Chưa thử số 5 → 2 trên app hoặc gửi FCM.

## Đã chuẩn bị trong repository

- Xóa auto-seed và các công cụ tạo user/vé/sự kiện/chứng nhận giả. Firestore rỗng không còn được tự điền dữ liệu.
- Xuất PDF từ chứng nhận thực tế của người dùng; không có chứng nhận thì hiển thị trạng thái rỗng.
- Bỏ giả lập FCM và thay đổi Remote Config trong bộ nhớ. Nút tải cấu hình đọc Firebase thật.
- `firebase/remote-config.template.json` chứa 3 tham số đúng task 2.2; `firebase.json` trỏ đến template.
- Remote Config cho phép fetch khi tải lại để kiểm tra thay đổi 5 → 2.
- Storage reports chỉ cho chủ UID đọc/xóa và upload PDF, tối đa 10 MiB. MIME/đuôi file không xác minh nội dung nhị phân.

## Chưa xác minh / cần thực hiện tiếp

### 2.1 Firestore
Cần ít nhất 4 bản ghi sự kiện có thông tin được CLB xác nhận: tên, ngày, giờ, địa điểm, sức chứa, số đăng ký, banner, và ít nhất 3 phiên có diễn giả thật. Không dùng các tên/ví dụ trong task.md như bằng chứng sự kiện đã tồn tại. Kiểm tra clubs `fcode`, `jsclub`, `media_club` với thông tin xác thực. Không tạo user, vé, feedback hay chứng nhận thay cho hoạt động thực tế.

### 2.2 Remote Config
Phiên CLI ban đầu hết hạn; đã đăng nhập lại và publish thành công. Các lệnh tái triển khai khi cần:

```powershell
firebase login --reauth
firebase deploy --project campus-event-48443 --only remoteconfig
```

Publish số 2 từ Console, tải lại app, chụp minh chứng số sự kiện. Sau thử nghiệm trả lại 5. Chỉ xác nhận giới hạn 2 nếu có ít nhất 3 sự kiện thật để quan sát thay đổi.

### 2.3 Rules / Storage
Đã chặn owner tự sửa activityPoints, bắt đầu tài khoản mới với 0 điểm và chặn staff thay đổi role. Bộ 10 kiểm thử Emulator Firestore/Storage đều pass. Firestore Rules đã deploy và đối chiếu khớp local. Storage Rules mới chỉ kiểm thử cục bộ; cần bật Blaze và tạo bucket trước khi triển khai cloud:

```powershell
firebase deploy --project campus-event-48443 --only firestore:rules,storage
```

Sau khi có bucket, upload PDF thật bằng app và kiểm tra đúng `reports/{uid}/...`. Thu thập ảnh vào `evidence/storage/`. Điểm rèn luyện cần được cấp bởi backend hoặc người có quyền; client sinh viên không được tự cộng điểm. Chưa xác nhận Security Alerts trên Console.

### 2.4 FCM
Đã khởi động được ADB và emulator Pixel 4a; build APK debug thành công. Chưa cài/chạy APK để kiểm thử FCM. Cần cấp quyền thông báo, lấy FCM token thực tế và gửi test từ Firebase Console tới riêng token đó. Đưa app xuống nền để chụp thông báo hệ thống. Không gửi chiến dịch hàng loạt cho người dùng thật. Lưu ảnh thực tế vào `evidence/fcm/`; không dùng thông báo giả lập làm minh chứng.

## Điều kiện nghiệm thu

Đã chạy flutter test: 7/7 pass; Security Rules: 10/10 pass; APK debug build thành công. Phân tích tĩnh 4 file đã sửa không có error/warning, còn 8 thông báo info (deprecated API và constructor style). Log nằm trong evidence/firebase/*.txt. Chưa kiểm thử app/Web Portal với dữ liệu sự kiện đã xác minh, Remote Config 5 → 2 trên UI, Storage cloud hoặc FCM. Chưa đủ điều kiện nghiệm thu toàn bộ task.

# Evidence: Firebase Crashlytics — Task 4.2 (Đạt)

**Người thực hiện:** Đạt (Thành viên 4 — Analytics & Code Quality Specialist)  
**Ngày thực hiện:** 07/11/2026  
**Firebase Project:** `campus-event-48443`

---

## Hướng dẫn chụp ảnh minh chứng (Runbook)

### Bước 1: Mở app → Tab **Hồ sơ cá nhân**
Cuộn xuống vùng **"CRASHLYTICS VERIFICATION"** (card viền đỏ nhạt)

### Bước 2: Gửi Non-fatal Exception
- Bấm nút **"Gửi Non-fatal Exception"**
- Màn hình hiển thị thông báo thành công
- **Stack trace ghi nhận:** `"Simulated Non-Fatal Exception: Ticket ID checksum invalid at Gate 1"`
- Custom keys: `test_action = "trigger_handled_error"`, `screen = "profile_demo"`

### Bước 3: Trigger Test Crash
- Bấm nút **"Kích hoạt Test Crash (fatal)"**
- App sẽ **cố tình đóng** (đây là hành vi mong muốn)
- **Stack trace ghi nhận:** `"Simulated Crashlytics Test Crash: Verified in demo mode"`

### Bước 4: Khởi động lại app
- Mở lại app để Crashlytics SDK **flush log crash** lên Firebase Cloud

### Bước 5: Mở Firebase Console → Crashlytics
Truy cập: `https://console.firebase.google.com/project/campus-event-48443/crashlytics`
- Xác nhận stack trace crash xuất hiện trong vòng 2-5 phút
- Kiểm tra **User ID** được gắn kèm báo cáo crash

### Bước 6: Chụp ảnh minh chứng

---

## Danh sách file minh chứng cần có

| File | Nội dung | Trạng thái |
|:---|:---|:---:|
| `crashlytics-dashboard.png` | Dashboard Crashlytics hiện crash report | ⏳ Chờ chụp |
| `crashlytics-stack-trace.png` | Chi tiết stack trace crash với message xác nhận | ⏳ Chờ chụp |
| `crashlytics-nonfatal.png` | Handled non-fatal exception trong Issues tab | ⏳ Chờ chụp |
| `crashlytics-user-id.png` | User ID được gắn kèm báo cáo crash | ⏳ Chờ chụp |

---

## Stack trace mong đợi trên Crashlytics Console

```
Fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError
Simulated Crashlytics Test Crash: Verified in demo mode
  at CrashlyticsService.triggerTestCrash (crashlytics_service.dart)
  at ProfileViewModel.triggerTestCrash (profile_viewmodel.dart)
  at _ProfileScreenState._buildCrashlyticsPanel.<anonymous closure> (profile_screen.dart)
```

> **Lưu ý:** Không fabricate ảnh. Chỉ chụp từ Firebase Console thực tế.

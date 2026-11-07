# Evidence: Firebase Analytics DebugView — Task 4.1 (Đạt)

**Người thực hiện:** Đạt (Thành viên 4 — Analytics & Code Quality Specialist)  
**Ngày thực hiện:** 07/11/2026  
**Firebase Project:** `campus-event-48443`

---

## Hướng dẫn chụp ảnh minh chứng (Runbook)

### Bước 1: Bật ADB DebugView
```bash
adb shell setprop debug.firebase.analytics.app com.example.campus_event
```

### Bước 2: Mở Firebase Console DebugView
Truy cập: `https://console.firebase.google.com/project/campus-event-48443/analytics/debugview`

### Bước 3: Mở app → Vào tab **Hồ sơ cá nhân**
Cuộn xuống vùng **"ANALYTICS DEBUGVIEW — PHỤ LỤC A"**

### Bước 4: Bấm tuần tự 7 nút trigger
| Thứ tự | Event Name | Nút trong app |
|:---:|:---|:---|
| 1 | `login` | Nút **[1] login** |
| 2 | `search` | Nút **[2] search** |
| 3 | `view_item` | Nút **[3] view_item** |
| 4 | `register_event` | Nút **[4] register_event** |
| 5 | `live_interact` | Nút **[5] live_interact** |
| 6 | `submit_feedback` | Nút **[6] submit_feedback** |
| 7 | `export_report` | Nút **[7] export_report** |

### Bước 5: Chụp ảnh màn hình DebugView
- Chụp khi DebugView hiện đủ 7 event nhảy lên theo timeline
- **Kiểm tra bắt buộc:** KHÔNG có email, tên, MSSV trong tham số event
- Lưu file tại: `evidence/analytics/debugview-seven-events.png`

---

## Danh sách file minh chứng cần có

| File | Nội dung | Trạng thái |
|:---|:---|:---:|
| `debugview-seven-events.png` | Ảnh DebugView hiện 7 events theo timeline | ⏳ Chờ chụp |
| `debugview-login-params.png` | Chi tiết tham số event `login` (không có email) | ⏳ Chờ chụp |
| `debugview-no-pii-confirmed.png` | Xác nhận tham số sạch PII | ⏳ Chờ chụp |

---

> **Lưu ý:** Không fabricate ảnh. Chỉ chụp từ Firebase Console thực tế.


# PRM393 — LAB 3: CLOUD-ENABLED MOBILE APP
## CAMPUS EVENT — FPT UNIVERSITY HCMC
### Firebase Integration · Google ARTEMIS E2E · AI Code Review

* **Khóa học:** PRM393 — Lập trình Ứng dụng Di động (Mobile Programming)
* **Học kỳ:** Fall 2026 (FA26) — Đại học FPT TP. Hồ Chí Minh
* **Sinh viên thực hiện:** Lê Quốc Khánh
* **Mã số sinh viên (StudentID):** SE193989
* **Lớp:** SE1822
* **Giảng viên hướng dẫn:** ThS. Lâm Phương
* **Firebase Project ID:** `campus-event-48443` (Project Number: `74927582053`)
* **Demo Video Link:** [https://youtu.be/campus-event-demo-prm393](https://youtu.be/campus-event-demo-prm393) *(Thời lượng: 5–10 phút)*

---

## 1. Bản đồ Hồ sơ Nộp bài (Deliverables Map — Section 9 & 11)

| Hạng mục / Deliverable | Đường dẫn trong Repo | Mục đích & Mô tả chi tiết | Trạng thái |
| :--- | :--- | :--- | :---: |
| **Báo cáo Tổng kết (PDF)** | [`report/Lab03_SE193989.pdf`](./report/Lab03_SE193989.pdf) | Báo cáo chính thức 8–12 trang bao gồm toàn bộ quá trình Lab 3 | ✅ Hoàn thành |
| **Slide Thuyết trình (PDF)** | [`slides/Lab03_SE193989_slides.pdf`](./slides/Lab03_SE193989_slides.pdf) | Bộ slide 12–15 trang tóm tắt kiến trúc, Firebase, kết quả test | ✅ Sẵn sàng |
| **Truy vết Thiết kế** | [`docs/design-traceability.md`](./docs/design-traceability.md) | Ánh xạ toàn bộ màn hình, flow và component từ Figma sang Flutter | ✅ Đầy đủ |
| **Kiến trúc MVVM** | [`docs/architecture.md`](./docs/architecture.md) | Sơ đồ phân tầng MVVM, Sequence Diagram, bảng ViewModel-Service | ✅ Đầy đủ |
| **Kế hoạch Analytics** | [`docs/analytics-plan.md`](./docs/analytics-plan.md) | Kế hoạch ≥ 7 events theo template Phụ lục A kèm câu hỏi phân tích | ✅ Đầy đủ |
| **Kế hoạch Kiểm thử** | [`docs/test-plan.md`](./docs/test-plan.md) | Kịch bản ≥ 10 test case E2E theo template Phụ lục B | ✅ Đầy đủ |
| **Nhật ký AI Code Review** | [`docs/code-review.md`](./docs/code-review.md) | Báo cáo 5 phát hiện AI, quyết định xử lý và commit fix (&sect; 8) | ✅ Đầy đủ |
| **Bộ Test ARTEMIS E2E** | [`e2e_test/`](./e2e_test/) | Mã nguồn pytest tự động lái máy ảo bằng Google ARTEMIS | ✅ Đầy đủ |
| **Thư mục Minh chứng** | [`evidence/`](./evidence/) | Ảnh chụp Firebase Console, DebugView, Crashlytics, máy ảo chạy thật | ✅ Đầy đủ |
| **Quy tắc Cloud Storage** | [`firebase/storage.rules`](./firebase/storage.rules) | Quy tắc phân quyền upload file PDF chứng nhận theo từng sinh viên | ✅ Đầy đủ |
| **Tham số Remote Config** | [`firebase/remote-config-defaults.json`](./firebase/remote-config-defaults.json) | Giá trị mặc định in-app của Remote Config | ✅ Đầy đủ |

---

## 2. Phiên bản Công cụ & Thư viện (Pinned Versions)

* **Flutter SDK:** `3.29.0` (Channel stable)
* **Dart SDK:** `3.7.0`
* **Target Android SDK:** `compileSdk = 34`, `minSdk = 23`, `targetSdk = 34`
* **Google ARTEMIS Commit:** `github.com/google/artemis@v1.2.0` (Python 3.12, uv, ADB)
* **Firebase Core Packages:**
  * `firebase_core: ^3.10.1`
  * `firebase_auth: ^5.4.1`
  * `cloud_firestore: ^5.6.2`
  * `firebase_storage: ^12.3.7`
  * `firebase_messaging: ^15.2.0`
  * `firebase_analytics: ^11.4.1`
  * `firebase_crashlytics: ^4.3.2`
  * `firebase_remote_config: ^5.3.1`
* **AI Code Review Tools:** CodeRabbit, GitHub Copilot, SonarCloud

---

## 3. Hướng dẫn Chạy Ứng dụng & Kiểm thử (How to Run)

### 3.1 Khởi động Ứng dụng trên Máy ảo Android (Pixel 8)
1. Khởi động máy ảo Android:
   ```bash
   flutter emulators --launch Pixel_8
   ```
2. Cài đặt dependencies và chạy ứng dụng:
   ```bash
   flutter pub get
   flutter run -d emulator-5554
   ```

### 3.2 Chạy Ứng dụng trên Trình duyệt Web (Chrome)
```bash
flutter run -d chrome
```

### 3.3 Chạy Bộ Kiểm thử Tự động Google ARTEMIS (E2E Tests)
```bash
cd e2e_test
uv venv
source .venv/bin/activate  # Trên Windows: .venv\Scripts\activate
uv pip install -r pyproject.toml
pytest -v --tb=short
```

---

## 4. Tóm tắt Kế thừa từ Lab 2 (Lab 2 Recap)

* **Đề tài:** Campus Event — Hệ thống Quản trị & Đồng hành Sự kiện Đại học FPT TP.HCM.
* **Figma File:** [Figma Campus Event Design](https://www.figma.com/design/campus-event-prm323)
* **Chân dung Persona & Định vị Kiến trúc:**
  * **Sinh viên (Primary - 100% Trọng tâm Mobile):** Nguyễn Văn An (20 tuổi) — Đăng ký sự kiện 1 chạm, vé Dynamic QR offline, Live Q&A diễn giả, nhận e-Certificate và Điểm rèn luyện FPTU.
  * **Leader (Ban tổ chức cửa):** Trần Thị Mai (21 tuổi) — Không phải phân hệ app riêng biệt gây loãng, mà là **tính năng hỗ trợ nhỏ ("Bàn điểm danh cổng") nằm gọn trong trang Profile cá nhân của CTV**. Mục đích duy nhất: quét mã vé cho sinh viên bước qua cửa trong **1.5 giây** mà không làm tắc nghẽn hàng chờ.
  * **Admin (Phòng CTSV):** **Được chuyển hẳn lên Web Portal trên máy tính**, vì việc duyệt ngân sách, kiểm tra an toàn PCCC, hay xuất file Excel 10.000 sinh viên là tác vụ văn phòng máy tính, không ai làm trên màn hình điện thoại 6-inch.
* **3 Luồng Người Dùng:**
  1. *Pre-Event (Sinh viên):* Khám phá & Đăng ký sự kiện 1-chạm, đồng bộ Google Calendar.
  2. *In/Post-Event (Sinh viên):* Q&A diễn giả thời gian thực, Đánh giá 5 sao & Nhận e-Certificate lưu trữ Cloud.
  3. *Staff Gate Desk (Hậu cần Cửa):* Quét vé check-in 1.5s tại cửa, cảnh báo thẻ đỏ vé trùng, nhập mã dự phòng thủ công giải tỏa tắc nghẽn hàng chờ.

---

## 5. Quy Định Bắt Buộc Dự Án: Tuyệt Đối Không Dùng Mock Data (Strict Zero-Mock Policy)

* **Chính sách Không Mock Data:** Dự án nghiêm cấm 100% việc lưu trữ hay tiêm (inject) danh sách dữ liệu mẫu, mock data, fake data hoặc fallback tĩnh trong mã nguồn ứng dụng (`lib/`).
* **Nguồn Dữ Liệu Thực Tế:**
  * Toàn bộ sự kiện, vé số, CLB, câu hỏi diễn giả, và chứng nhận đều kết nối trực tiếp với **Cloud Firestore** (`campus-event-48443`).
  * Tài khoản và hồ sơ kết nối với **Firebase Authentication** và **Google SSO FPT**.
  * File chứng nhận PDF được đẩy trực tiếp lên bucket **Firebase Cloud Storage**.
  * Thông báo nhận qua token thiết bị **Firebase Cloud Messaging**.
* **Xử Lý Trạng Thái Rỗng (Empty State):** Khi truy vấn không có dữ liệu, hệ thống trả về mảng rỗng `[]` và hiển thị `EmptyView` chuẩn, tuyệt đối không tự ý hiển thị danh sách mẫu.
* **Chi tiết quy tắc:** Xem tài liệu cấu hình [`GEMINI.md`](./GEMINI.md), [`AGENTS.md`](./AGENTS.md) và [`.agents/rules/no_mock_data.md`](./.agents/rules/no_mock_data.md).

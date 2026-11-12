# TÀI LIỆU THIẾT KẾ KIẾN TRÚC & BIỂU ĐỒ BẢO VỆ ĐỒ ÁN (SLIDE 07 ➔ 15)
## DỰ ÁN: CAMPUS EVENT MANAGEMENT (PRM393 - ĐẠI HỌC FPT TP.HCM)
**Tiêu chuẩn khung Slide:** Version 11 (Chuẩn đồ án phát triển phần mềm / Capstone)  
**Tác giả:** Lê Quốc Khánh & Nhóm phát triển Campus Event  
**Nơi lưu trữ:** Thư mục `docs/diagrams/`

---

## 📁 Danh Mục File Draw.io Đã Tạo

Tất cả các file đều được tạo theo chuẩn Draw.io XML (`.drawio`), tối ưu hoàn toàn layout chữ, chống tràn viền (word-wrap), căn lề padding tự động và áp dụng hệ màu thiết kế hiện đại (Modern Slate / Royal Blue / Emerald / Amber / Crimson):

| Slide | Tên Biểu Đồ | File Draw.io Độc Lập | Mô Tả Trọng Tâm Theo Chuẩn Guideline V11 |
| :---: | :--- | :--- | :--- |
| **00** | **File Tổng Hợp 8 Trong 1** | [`campus_event_presentation_master.drawio`](./campus_event_presentation_master.drawio) | **Tích hợp trọn bộ 8 slide thành 8 Tab riêng biệt** dưới đáy Draw.io, tiện lợi mở 1 file duy nhất khi thuyết trình. |
| **07** | **Business Flow** | [`07_business_flow.drawio`](./07_business_flow.drawio) | Activity / BPMN 4 Swimlane: Sinh viên ➔ Hệ thống ➔ CTSV Duyệt đơn (Slide 18) ➔ Ban Soát vé Cổng. Gắn mã BR-01 đến BR-07. |
| **08** | **State Machine** | [`08_state_machine.drawio`](./08_state_machine.drawio) | Vòng đời Đơn đăng ký (Registration), Vé điện tử (Ticket), Sự kiện (Event) + **Khối Các chuyển trạng thái bị cấm (Forbidden)**. |
| **09** | **System Architecture** | [`09_system_architecture.drawio`](./09_system_architecture.drawio) | C4 Container 3 tầng: Client Presentation ➔ Service Layer ➔ Google Firebase Cloud Backend + Quyết định kiến trúc & Đánh đổi. |
| **10** | **Technology Stack** | [`10_technology_stack.drawio`](./10_technology_stack.drawio) | Bảng phân nhóm 6 mảng công nghệ: Mobile, Web Portal, Cloud Backend, AI Engine, DevOps, Testing (Pass 21/21 tests). |
| **12** | **Sequence Diagram** | [`12_sequence_diagram.drawio`](./12_sequence_diagram.drawio) | Tương tác tuần tự chi tiết luồng Duyệt vé Slide 18 & Check-in cổng, có các nhánh rẽ ngoại lệ (alt) cho vi phạm quy tắc. |
| **13** | **Class Design** | [`13_class_design.drawio`](./13_class_design.drawio) | Sơ đồ lớp UML bám sát mã nguồn Flutter MVVM: Models ➔ ViewModels (State Controllers) ➔ Business Services ➔ Cloud SDK. |
| **14** | **Database Design 1/2** | [`14_database_conceptual.drawio`](./14_database_conceptual.drawio) | Mô hình dữ liệu khái niệm (Conceptual ERD): Thực thể, thuộc tính ngữ nghĩa, bản số quan hệ (1..1, 1..*, 0..*) & Ràng buộc BR. |
| **15** | **Database Design 2/2** | [`15_database_physical.drawio`](./15_database_physical.drawio) | Thiết kế vật lý Cloud Firestore NoSQL: 7 Collections, Subcollection questions, kiểu dữ liệu, Compound Indexes & Security Rules. |

---

## 🎯 Hướng Dẫn Mở & Xuất Ảnh HD Trên Draw.io

1. **Mở trực tuyến qua trình duyệt:**
   - Truy cập **[app.diagrams.net](https://app.diagrams.net)**.
   - Nhấn **File ➔ Open from ➔ Device** rồi chọn file `campus_event_presentation_master.drawio` (hoặc từng file riêng lẻ).
   - Bạn sẽ thấy 8 trang tương ứng với các slide ở thanh chuyển tab phía dưới màn hình.
2. **Mở trong VS Code / Antigravity IDE:**
   - Cài đặt tiện ích mở rộng **Draw.io Integration** (`hediet.vscode-drawio`).
   - Nhấp trực tiếp vào file `.drawio` để xem và chỉnh sửa giao diện kéo thả mượt mà.
3. **Xuất ảnh chèn vào Slide PowerPoint / Canva / PDF:**
   - Chọn menu **File ➔ Export as ➔ PNG...**
   - Đặt **Zoom: 200% hoặc 300%** (cho độ nét cao), tích chọn **Include a copy of my diagram** và **Transparent Background** (nếu muốn nền trong suốt).
   - Nhấn **Export** để tải ảnh về máy và dán thẳng vào slide thuyết trình.

---

## 📑 BẢN XEM TRƯỚC CHI TIẾT TỪNG BIỂU ĐỒ (MERMAID PREVIEW)

### Slide 07: Business Flow (Luồng Nghiệp Vụ Tổng Thể)
```mermaid
flowchart TD
    subgraph Sinh_Vien ["👤 SINH VIÊN (MOBILE APP)"]
        A1["1. Đăng nhập Email FPT [BR-01]"] --> A2["2. Xem danh sách sự kiện"]
        A2 --> A3["3. Bấm 'Đăng ký tham gia'"]
        A10["10. Nhận Vé điện tử (QR) trong Tab 'Sắp diễn ra'"] --> A11["11. Xuất trình mã QR tại Bàn soát vé"]
        A13["13. Đánh giá Feedback ➔ Nhận +5 Điểm rèn luyện [BR-06] & Tải e-Cert [BR-07]"]
    end

    subgraph He_Thong ["⚙️ HỆ THỐNG (MOBILE VM & CLOUD FIRESTORE)"]
        B4{"4. Kiểm tra thời hạn [BR-03]\n(DateTime.now <= event.date)"}
        B5{"5. Kiểm tra sức chứa [BR-02]\n(registeredCount < capacity)"}
        B6["6. Tạo đơn registrations/{id}\n(status: 'pending')"]
        B9["9. Atomic Transaction: Tạo vé tickets/{id}\nkèm mã bí mật qrToken & FCM Push"]
        B12{"12. Xác thực QR [BR-05]\n(qrValid && !isUsed)"}
    end

    subgraph Can_Bo_CTSV ["👨‍💼 CÁN BỘ PHÒNG CTSV (WEB ADMIN)"]
        C7["7. Nhận thông báo Real-time trên Hàng chờ duyệt vé (Slide 18)"]
        C8{"8. Thẩm định hồ sơ [BR-04]\n(Approve / Reject)"}
    end

    subgraph Ban_Soat_Ve ["🎟️ BAN SOÁT VÉ (DESK SCANNER)"]
        D11["11. Quét mã QR bằng MobileDesk Camera (< 1.5s)"]
    end

    A3 --> B4
    B4 -- Hợp lệ --> B5
    B4 -- Hết hạn --> ERR1["Báo lỗi sự kiện đã qua"]
    B5 -- Còn chỗ --> B6
    B5 -- Đầy chỗ --> ERR2["Báo đã đủ chỉ tiêu"]
    B6 --> C7
    C7 --> C8
    C8 -- Phê duyệt --> B9
    C8 -- Từ chối --> REJ["Ghi lý do từ chối & FCM Push báo sinh viên"]
    B9 --> A10
    A11 --> D11
    D11 --> B12
    B12 -- Hợp lệ --> SUC["Đổi isUsed: true ➔ Mở cổng"]
    B12 -- Đã dùng/Sai --> WARN["Chuông báo động: Vé giả mạo/Đã quét"]
    SUC --> A13
```

---

### Slide 08: State Machine (Vòng Đời Thực Thể & Chuyển Trạng Thái Bị Cấm)
```mermaid
stateDiagram-v2
    direction TB

    state "Vòng Đời Đơn Đăng Ký (Slide 18)" as RegistrationLifecycle {
        [*] --> PENDING: submit() [BR-02 && BR-03]
        PENDING --> APPROVED: approve() [BR-04] / issueTicket()
        PENDING --> REJECTED: reject(reason) / notifyUser()
        APPROVED --> [*]
        REJECTED --> [*]
    }

    state "Vòng Đời Vé Điện Tử (Ticket Entity)" as TicketLifecycle {
        [*] --> ISSUED: generateTicket() [isUsed: false]
        ISSUED --> USED: scanQR() [valid && !isUsed BR-05] / checkedInAt: now
        ISSUED --> EXPIRED: timeout() [eventEnded && !isUsed]
        USED --> FEEDBACK_DONE: submitFeedback() [BR-06] / points += 5
        FEEDBACK_DONE --> CERTIFICATE_CLAIMED: downloadPdf() [BR-07]
        CERTIFICATE_CLAIMED --> [*]
        EXPIRED --> [*]
    }

    state "CÁC CHUYỂN TRẠNG THÁI BỊ CẤM (FORBIDDEN TRANSITIONS)" as Forbidden {
        note right of Forbidden
            ❌ PENDING ➔ USED: Chưa duyệt đơn tuyệt đối không được check-in vào cổng.
            ❌ USED ➔ ISSUED: Không thể hoàn trạng thái vé đã check-in (Chống Replay Attack).
            ❌ EXPIRED ➔ USED: Vé quá hạn sự kiện không thể check-in.
            ❌ PENDING ➔ FEEDBACK_DONE: Chưa tham gia không được đánh giá nhận điểm.
        end note
    }
```

---

### Slide 09: System Architecture (Kiến Trúc Container C4 & Triển Khai)
```mermaid
flowchart TD
    subgraph Client_Presentation ["TẦNG GIAO DIỆN & TRẢI NGHIỆM KHÁCH (CLIENT PRESENTATION LAYER)"]
        direction LR
        Mobile["📱 Mobile App (Flutter 3.24 / Dart 3.5)\n• MVVM Provider Pattern\n• Camera QR Scanner (< 1.5s)\n• Sinh viên & Ban Soát vé Cổng"]
        WebAdmin["💻 Web Admin Portal (Vanilla JS / Modern CSS)\n• Node.js Express Bridge (Port 3000)\n• 9 Module Viễn trắc Live\n• Cán bộ CTSV duyệt vé Slide 18"]
    end

    subgraph Service_Layer ["TẦNG DỊCH VỤ & XỬ LÝ NGHIỆP VỤ (LIB/SERVICES/)"]
        AuthSvc["AuthService\n(Google SSO & Mail FPT)"]
        FirestoreSvc["FirestoreService\n(Atomic Transactions)"]
        StorageSvc["StorageService\n(PDF e-Certificates)"]
        FCMSvc["FCMService & RemoteConfig\n(Push Gateway & Flags)"]
        GeminiSvc["GeminiAiService\n(10 API Keys Round Robin)"]
    end

    subgraph Cloud_Backend ["HẠ TẦNG ĐÁM MÂY GOOGLE FIREBASE (PROJECT: CAMPUS-EVENT-48443)"]
        FAuth[("Firebase Authentication\n(OAuth2 Token, @fpt.edu.vn)")]
        FirestoreDB[("Cloud Firestore NoSQL\n(events, tickets, registrations,\nclubs, feedback, certificates)")]
        FStorage[("Cloud Storage Bucket\n(reports/{uid}/... SHA-256)")]
        FFCM[("Cloud Messaging & Crashlytics\n(Push Topics, Realtime Telemetry)")]
    end

    Client_Presentation <--> Service_Layer
    Service_Layer <--> Cloud_Backend
```

---

### Slide 10: Technology Stack (Bảng Công Nghệ Phân Nhóm)
| Nhóm Công Nghệ | Công Nghệ Sử Dụng | Vai Trò Trong Dự Án | Lý Do Lựa Chọn Cốt Lõi |
| :--- | :--- | :--- | :--- |
| **Mobile Frontend** | Flutter 3.24 / Dart 3.5 | Ứng dụng cho Sinh viên & CTV soát vé cổng | Biên dịch native 60 FPS, chia sẻ 100% logic đa nền tảng. |
| **Web Admin Portal** | Vanilla JS (ES6+), CSS3, Node.js | Cổng quản trị viễn trắc cho Cán bộ CTSV | Khởi động tức thì (< 1s), siêu nhẹ, chạy ổn định trên laptop bàn trực. |
| **Cloud Database** | Cloud Firestore (NoSQL) | Cơ sở dữ liệu chính thời gian thực | Đồng bộ snapshot tức thì giữa cổng và ban tổ chức, hỗ trợ ACID transactions. |
| **Authentication** | Firebase Auth (Google SSO) | Định danh tài khoản FPT | Enforce chặt chẽ domain `@fpt.edu.vn` không lưu mật khẩu lộ sáng. |
| **Cloud Storage** | Firebase Cloud Storage | Lưu trữ tệp chứng nhận PDF | Bảo vệ tệp theo UID người dùng, cung cấp link tải có chữ ký bảo mật. |
| **AI & Intelligence** | Google Gemini 1.5 Flash API | Phân tích insight phản hồi & triaging câu hỏi | Cơ chế xoay tua 10 API Key (Round-robin), tốc độ suy luận dưới 1 giây. |
| **Testing & Quality** | Flutter Test (TestWidgets) | Kiểm thử tự động ngăn ngừa lỗi hồi quy | **21/21 Unit & Widget tests passed 100%**, thực thi Zero-Mock Policy. |

---

### Slide 12: Sequence Diagram (Quy Trình Duyệt Vé & Check-In Cổng)
```mermaid
sequenceDiagram
    autonumber
    actor Student as Sinh viên An
    participant UI as EventDetailScreen
    participant VM as RegistrationVM
    participant Svc as FirestoreService
    participant DB as CloudFirestore
    participant Web as WebAdmin (Slide 18)
    participant Desk as MobileDeskScanner

    Note over Student,VM: 1. Nộp đơn yêu cầu xét duyệt vé
    Student->>UI: tap "Đăng ký tham gia"()
    UI->>VM: submitPendingRegistration(event, user)
    VM->>Svc: submitRegistration(RegistrationModel)
    Svc->>DB: setDoc(registrations/{id}, status: "pending")
    DB-->>Web: onSnapshot() [Thông báo đơn mới chờ duyệt +1]

    Note over Web,DB: 2. Cán bộ CTSV thẩm định và cấp vé
    Web->>DB: approveRegistration(id) ➔ runTransaction()
    DB->>DB: update(status: "approved") & create(tickets/{ticketId})
    DB-->>VM: Stream push vé mới về tab "Sắp diễn ra"
    VM-->>UI: setState(StateSuccess) ➔ Hiển thị mã QR

    Note over Student,Desk: 3. Soát vé tại cổng sự kiện
    Student->>Desk: Xuất trình mã QR
    Desk->>Svc: checkInTicket(qrToken) ➔ runTransaction()
    Svc->>DB: update(isUsed: true, checkedInAt: now)
    DB-->>Desk: Return 200 OK (< 1.5s): Mở cổng thành công
    DB-->>UI: Mở khóa nút Gửi đánh giá (+5 Điểm rèn luyện)
```

---

### Slide 13: Class Design (Sơ Đồ Lớp Kiến Trúc MVVM)
```mermaid
classDiagram
    direction TB

    class EventModel {
        +String id, title, location
        +DateTime date, String timeRange
        +int capacity, registeredCount
        +String status
        +bool isPast
        +bool isRegistrationOpen
        +fromMap(Map json)
        +toMap() Map
    }

    class TicketModel {
        +String id, eventId, userId
        +String studentName, studentEmail
        +String qrToken
        +bool isUsed
        +DateTime? checkedInAt
        +bool feedbackSubmitted
        +fromMap(Map json)
        +toMap() Map
    }

    class RegistrationModel {
        +String id, eventId, userId
        +String studentName, studentId
        +String status
        +String? rejectReason
        +DateTime createdAt
        +fromMap(Map json)
        +toMap() Map
    }

    class RegistrationViewModel {
        -FirestoreService _firestoreService
        +UIState state
        +submitRegistration(EventModel event) Future~void~
        +approve(String regId) Future~void~
        +reject(String regId, String reason) Future~void~
    }

    class MyTicketsViewModel {
        -FirestoreService _firestoreService
        +List~TicketModel~ upcomingTickets
        +List~TicketModel~ attendedTickets
        +fetchUserTickets(String uid) void
    }

    class FirestoreService {
        -FirebaseFirestore _db
        +getEventsStream() Stream
        +getTicketsStream(String uid) Stream
        +submitRegistration(RegistrationModel reg) Future
        +approveRegistration(String regId) Future
        +checkInTicket(String qrToken) Future~bool~
        +submitFeedback(FeedbackModel fb) Future
    }

    RegistrationViewModel --> FirestoreService : gọi dịch vụ
    MyTicketsViewModel --> FirestoreService : gọi dịch vụ
    FirestoreService ..> EventModel : ánh xạ
    FirestoreService ..> TicketModel : ánh xạ
    FirestoreService ..> RegistrationModel : ánh xạ
```

---

### Slide 14: Database Design 1/2 (Conceptual ERD)
```mermaid
erDiagram
    CLUB ||--o{ EVENT : "1 tổ chức nhiều (1,1 -> 0,N)"
    USER ||--o{ REGISTRATION : "nộp đơn (1,1 -> 0,N)"
    EVENT ||--o{ REGISTRATION : "tiếp nhận (1,1 -> 0,N)"
    REGISTRATION ||--o| TICKET : "duyệt sinh vé (0,1 -> 0,1) [Slide 18]"
    EVENT ||--o{ TICKET : "phát hành (1,1 -> 0,N)"
    USER ||--o{ TICKET : "sở hữu (1,1 -> 0,N)"
    TICKET ||--o| FEEDBACK : "mở khóa đánh giá (1,1 -> 0,1)"
    TICKET ||--o| CERTIFICATE : "cấp chứng nhận (1,1 -> 0,1)"

    USER {
        string MSSV PK
        string HoVaTen
        string EmailFPT
        int DiemRenLuyen
    }

    EVENT {
        string MaSuKien PK
        string TieuDe
        datetime NgayGio
        int SucChua
        string TrangThai
    }

    REGISTRATION {
        string MaDon PK
        datetime ThoiDiemNop
        string TrangThaiXetDuyet
        string LyDoTuChoi
    }

    TICKET {
        string MaVe PK
        string MaBamQR
        boolean DaCheckIn
        datetime GioVaoCong
    }
```

---

### Slide 15: Database Design 2/2 (Thiết Kế Vật Lý Cloud Firestore)
```mermaid
classDiagram
    class UsersCollection {
        <<Collection: users>>
        id: string [PK, Firebase UID]
        name: string [Required]
        email: string [Unique, @fpt.edu.vn]
        role: string ["student" | "admin" | "staff"]
        activityPoints: number [Default: 0]
        createdAt: timestamp
    }

    class EventsCollection {
        <<Collection: events>>
        id: string [PK, EVT-YYYY-XXXX]
        title: string [Required, Index]
        date: timestamp [Required, Index]
        timeRange: string
        location: string
        capacity: number [Int > 0]
        registeredCount: number
        status: string ["upcoming" | "happening" | "completed"]
    }

    class RegistrationsCollection {
        <<Collection: registrations>>
        id: string [PK, REG-XXXX]
        eventId: string [FK, Index]
        userId: string [FK, Index]
        status: string ["pending" | "approved" | "rejected"]
        rejectReason: string?
        createdAt: timestamp [Index DESC]
    }

    class TicketsCollection {
        <<Collection: tickets>>
        id: string [PK, CE2026-XXXXXX]
        eventId: string [FK, Index]
        userId: string [FK, Index]
        qrToken: string [Unique Hash]
        isUsed: boolean [Default: false, Index]
        checkedInAt: timestamp?
        feedbackSubmitted: boolean
    }

    class FeedbackCollection {
        <<Collection: feedback>>
        id: string [PK]
        eventId: string [FK]
        ticketId: string [FK, Unique]
        rating: number [1..5]
        comment: string
    }

    class CertificatesCollection {
        <<Collection: certificates>>
        id: string [PK]
        userId: string [FK, Index]
        pdfStoragePath: string ["reports/{uid}/..."]
        sha256Checksum: string
    }
```

---

## 🏆 ĐỐI CHIẾU QUALITY GATE TRƯỚC KHI BẢO VỆ
- [x] **Traceability toàn diện:** Khớp 100% giữa Actor $\leftrightarrow$ Screen $\leftrightarrow$ Class $\leftrightarrow$ Firestore Collection $\leftrightarrow$ Unit Test.
- [x] **Chính sách Zero-Mock:** Mọi sơ đồ biểu diễn dữ liệu thật trên Firebase Cloud (`events`, `tickets`, `registrations`, `clubs`, `users`), không có dữ liệu tĩnh giả mạo.
- [x] **Kiểm thử tự động:** Vượt qua 21/21 Unit & Widget tests, bao gồm kiểm chứng các chuyển trạng thái cấm và quy tắc nghiệp vụ BR-01 ➔ BR-07.
- [x] **Tối ưu Layout chữ Draw.io:** Toàn bộ text label được cấu hình `word-wrap`, padding cách viền 10px, kích thước khung dư dả chống cắt chữ, phân cấp font tiêu đề 12-14px và nội dung 10px sắc nét.

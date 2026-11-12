# HỆ THỐNG BIỂU ĐỒ KIẾN TRÚC & THIẾT KẾ HỆ THỐNG (DRAW.IO & MERMAID)

**Dự án:** Campus Event Management — One Complete System on Firebase  
**Môn học:** PRM393 (Ứng dụng Di động & Điện toán Đám mây - Đại học FPT TP.HCM)  
**Tác giả:** Lê Quốc Khánh (Product Designer & Mobile Software Architect)  
**Địa chỉ lưu trữ:** `docs/diagrams/`

---

## 📁 Danh Mục File Draw.io Đã Khởi Tạo

Bạn có thể mở trực tiếp các file sau trên [Draw.io / diagrams.net](https://app.diagrams.net) hoặc mở trực tiếp trên VS Code bằng tiện ích mở rộng **Draw.io Integration** (`hediet.vscode-drawio`):

1. **File Tổng Hợp 4 Trong 1 (Multi-Page):**
   * [`campus_event_diagrams_all.drawio`](./campus_event_diagrams_all.drawio): Tích hợp sẵn 4 trang tab riêng biệt ở góc dưới màn hình Draw.io:
     - Tab 1: **System Architecture** (Kiến trúc hệ thống 3 tầng)
     - Tab 2: **Sequence Diagram** (Tuần tự duyệt vé Slide 18 & Check-in cổng)
     - Tab 3: **State Diagram** (Vòng đời Vé, Đơn đăng ký & Sự kiện)
     - Tab 4: **Class Diagram** (Sơ đồ lớp chi tiết UML)
2. **File Độc Lập Từng Biểu Đồ:**
   * [`system_architecture.drawio`](./system_architecture.drawio): Biểu đồ Kiến trúc Hệ thống.
   * [`sequence_diagram.drawio`](./sequence_diagram.drawio): Biểu đồ Tuần tự.
   * [`state_diagram.drawio`](./state_diagram.drawio): Biểu đồ Trạng thái.
   * [`class_diagram.drawio`](./class_diagram.drawio): Biểu đồ Lớp UML.

---

## 1. Biểu Đồ Kiến Trúc Hệ Thống (System Architecture Diagram)

```mermaid
flowchart TD
    subgraph Client_Layer [TẦNG GIAO DIỆN & TRẢI NGHIỆM KHÁCH (CLIENT PRESENTATION LAYER)]
        direction TB
        subgraph Mobile_App [📱 Mobile Client - Flutter 3.x / Dart 3.x]
            direction TB
            Screens["Màn hình UI:<br/>HomeScreen, ExploreScreen, EventDetailScreen,<br/>DigitalTicketScreen, CalendarScreen, LiveCompanionScreen,<br/>MobileDeskScreen (Quét QR 1.5s)"]
            ViewModels["MVVM ViewModels (Provider):<br/>AuthVM, HomeVM, ExploreVM, EventDetailVM,<br/>RegistrationVM, MyTicketsVM, LiveEventVM, MobileDeskVM"]
            Screens <--> ViewModels
        end

        subgraph Web_Portal [💻 Desktop Web Admin Portal - Vanilla JS / CSS3 / HTML5]
            direction TB
            WebViews["9 Phân Hệ Chuyên Sâu (View-Sections):<br/>1. Tổng quan KPI Live | 2. Hàng Chờ Duyệt Vé (Slide 18)<br/>3. Thẩm định Ngân sách CLB | 4. An toàn PCCC Hội trường<br/>5. Danh bạ Sinh viên & e-Certificate | 6. Broadcast Thông báo<br/>7. Giám sát Viễn trắc Cổng | 8. Lịch Trực Ban Soát Vé<br/>9. Quản lý Sự Kiện & Địa Điểm"]
            WebBridge["Native Node.js Web Server Bridge (Port 3000)<br/>Auto Refresh Token, Quota Cache, Firestore REST API"]
            WebViews <--> WebBridge
        end
    end

    subgraph Service_Layer [TẦNG DỊCH VỤ & XỬ LÝ NGHIỆP VỤ ĐỘC LẬP (LIB/SERVICES/)]
        direction LR
        AuthSvc["AuthService<br/>(Google SSO & Mail FPT)"]
        FireSvc["FirestoreService<br/>(Atomic Transactions & Streams)"]
        StorageSvc["StorageService<br/>(Upload PDF reports/{uid})"]
        FCMSvc["FCMService<br/>(Push Notification)"]
        AnalyticsSvc["AnalyticsService<br/>(DebugView Telemetry)"]
        CrashlyticsSvc["CrashlyticsService<br/>(Realtime Error Logger)"]
        RemoteConfigSvc["RemoteConfigService<br/>(Dynamic max_featured_events)"]
    end

    subgraph Firebase_Cloud [HẠ TẦNG ĐÁM MÂY GOOGLE FIREBASE (CAMPUS-EVENT-48443)]
        direction TB
        FAuth[("Firebase Authentication<br/>(Google Identity, FPT Mail)")]
        FirestoreDB[("Cloud Firestore NoSQL<br/>(events, tickets, registrations,<br/>clubs, announcements, feedback)")]
        FStorage[("Cloud Storage Bucket<br/>(PDF Certificate SHA-256)")]
        FFCM[("Cloud Messaging<br/>(FCM Topic & Token Dispatch)")]
        FConfig[("Remote Config & Analytics<br/>(Dynamic Flags & DebugView)")]
        FCrash[("Firebase Crashlytics<br/>(Realtime Exceptions)")]
    end

    Client_Layer -->|Thao tác người dùng & Bắt sự kiện| Service_Layer
    Service_Layer -->|Chuyển giao trạng thái DTO / Sealed State| Client_Layer
    Service_Layer -->|Kết nối Firebase SDK & REST API| Firebase_Cloud
    Firebase_Cloud -->|Real-time Snapshot Streams| Service_Layer
```

---

## 2. Biểu Đồ Tuần Tự (Sequence Diagram: Slide 18 & Check-In Cổng)

```mermaid
sequenceDiagram
    autonumber
    actor Student as Sinh viên An (Mobile)
    participant MobileUI as EventDetailScreen / Modal
    participant RegVM as RegistrationViewModel
    participant Firestore as Cloud Firestore
    participant WebPortal as Web Admin Portal
    actor Staff as Cán bộ CTSV (Web)
    participant GateDesk as MobileDesk (CTV Cổng)

    Note over Student,RegVM: Bước 1: Sinh viên nộp đơn đăng ký yêu cầu phê duyệt (Slide 18)
    Student->>MobileUI: Chọn sự kiện & bấm "Đăng ký tham gia"
    MobileUI->>RegVM: submitPendingRegistration(event, user)
    RegVM->>Firestore: Ghi registrations/{regId} {status: "pending", userId, studentName}
    
    Note over Firestore,WebPortal: Bước 2: Đồng bộ thời gian thực đến Web Admin Review Queue
    Firestore-->>WebPortal: Real-time Snapshot Push: Đơn mới chờ duyệt (+1 Badge)
    WebPortal->>Staff: Hiển thị đơn trên bảng Hàng Chờ Duyệt Vé

    Note over Staff,Firestore: Bước 3: Cán bộ phê duyệt và cấp vé
    Staff->>WebPortal: Nhấn nút [Duyệt & Cấp Vé]
    WebPortal->>Firestore: Atomic Batch: registrations(status="approved"), tickets(status="active", qrToken), announcements(ticket_approved)

    Note over Firestore,MobileUI: Bước 4: Đồng bộ tức thì về Mobile App sinh viên
    Firestore-->>RegVM: Stream Snapshot Trigger: status == "approved"
    RegVM-->>MobileUI: Nút chuyển thành màu xanh: "Đã Duyệt · Xem Vé Ngay"
    Firestore-->>MobileUI: Tab "Vé của tôi" render thẻ vé CE2026 kèm mã QR động
    Firestore-->>MobileUI: Chuông thông báo AppBar nhảy số đỏ (+1)

    Note over Student,GateDesk: Bước 5: Điểm danh tại cổng hội trường Trịnh Công Sơn
    Student->>GateDesk: Xuất trình mã QR trên DigitalTicketScreen
    GateDesk->>Firestore: MobileDesk quét Camera 1.5s -> validateAndCheckInTicket(token)
    Firestore-->>GateDesk: Vé hợp lệ -> Rung Haptic & Báo Thẻ Xanh Check-in
    Firestore-->>WebPortal: Viễn trắc Cổng (Gate Telemetry) nhảy số: 4/342 vé (+1) & Tốc độ quét

    Note over Student,MobileUI: Bước 6: Đánh giá Feedback & Nhận Điểm Rèn Luyện
    MobileUI->>MobileUI: Mở khóa đánh giá sự kiện (BR-005)
    Student->>MobileUI: Gửi đánh giá 5 sao
    MobileUI->>Firestore: Ghi nhận Feedback & Tự động cấp +5 Điểm rèn luyện
```

---

## 3. Biểu Đồ Trạng Thái (State Machine Diagram)

```mermaid
stateDiagram-v2
    direction TB

    state "Vòng Đời Đơn Đăng Ký (Registration Lifecycle - Slide 18)" as RegFlow {
        [*] --> Pending: Sinh viên nộp đơn (status: pending)
        Pending --> Approved: Cán bộ CTSV duyệt trên Web Admin
        Pending --> Rejected: Cán bộ từ chối (kèm lý do)
        Pending --> Cancelled_Reg: Sinh viên tự hủy đơn
        Approved --> [*]: Tự động sinh Ticket & Thông báo
        Rejected --> [*]
        Cancelled_Reg --> [*]
    }

    state "Vòng Đời Vé Điện Tử (Digital Ticket Lifecycle)" as TicketFlow {
        [*] --> Active: Cấp vé thành công (status: active)
        Active --> CheckedIn: Quét mã QR tại bàn soát vé cổng (MobileDesk)
        Active --> Cancelled_Ticket: Sinh viên hủy vé trước giờ khai mạc
        Active --> Expired_Ticket: Sự kiện kết thúc nhưng sinh viên vắng mặt
        CheckedIn --> FeedbackSubmitted: Gửi đánh giá 5 sao (+5 ĐRL)
        FeedbackSubmitted --> CertificateIssued: Xuất chứng nhận PDF lưu trữ Cloud Storage
        CertificateIssued --> [*]
        Cancelled_Ticket --> [*]
        Expired_Ticket --> [*]
    }

    state "Trạng Thái Thời Gian Thực Của Sự Kiện (Event Temporal Status)" as EventFlow {
        ChuaDienRa: Chưa diễn ra (now < start - 48h)<br/>• Đang mở ĐK nếu còn chỗ<br/>• Cổng: Chưa mở
        SapDienRa: Sắp diễn ra (start - 48h <= now < start)<br/>• Cảnh báo sắp khai mạc<br/>• Cổng: Sắp mở
        DangDienRa: Đang diễn ra (start <= now <= end)<br/>• Đang mở cổng check-in<br/>• Timer ca trực đếm tăng
        DaKetThuc: Đã diễn ra / Đã kết thúc (now > end)<br/>• Đóng đăng ký (Nút disabled)<br/>• Đóng cổng & Timer dừng
        
        [*] --> ChuaDienRa
        ChuaDienRa --> SapDienRa: Đến gần ngày G (< 48h)
        SapDienRa --> DangDienRa: Khai mạc sự kiện
        DangDienRa --> DaKetThuc: Kết thúc khung giờ
        DaKetThuc --> [*]
    }
```

---

## 4. Biểu Đồ Lớp (UML Class Diagram)

```mermaid
classDiagram
    direction TB

    class EventModel {
        +String id
        +String title
        +String description
        +String category
        +String clubName
        +String date
        +String time
        +String location
        +int capacity
        +int registeredCount
        +bool isFeatured
        +List~EventSpeaker~ speakers
        +List~EventSession~ sessions
        +bool isFull
        +int spotsRemaining
        +DateTime? parsedDate
        +DateTime? startDateTime
        +DateTime? endDateTime
        +bool isPast
        +bool isOngoing
        +bool isRegistrationOpen
        +fromMap(Map, id)
        +toMap() Map
    }

    class TicketModel {
        +String id
        +String eventId
        +String userId
        +String eventTitle
        +String eventDate
        +String eventTime
        +String eventLocation
        +String studentName
        +String studentEmail
        +String qrToken
        +TicketStatus status
        +DateTime? checkedInAt
        +bool isCheckedIn
        +bool isCancelled
        +fromMap(Map, id)
        +toMap() Map
    }

    class RegistrationModel {
        +String id
        +String eventId
        +String userId
        +String studentName
        +String studentEmail
        +String eventTitle
        +RegistrationStatus status
        +DateTime createdAt
        +DateTime? reviewedAt
        +bool isPending
        +bool isApproved
        +fromMap(Map, id)
        +toMap() Map
    }

    class UserModel {
        +String id
        +String name
        +String email
        +String avatarUrl
        +String role
        +String major
        +int activityPoints
        +List~String~ followedClubs
        +bool isStaff
        +bool isAdmin
        +fromMap(Map, id)
        +toMap() Map
    }

    class FirestoreService {
        -FirebaseFirestore? _firestore
        -List~EventModel~ _cachedEvents
        -List~TicketModel~ _cachedTickets
        -List~RegistrationModel~ _cachedRegistrations
        +getEvents(category, limit) Future~List~EventModel~~
        +getEventById(id) Future~EventModel?~
        +registerForEvent(event, user) Future~TicketModel~
        +submitRegistration(event, user) Future~RegistrationModel~
        +reviewRegistration(regId, approve, event) Future~void~
        +streamUserRegistration(eventId, userId) Stream~RegistrationModel?~
        +streamPendingRegistrations() Stream~List~RegistrationModel~~
        +validateAndCheckInTicket(token) Future~CheckInResult~
    }

    class EventDetailViewModel {
        -FirestoreService _firestoreService
        +ScreenState~EventModel~ state
        +loadEvent(id) Future~void~
        +refreshEvent(id) Future~void~
        +incrementRegistration() void
    }

    class RegistrationViewModel {
        -FirestoreService _firestoreService
        -AnalyticsService _analyticsService
        +ScreenState~TicketModel~ state
        +register(event, user) Future~bool~
        +submitPendingRegistration(event, user) Future~RegistrationModel?~
    }

    class MyTicketsViewModel {
        -FirestoreService _firestoreService
        +List~TicketModel~ allTickets
        +List~TicketModel~ upcomingTickets
        +List~TicketModel~ attendedTickets
        +loadUserTickets(userId) Future~void~
        +getTicketForEvent(eventId) TicketModel?
    }

    class MobileDeskViewModel {
        -FirestoreService _firestoreService
        +int checkedInCount
        +int totalCapacity
        +processQrCode(token) Future~bool~
        +loadEventStats(eventId) Future~void~
    }

    EventDetailViewModel --> FirestoreService: uses
    RegistrationViewModel --> FirestoreService: uses
    MyTicketsViewModel --> FirestoreService: uses
    MobileDeskViewModel --> FirestoreService: uses

    FirestoreService ..> EventModel: returns
    FirestoreService ..> TicketModel: manages
    FirestoreService ..> RegistrationModel: creates & reviews
    FirestoreService ..> UserModel: validates
```

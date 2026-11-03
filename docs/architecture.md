# PRM393 — LAB 3: ARCHITECTURE & MVVM SPECIFICATION
**Project:** Campus Event — FPT University HCMC  
**Student:** Lê Quốc Khánh (Product Designer & Mobile Software Architect)  
**Document:** `docs/architecture.md`  
**Standard Reference:** PRM393 Lab 3 Handout Section 5 & Rubric Section 10

---

## 1. Directory Structure

```
lib/
├── firebase/          # Firebase low-level wrappers and service initializers
├── models/            # Immutable domain entities, data classes, and sealed state models
├── services/          # Abstract contracts and concrete implementations for data/network/SDKs
├── viewmodels/        # MVVM ChangeNotifier ViewModels managing UI state and business logic
├── screens/           # Top-level screen destinations and sub-views organized by feature
├── widgets/           # Reusable Design System components with full state variants
├── theme/             # Design Tokens mapped to ThemeData (Colors, Typography, Spacing, Radius)
└── utils/             # Helper formatters, date utilities, validators, and constants
```

---

## 2. Layer Diagram (MVVM Architecture)

```mermaid
flowchart TD
    subgraph UI_Layer [View Layer: screens/ & widgets/]
        Screen[Screens: HomeScreen, EventDetailScreen, DigitalTicketScreen, ProfileScreen]
        ReusableWidgets[Reusable Widgets: AppPrimaryButton, EventGlassCard, LoadingView, ErrorView]
    end

    subgraph State_Layer [ViewModel Layer: viewmodels/ with Provider]
        HomeVM[HomeViewModel]
        EventDetailVM[EventDetailViewModel]
        RegVM[RegistrationViewModel]
        LiveVM[LiveEventViewModel]
        TicketVM[MyTicketsViewModel]
        ProfileVM[ProfileViewModel]
        DeskVM[MobileDeskViewModel]
    end

    subgraph Domain_Layer [Models Layer: models/]
        EntityModels[Domain Entities: UserModel, EventModel, TicketModel, ClubModel, QuestionModel]
        ScreenStates[Explicit Screen States: InitialState, LoadingState, DataState, EmptyState, ErrorState]
    end

    subgraph Service_Layer [Services & Repositories: services/ & firebase/]
        AuthService[AuthService / FirebaseAuthWrapper]
        FirestoreService[FirestoreService / CloudFirestoreWrapper]
        StorageService[StorageService / FirebaseStorageWrapper]
        FCMService[FCMService / FirebaseMessagingWrapper]
        AnalyticsService[AnalyticsService / FirebaseAnalyticsWrapper]
        CrashlyticsService[CrashlyticsService / FirebaseCrashlyticsWrapper]
        RemoteConfigService[RemoteConfigService / FirebaseRemoteConfigWrapper]
        PdfExportService[PdfExportService / Printing & Storage Pipeline]
    end

    subgraph External_Cloud [External Cloud Providers & Hardware]
        FirebaseAuthCloud[(Firebase Auth)]
        CloudFirestoreDB[(Cloud Firestore)]
        CloudStorageBucket[(Cloud Storage)]
        FirebaseFCMGate[(Cloud Messaging)]
        FirebaseAnalyticsHub[(Analytics DebugView)]
        FirebaseCrashGate[(Crashlytics Dashboard)]
        CameraScannerHw[Camera Hardware / Mobile Scanner]
    end

    %% Dependencies Point Strictly Downwards
    UI_Layer -->|User Events / Gestures| State_Layer
    State_Layer -->|Notifies State Changes / UI States| UI_Layer
    State_Layer -->|Reads & Emits| Domain_Layer
    State_Layer -->|Async Invocations| Service_Layer
    Service_Layer -->|Translates Exceptions & Maps DTOs| Domain_Layer
    Service_Layer -->|Network / Cloud Requests| External_Cloud

    style UI_Layer fill:#F3EBF8,stroke:#5E548E,stroke-width:2px
    style State_Layer fill:#EDE5F2,stroke:#463C75,stroke-width:2px
    style Domain_Layer fill:#FFFFFF,stroke:#797580,stroke-width:1.5px
    style Service_Layer fill:#E8F5E9,stroke:#4E8B65,stroke-width:2px
    style External_Cloud fill:#FFF9C4,stroke:#FBC02D,stroke-width:2px
```

---

## 3. End-to-End Sequence Diagram: Event Search, Registration & PDF Export

```mermaid
sequenceDiagram
    autonumber
    actor User as Sinh viên (Nguyễn Văn An)
    participant View as EventDetailScreen
    participant VM as EventDetailViewModel
    participant FireSvc as FirestoreService
    participant StorageSvc as StorageService
    participant AnalyticsSvc as AnalyticsService
    participant Cloud as Firebase Backend (Firestore & Storage)

    User->>View: Mở chi tiết sự kiện & bấm "Đăng ký tham gia"
    View->>VM: registerForEvent(eventId, userId)
    VM->>VM: emit(ScreenState.loading)
    VM-->>View: notifyListeners() (Hiển thị LoadingView spinner)

    VM->>FireSvc: createRegistrationTransaction(eventId, userId)
    FireSvc->>Cloud: Run Firestore atomic transaction (Check capacity & duplicate)
    Cloud-->>FireSvc: Transaction success (Returns TicketID: CE2026-083291)
    FireSvc-->>VM: TicketModel(id, token, qrCode)

    VM->>AnalyticsSvc: logEvent("register_event", {"event_id": eventId})
    AnalyticsSvc->>Cloud: Send Analytics payload to DebugView

    VM->>StorageSvc: generateAndUploadTicketPdf(ticketModel, userId)
    StorageSvc->>Cloud: Upload PDF to reports/{uid}/ticket_CE2026.pdf
    Cloud-->>StorageSvc: Download URL: https://firebasestorage...
    StorageSvc-->>VM: downloadUrl

    VM->>VM: emit(ScreenState.data(ticket, downloadUrl))
    VM-->>View: notifyListeners() (Chuyển sang RegistrationSuccessScreen)
    View-->>User: Hiển thị Vé QR hợp lệ + Nút "Tải PDF Vé"
```

---

## 4. ViewModel to Services Injection Matrix

| ViewModel | File Location | Injected Services Used | Primary Responsibilities & Business Logic |
| :--- | :--- | :--- | :--- |
| **AuthViewModel** | `lib/viewmodels/auth_viewmodel.dart` | `AuthService`, `AnalyticsService`, `CrashlyticsService` | User authentication status, Google Sign-In orchestration, session purge on logout |
| **HomeViewModel** | `lib/viewmodels/home_viewmodel.dart` | `FirestoreService`, `RemoteConfigService`, `AnalyticsService` | Fetch featured & upcoming events, apply `max_featured_events` threshold from Remote Config |
| **ExploreViewModel** | `lib/viewmodels/explore_viewmodel.dart`| `FirestoreService`, `AnalyticsService` | Real-time category filtering (Tech, Sports, Club, Workshop), search keyword matching |
| **EventDetailViewModel**| `lib/viewmodels/event_detail_vm.dart` | `FirestoreService`, `AnalyticsService`, `CrashlyticsService` | Load full event specs, speaker profiles, validate registration eligibility (`BR-001..004`) |
| **RegistrationViewModel**| `lib/viewmodels/registration_vm.dart` | `FirestoreService`, `StorageService`, `AnalyticsService` | Execute 1-Tap registration, ticket generation with dynamic token, upload PDF certificate |
| **MyTicketsViewModel** | `lib/viewmodels/my_tickets_vm.dart` | `FirestoreService`, `CrashlyticsService` | User ticket ledger (Upcoming, Checked-in, Expired), offline cache persistence |
| **LiveEventViewModel** | `lib/viewmodels/live_event_vm.dart` | `FirestoreService`, `AnalyticsService` | Realtime listener on live agenda, submit speaker questions, atomic upvoting |
| **FeedbackViewModel** | `lib/viewmodels/feedback_vm.dart` | `FirestoreService`, `StorageService`, `AnalyticsService` | Validate 5-star ratings, submit feedback reviews, grant FPTU Activity Points (`+5 ĐRL`) |
| **ProfileViewModel** | `lib/viewmodels/profile_viewmodel.dart`| `AuthService`, `StorageService`, `RemoteConfigService`, `CrashlyticsService`, `FCMService` | Manage student profile, host **Firebase Demo Area** (FCM notifications, test crash, export PDF, remote config toggles) |
| **MobileDeskViewModel** | `lib/viewmodels/mobile_desk_vm.dart` | `FirestoreService`, `CrashlyticsService`, `AnalyticsService` | High-speed QR token validation, detect duplicate scans, manual Ticket ID fallback, live gate counter |

---

## 5. Architectural Compliance & Strict Grading Rules

1. **Strict Dependency Decoupling:**
   - No widget in `lib/screens/` or `lib/widgets/` imports or references `http`, `FirebaseAuth`, `FirebaseFirestore`, `FirebaseStorage`, `FirebaseMessaging`, `FirebaseAnalytics`, or `FirebaseCrashlytics`.
   - All cloud SDK calls are encapsulated strictly within `lib/services/` and `lib/firebase/`.
2. **Explicit Screen State Modeling:**
   - Every data-driven screen binds to a dedicated state model:
     ```dart
     sealed class ScreenState<T> {
       const ScreenState();
     }
     class StateInitial<T> extends ScreenState<T> { const StateInitial(); }
     class StateLoading<T> extends ScreenState<T> { const StateLoading(); }
     class StateData<T> extends ScreenState<T> { final T data; const StateData(this.data); }
     class StateEmpty<T> extends ScreenState<T> { final String message; const StateEmpty(this.message); }
     class StateError<T> extends ScreenState<T> { final String error; const StateError(this.error); }
     ```
3. **Dependency Injection & Testability:**
   - All ViewModels receive their service dependencies via constructor injection. In production, dependencies are supplied via `MultiProvider` in `lib/main.dart`; in automated tests, fake/mock services are injected without touching real network sockets.
4. **Business Logic Isolation:**
   - All filtering, data aggregation, eligibility checks, and form validations are implemented inside ViewModels or Services, ensuring `build()` methods in widgets remain strictly declarative and side-effect free.

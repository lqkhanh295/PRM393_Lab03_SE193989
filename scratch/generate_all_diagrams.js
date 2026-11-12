const fs = require('fs');
const path = require('path');
const { DiagramBuilder, escapeXml } = require('./diagram_builder');

// =========================================================================
// SLIDE 07: BUSINESS FLOW (BPMN / Activity with 4 Swimlanes & BR Rules)
// =========================================================================
function buildSlide07BusinessFlow() {
  const d = new DiagramBuilder('07_Business_Flow', 1450, 1000);
  d.addTitle(
    '07. BUSINESS FLOW — LUỒNG NGHIỆP VỤ TỔNG THỂ HỆ THỐNG',
    'Phối hợp 4 tác nhân: Sinh viên ➔ Hệ thống Cloud/Mobile ➔ Cán bộ CTSV (Duyệt vé Slide 18) ➔ Ban Soát vé Cổng',
    'SLIDE 07 • BUSINESS FLOW'
  );

  // 4 Swimlanes
  const laneStudent = d.addSwimlane({ x: 40, y: 100, w: 320, h: 860, title: 'SINH VIÊN (MOBILE APP)', subtitle: 'Tài khoản Email FPT (@fpt.edu.vn)', colorTheme: 'blue' });
  const laneSystem = d.addSwimlane({ x: 380, y: 100, w: 340, h: 860, title: 'HỆ THỐNG (MOBILE VM & FIRESTORE)', subtitle: 'Atomic Engine, Rule Check & FCM Gateway', colorTheme: 'slate' });
  const laneCTSV = d.addSwimlane({ x: 740, y: 100, w: 330, h: 860, title: 'CÁN BỘ CTSV (WEB ADMIN PORTAL)', subtitle: 'Hàng chờ thẩm định đơn đăng ký & cấp vé', colorTheme: 'purple' });
  const laneGate = d.addSwimlane({ x: 1090, y: 100, w: 320, h: 860, title: 'BAN SOÁT VÉ / CTV CỔNG', subtitle: 'MobileDesk Scanner viễn trắc thời gian thực', colorTheme: 'emerald' });

  // Nodes in Lane 1 (Student)
  const nStart = d.addBox({
    parent: laneStudent, x: 30, y: 60, w: 260, h: 55,
    title: '1. Khởi động & Đăng nhập',
    subtitle: 'Đăng nhập Google SSO / Email FPT',
    details: ['Xác thực định danh sinh viên FPT'],
    colorTheme: 'blue'
  });

  const nSelectEvent = d.addBox({
    parent: laneStudent, x: 30, y: 140, w: 260, h: 60,
    title: '2. Duyệt & Chọn Sự kiện',
    subtitle: 'Màn hình Explore / Danh sách sự kiện',
    details: ['Xem ngày giờ, địa điểm, số chỗ còn lại'],
    colorTheme: 'blue'
  });

  const nSubmitReg = d.addBox({
    parent: laneStudent, x: 30, y: 230, w: 260, h: 60,
    title: '3. Bấm "Đăng ký tham gia"',
    subtitle: 'Mở Registration Modal',
    details: ['Xác nhận MSSV, họ tên, email, CLB tổ chức'],
    colorTheme: 'blue'
  });

  // Nodes in Lane 2 (System Verification)
  const nCheckBR03 = d.addBox({
    parent: laneSystem, x: 30, y: 230, w: 280, h: 70,
    title: '4. Kiểm tra Thời hạn Sự kiện [BR-03]',
    subtitle: 'Guard: DateTime.now() <= event.date',
    details: ['Chặn đăng ký nếu sự kiện đã trong quá khứ'],
    colorTheme: 'amber'
  });

  const nCheckBR02 = d.addBox({
    parent: laneSystem, x: 30, y: 330, w: 280, h: 70,
    title: '5. Kiểm tra Sức chứa & Hạn mức [BR-02]',
    subtitle: 'Guard: registeredCount < capacity',
    details: ['Đảm bảo không vượt quá sức chứa hội trường'],
    colorTheme: 'amber'
  });

  const nCreatePending = d.addBox({
    parent: laneSystem, x: 30, y: 430, w: 280, h: 65,
    title: '6. Lưu Đơn Xét Duyệt (Pending)',
    subtitle: 'Ghi Firestore: registrations/{regId}',
    details: ['Status: "pending" • Bắn Snapshot Stream'],
    colorTheme: 'purple'
  });

  // Nodes in Lane 3 (CTSV Review - Slide 18)
  const nReviewQueue = d.addBox({
    parent: laneCTSV, x: 25, y: 430, w: 280, h: 65,
    title: '7. Nhận Đơn trên Hàng Chờ (Slide 18)',
    subtitle: 'Web Admin Portal: Tab Hàng chờ duyệt vé',
    details: ['Real-time badge (+1) hiển thị tức thì'],
    colorTheme: 'purple'
  });

  const nDecision = d.addBox({
    parent: laneCTSV, x: 25, y: 525, w: 280, h: 75,
    title: '8. Thẩm định & Ra Quyết định [BR-04]',
    subtitle: 'Kiểm tra tư cách sinh viên & hồ sơ CLB',
    details: ['Nhánh A: Phê duyệt (Approve) ➔ Cấp vé', 'Nhánh B: Từ chối (Reject) ➔ Nhập lý do'],
    colorTheme: 'amber'
  });

  // Issue Ticket (System)
  const nIssueTicket = d.addBox({
    parent: laneSystem, x: 30, y: 620, w: 280, h: 75,
    title: '9. Phát hành Vé & Sinh Mã QR [BR-04]',
    subtitle: 'Atomic Transaction Cloud Firestore',
    details: ['Tạo tickets/{ticketId} • qrToken bí mật', 'FCM Push Notification: "Vé của bạn đã sẵn sàng"'],
    colorTheme: 'green'
  });

  // Receive Ticket (Student)
  const nReceiveTicket = d.addBox({
    parent: laneStudent, x: 30, y: 620, w: 260, h: 75,
    title: '10. Nhận Vé trong Tab "Sắp diễn ra"',
    subtitle: 'DigitalTicketScreen hiển thị mã QR',
    details: ['Vé hợp lệ, sẵn sàng xuất trình tại cổng'],
    colorTheme: 'green'
  });

  // Gate Check-in (Lane 4)
  const nScanGate = d.addBox({
    parent: laneGate, x: 20, y: 620, w: 280, h: 75,
    title: '11. Quét QR tại Bàn Soát Vé',
    subtitle: 'MobileDesk Camera Scanner (< 1.5s/lượt)',
    details: ['Đối chiếu qrToken với Firestore Ticket Record'],
    colorTheme: 'emerald'
  });

  const nValidateQR = d.addBox({
    parent: laneGate, x: 20, y: 725, w: 280, h: 75,
    title: '12. Xác thực Hợp lệ [BR-05]',
    subtitle: 'Guard: qrValid && !isUsed',
    details: ['Nhánh ĐÚNG: Check-in thành công ➔ Đổi isUsed:true', 'Nhánh SAI: Báo động Vé giả mạo / Đã qua sử dụng'],
    colorTheme: 'amber'
  });

  // Post Check-in (Student)
  const nFeedbackReward = d.addBox({
    parent: laneStudent, x: 30, y: 820, w: 260, h: 80,
    title: '13. Đánh giá & Nhận Điểm Rèn Luyện',
    subtitle: 'Mở khóa Feedback Screen [BR-06]',
    details: ['Đánh giá 1-5 sao ➔ +5 Điểm rèn luyện', 'Xuất chứng nhận e-Certificate PDF [BR-07]'],
    colorTheme: 'green'
  });

  // Connectors
  d.addConnection({ source: nStart, target: nSelectEvent, label: 'Khám phá sự kiện' });
  d.addConnection({ source: nSelectEvent, target: nSubmitReg, label: 'Chọn sự kiện' });
  d.addConnection({ source: nSubmitReg, target: nCheckBR03, label: 'Gửi yêu cầu' });
  d.addConnection({ source: nCheckBR03, target: nCheckBR02, label: 'Hợp lệ [BR-03]' });
  d.addConnection({ source: nCheckBR02, target: nCreatePending, label: 'Còn chỗ [BR-02]' });
  d.addConnection({ source: nCreatePending, target: nReviewQueue, label: 'Realtime Sync (Slide 18)' });
  d.addConnection({ source: nReviewQueue, target: nDecision, label: 'Thẩm định' });
  d.addConnection({ source: nDecision, target: nIssueTicket, label: 'Duyệt đơn [BR-04]', color: '#059669', strokeWidth: 2 });
  d.addConnection({ source: nIssueTicket, target: nReceiveTicket, label: 'FCM Push & Stream', color: '#059669' });
  d.addConnection({ source: nReceiveTicket, target: nScanGate, label: 'Xuất trình QR tại cổng', color: '#2563eb' });
  d.addConnection({ source: nScanGate, target: nValidateQR, label: 'Quét token' });
  d.addConnection({ source: nValidateQR, target: nFeedbackReward, label: 'Check-in thành công [BR-05]', color: '#059669', strokeWidth: 2 });

  // Floating Business Rules Summary Box
  d.addBox({
    x: 40, y: 970, w: 1370, h: 50,
    title: 'QUY TẮC NGHIỆP VỤ (BUSINESS RULES) GẮN TRÊN LUỒNG:',
    subtitle: 'BR-01: Định danh email @fpt.edu.vn • BR-02: Giới hạn sức chứa hội trường • BR-03: Không đăng ký sự kiện quá khứ • BR-04: Cán bộ CTSV phê duyệt mới cấp vé (Slide 18) • BR-05: Chống tái quét vé (Single check-in) • BR-06: Check-in xong mới được đánh giá & nhận +5 điểm • BR-07: e-Certificate PDF có chữ ký băm.',
    colorTheme: 'slate', rx: 4
  });

  return d;
}

// =========================================================================
// SLIDE 08: STATE MACHINE (Vòng đời Vé, Đơn đăng ký & Sự kiện)
// =========================================================================
function buildSlide08StateMachine() {
  const d = new DiagramBuilder('08_State_Machine', 1450, 950);
  d.addTitle(
    '08. STATE MACHINE DIAGRAM — VÒNG ĐỜI THỰC THỂ KINH DOANH CHÍNH',
    'Đặc tả State, Event, Guard, Action và Các Chuyển Trạng Thái Bị Cấm (Forbidden Transitions)',
    'SLIDE 08 • STATE MACHINE'
  );

  // Group 1: Registration State Machine (Slide 18)
  d.addBox({
    x: 40, y: 100, w: 650, h: 420,
    title: 'VÒNG ĐỜI ĐƠN ĐĂNG KÝ (REGISTRATION LIFECYCLE - SLIDE 18)',
    subtitle: 'Quản lý yêu cầu từ lúc sinh viên nộp đơn đến khi hoàn tất thẩm định',
    colorTheme: 'blue'
  });

  const rStart = d.addBox({ x: 70, y: 180, w: 140, h: 50, title: '[*] Khởi tạo', subtitle: 'Sinh viên chọn sự kiện', colorTheme: 'slate' });
  const rPending = d.addBox({ x: 260, y: 180, w: 180, h: 70, title: 'PENDING (Chờ duyệt)', subtitle: 'Đang nằm trên Hàng chờ', details: ['Khóa chỉnh sửa thông tin', 'Chờ cán bộ CTSV review'], colorTheme: 'amber' });
  const rApproved = d.addBox({ x: 500, y: 150, w: 160, h: 65, title: 'APPROVED (Đã duyệt)', subtitle: 'Đạt điều kiện tham dự', details: ['Trigger tạo Vé điện tử'], colorTheme: 'green' });
  const rRejected = d.addBox({ x: 500, y: 270, w: 160, h: 65, title: 'REJECTED (Từ chối)', subtitle: 'Không đạt tiêu chí', details: ['Lưu lý do từ chối cụ thể'], colorTheme: 'red' });

  d.addConnection({ source: rStart, target: rPending, label: 'submit() [BR-02 && BR-03]' });
  d.addConnection({ source: rPending, target: rApproved, label: 'approve() [BR-04] / issueTicket()', color: '#059669', strokeWidth: 2 });
  d.addConnection({ source: rPending, target: rRejected, label: 'reject(reason) / notifyUser()', color: '#dc2626' });

  // Group 2: Digital Ticket State Machine (Core Entity)
  d.addBox({
    x: 720, y: 100, w: 690, h: 420,
    title: 'VÒNG ĐỜI VÉ ĐIỆN TỬ (DIGITAL TICKET LIFECYCLE - CORE ENTITY)',
    subtitle: 'Thực thể kiểm soát an ninh cổng, điểm danh và tích lũy điểm rèn luyện',
    colorTheme: 'green'
  });

  const tIssued = d.addBox({ x: 750, y: 170, w: 170, h: 70, title: 'ISSUED (Đã phát hành)', subtitle: 'Tab "Sắp diễn ra"', details: ['isUsed = false', 'Mã QR hoạt động'], colorTheme: 'blue' });
  const tUsed = d.addBox({ x: 970, y: 170, w: 180, h: 70, title: 'USED (Đã check-in)', subtitle: 'Tab "Đã tham gia"', details: ['isUsed = true', 'Ghi checkedInAt: now'], colorTheme: 'green' });
  const tExpired = d.addBox({ x: 750, y: 310, w: 170, h: 70, title: 'EXPIRED (Quá hạn)', subtitle: 'Không đến dự', details: ['Sự kiện đã kết thúc', 'Khóa quét QR'], colorTheme: 'slate' });
  const tFeedback = d.addBox({ x: 1200, y: 170, w: 180, h: 70, title: 'FEEDBACK_DONE', subtitle: 'Hoàn thành đánh giá', details: ['activityPoints += 5', 'Mở khóa tải e-Cert'], colorTheme: 'purple' });

  d.addConnection({ source: tIssued, target: tUsed, label: 'scanQR() [valid && !isUsed BR-05] / openGate()', color: '#059669', strokeWidth: 2 });
  d.addConnection({ source: tIssued, target: tExpired, label: 'timeout() [eventEnded && !isUsed]', color: '#64748b' });
  d.addConnection({ source: tUsed, target: tFeedback, label: 'submitFeedback() [BR-06] / addPoints(+5)', color: '#7c3aed', strokeWidth: 2 });

  // Group 3: Event Operational State Machine
  d.addBox({
    x: 40, y: 550, w: 650, h: 360,
    title: 'TRẠNG THÁI VẬN HÀNH SỰ KIỆN (EVENT OPERATIONAL STATUS)',
    subtitle: 'Đồng bộ thời gian thực theo DateTime.now() và khung giờ tổ chức',
    colorTheme: 'purple'
  });

  const eUpcoming = d.addBox({ x: 70, y: 640, w: 160, h: 65, title: 'UPCOMING (Sắp diễn ra)', subtitle: 'now < startDate', details: ['Mở đăng ký vé [BR-03]'], colorTheme: 'blue' });
  const eHappening = d.addBox({ x: 280, y: 640, w: 170, h: 65, title: 'HAPPENING (Đang diễn ra)', subtitle: 'startDate <= now <= endDate', details: ['Mở cổng soát vé MobileDesk', 'Live Companion Q&A'], colorTheme: 'green' });
  const eCompleted = d.addBox({ x: 490, y: 640, w: 170, h: 65, title: 'COMPLETED (Đã diễn ra)', subtitle: 'now > endDate', details: ['Đóng cổng soát vé', 'Tổng kết viễn trắc'], colorTheme: 'slate' });

  d.addConnection({ source: eUpcoming, target: eHappening, label: 'timeReached() / openDeskGate()' });
  d.addConnection({ source: eHappening, target: eCompleted, label: 'eventFinished() / closeDeskGate()' });

  // Group 4: FORBIDDEN TRANSITIONS BOX (BẮT BUỘC THEO SLIDE 08 GUIDELINE)
  d.addBox({
    x: 720, y: 550, w: 690, h: 360,
    title: 'CÁC CHUYỂN TRẠNG THÁI BỊ CẤM & RÀNG BUỘC TOÀN VẸN (FORBIDDEN TRANSITIONS)',
    subtitle: 'Bắt buộc kiểm thử tự động (Unit Test / Integration Test) để ngăn chặn lỗ hổng bảo mật',
    details: [
      '❌ CẤM: PENDING ➔ USED — Đơn chưa được CTSV duyệt tuyệt đối không được phép soát vé vào cổng.',
      '❌ CẤM: USED ➔ ISSUED — Vé đã check-in không được phép hoàn lại trạng thái chưa quét (Chống tấn công Replay Attack).',
      '❌ CẤM: EXPIRED ➔ USED — Vé của sự kiện đã kết thúc trong quá khứ không được phép check-in.',
      '❌ CẤM: PENDING ➔ FEEDBACK_DONE — Sinh viên chưa tham dự sự kiện không được phép gửi đánh giá hay nhận điểm.',
      '❌ CẤM: DRAFT ➔ APPROVED — Phải đi qua hàng chờ PENDING để có vết kiểm toán (Audit Trail) của cán bộ CTSV.',
      '🔒 BẢO VỆ ATOMIC: Mọi thao tác đổi trạng thái vé và duyệt đơn đều chạy qua Firestore RunTransaction bảo đảm tính nhất quán cao.'
    ],
    colorTheme: 'red'
  });

  return d;
}

// =========================================================================
// SLIDE 09: SYSTEM ARCHITECTURE (C4 Container & Deployment)
// =========================================================================
function buildSlide09SystemArchitecture() {
  const d = new DiagramBuilder('09_System_Architecture', 1450, 1000);
  d.addTitle(
    '09. SYSTEM ARCHITECTURE — KIẾN TRÚC HỆ THỐNG & NƠI TRIỂN KHAI',
    'Mô hình C4 Container: Client Presentation Layer ➔ Business Service Layer ➔ Google Firebase Cloud Backend',
    'SLIDE 09 • SYSTEM ARCHITECTURE'
  );

  // Layer 1: Client Layer
  d.addBox({
    x: 40, y: 100, w: 1370, h: 220,
    title: 'TẦNG GIAO DIỆN & TRẢI NGHIỆM KHÁCH (CLIENT PRESENTATION LAYER)',
    subtitle: 'Đa nền tảng: Ứng dụng Di động Native (Sinh viên, CTV) & Cổng Quản trị Web Desktop (Cán bộ CTSV)',
    colorTheme: 'blue'
  });

  const cMobile = d.addBox({
    x: 70, y: 155, w: 630, h: 140,
    title: '📱 Mobile Client — Flutter 3.24 / Dart 3.5 (iOS & Android)',
    subtitle: 'Kiến trúc MVVM sạch, phân tách giao diện và trạng thái dữ liệu (Provider Pattern)',
    details: [
      'Screens: HomeScreen, ExploreScreen, EventDetailScreen, DigitalTicketScreen, LiveCompanionScreen, MobileDeskScreen',
      'State Management: AuthViewModel, ExploreViewModel, RegistrationViewModel, MyTicketsViewModel, LiveEventViewModel',
      'Hardware Access: Camera Scanner QR (1.5s/lượt), Push Notifications (FCM), Local Storage Cache'
    ],
    colorTheme: 'blue'
  });

  const cWeb = d.addBox({
    x: 730, y: 155, w: 650, h: 140,
    title: '💻 Desktop Web Admin Portal — Vanilla JS / Modern CSS / Node.js Express Bridge (Port 3000)',
    subtitle: 'Hệ thống bảng điều khiển trung tâm dành cho Cán bộ Phòng Chăm sóc Sinh viên (CTSV)',
    details: [
      '9 Module Chuyên Sâu: Live KPI Monitor, Hàng chờ duyệt vé (Slide 18), Thẩm định ngân sách CLB, An toàn hội trường',
      'Realtime Telemetry: Bảng đối chiếu tiến độ check-in, giám sát lưu lượng vào cổng theo giây, quản lý sự kiện',
      'Bảo mật: Google Identity Token, Session Cookie, REST API Bridge tự động refresh token định danh'
    ],
    colorTheme: 'purple'
  });

  // Layer 2: Business Service Layer
  d.addBox({
    x: 40, y: 350, w: 1370, h: 180,
    title: 'TẦNG DỊCH VỤ & NGHIỆP VỤ HỆ THỐNG (BUSINESS SERVICE LAYER - LIB/SERVICES/)',
    subtitle: 'Tập trung toàn bộ logic nghiệp vụ độc lập, đóng gói REST API và SDK giao tiếp',
    colorTheme: 'slate'
  });

  const sAuth = d.addBox({ x: 60, y: 405, w: 230, h: 105, title: 'AuthService', subtitle: 'Google SSO & Mail FPT', details: ['Enforce @fpt.edu.vn', 'Firebase Auth Token', 'User state sync'], colorTheme: 'blue' });
  const sFirestore = d.addBox({ x: 310, y: 405, w: 260, h: 105, title: 'FirestoreService', subtitle: 'Atomic Transaction Engine', details: ['runTransaction: Check-in', 'Snapshot streams', 'Zero-mock policy'], colorTheme: 'green' });
  const sStorage = d.addBox({ x: 590, y: 405, w: 240, h: 105, title: 'StorageService', subtitle: 'Cloud Storage Handler', details: ['Upload PDF e-Cert', 'Path: reports/{uid}/', 'Signed download URL'], colorTheme: 'amber' });
  const sFCM = d.addBox({ x: 850, y: 405, w: 260, h: 105, title: 'FCMService & RemoteConfig', subtitle: 'Cloud Messaging & Config', details: ['Push thông báo duyệt vé', 'Topic broadcast', 'max_featured_events flag'], colorTheme: 'purple' });
  const sGemini = d.addBox({ x: 1130, y: 405, w: 250, h: 105, title: 'GeminiAiService', subtitle: 'Google GenAI Flash 1.5', details: ['Multi-key pool (10 keys)', 'Round-robin failover', 'Phân tích phản hồi sinh viên'], colorTheme: 'purple' });

  // Layer 3: Cloud Infrastructure Backend
  d.addBox({
    x: 40, y: 560, w: 1370, h: 220,
    title: 'HẠ TẦNG ĐÁM MÂY GOOGLE FIREBASE (CLOUD BACKEND - PROJECT: CAMPUS-EVENT-48443)',
    subtitle: 'Toàn bộ dữ liệu vận hành thực tế 100% trên đám mây Google Cloud Platform (GCP)',
    colorTheme: 'green'
  });

  const bAuth = d.addBox({ x: 60, y: 615, w: 250, h: 140, title: 'Firebase Authentication', subtitle: 'Identity Toolkit & OAuth2', details: ['Đăng nhập tài khoản trường FPT', 'Xác thực hai lớp qua Google', 'Cấp JWT Token định danh'], colorTheme: 'blue' });
  const bFirestore = d.addBox({ x: 330, y: 615, w: 450, h: 140, title: 'Cloud Firestore (NoSQL Document Database)', subtitle: 'Multi-Region High Availability & Sub-second Query', details: ['Collections: events, tickets, registrations, clubs, feedback, certificates, announcements', 'Compound Indexes: Lọc vé theo sinh viên và trạng thái check-in', 'Security Rules: Phân quyền truy cập tài liệu nghiêm ngặt'], colorTheme: 'green' });
  const bStorage = d.addBox({ x: 800, y: 615, w: 280, h: 140, title: 'Firebase Cloud Storage', subtitle: 'Bảo mật lưu trữ chứng nhận số', details: ['Lưu trữ PDF e-Certificate SHA-256', 'Quy tắc bảo mật theo UID người dùng', 'Hỗ trợ tải ngoại tuyến'], colorTheme: 'amber' });
  const bFCM = d.addBox({ x: 1100, y: 615, w: 280, h: 140, title: 'FCM & Crashlytics / Analytics', subtitle: 'Hệ thống vận hành viễn trắc', details: ['FCM Push Gateway độ trễ thấp', 'Crashlytics bắt lỗi Crash thời gian thực', 'Google Analytics DebugView'], colorTheme: 'purple' });

  // Layer 4: Architectural Decisions Box
  d.addBox({
    x: 40, y: 805, w: 1370, h: 160,
    title: 'CÁC QUYẾT ĐỊNH KIẾN TRÚC & ĐÁNH ĐỔI (ARCHITECTURAL DECISIONS & TRADE-OFFS):',
    subtitle: 'Lựa chọn công nghệ phục vụ trực tiếp cho tiêu chí vận hành thực tế của Đại học FPT TP.HCM',
    details: [
      '1. Quyết định chọn Cloud Firestore NoSQL thay vì RDBMS truyền thống: Đạt tốc độ truy vấn sub-second (< 1.5s khi quét vé tại cổng), snapshot stream tự động đẩy dữ liệu tức thì giữa điện thoại sinh viên và cổng soát vé. Đánh đổi: Cần thiết kế cấu trúc dữ liệu phẳng hóa, hạn chế join nhiều bảng.',
      '2. Quyết định mô hình MVVM + Provider trên Flutter: Tách biệt hoàn toàn tầng hiển thị khỏi nghiệp vụ, giúp mã nguồn dễ bảo trì, dễ viết kiểm thử tự động (đạt 21/21 Unit/Widget Tests pass 100%), không gây re-render thừa.',
      '3. Cơ chế Multi-Key Round Robin cho Gemini AI: Sử dụng bể 10 API Key chính thức kèm tự động xoay tua khi gặp lỗi HTTP 429 Quota Exceeded, đảm bảo hệ sinh thái AI hoạt động liên tục không gián đoạn.'
    ],
    colorTheme: 'slate', rx: 4
  });

  return d;
}

// =========================================================================
// SLIDE 10: TECHNOLOGY STACK (Bảng công nghệ theo nhóm chuẩn Slide 10)
// =========================================================================
function buildSlide10TechStack() {
  const d = new DiagramBuilder('10_Technology_Stack', 1450, 950);
  d.addTitle(
    '10. TECHNOLOGY STACK — BẢNG CÔNG NGHỆ THEO NHÓM VÀ VAI TRÒ SỬ DỤNG',
    'Khớp 100% mã nguồn thực tế và môi trường triển khai của dự án Campus Event Management',
    'SLIDE 10 • TECHNOLOGY STACK'
  );

  const cardWidth = 430;
  const cardHeight = 220;

  // 1. Mobile Frontend
  d.addBox({
    x: 40, y: 100, w: cardWidth, h: cardHeight,
    title: '📱 1. MOBILE APPLICATION',
    subtitle: 'Ứng dụng di động sinh viên và CTV cổng',
    details: [
      'Công nghệ: Flutter 3.24 SDK & Dart 3.5',
      'State Management: Provider (MVVM Pattern)',
      'UI Kit: Material Design 3, Glassmorphism, Google Fonts',
      'Phần cứng: Mobile Scanner (Camera QR), Image Picker',
      'Lý do chọn: Biên dịch Native mượt mà 60 FPS, chia sẻ 100% logic giữa Android và iOS.'
    ],
    colorTheme: 'blue'
  });

  // 2. Web Admin Portal
  d.addBox({
    x: 510, y: 100, w: cardWidth, h: cardHeight,
    title: '💻 2. WEB ADMIN PORTAL',
    subtitle: 'Cổng quản trị chuyên sâu dành cho Cán bộ CTSV',
    details: [
      'Công nghệ: Vanilla JavaScript ES6+, Modern CSS3, HTML5',
      'Server Bridge: Node.js Express Bridge (Port 3000)',
      'Giao diện: 9 Phân hệ viễn trắc (Live Telemetry Dashboard)',
      'Tích hợp: Firestore REST API, Real-time Polling & Push',
      'Lý do chọn: Siêu nhẹ, tải trang tức thì trên máy tính bàn soát vé, không phụ thuộc nặng nề vào build tools.'
    ],
    colorTheme: 'purple'
  });

  // 3. Backend & Cloud Database
  d.addBox({
    x: 980, y: 100, w: cardWidth, h: cardHeight,
    title: '☁️ 3. BACKEND & CLOUD PLATFORM',
    subtitle: 'Nền tảng điện toán đám mây Google Cloud / Firebase',
    details: [
      'Cơ sở dữ liệu: Cloud Firestore (NoSQL Document Store)',
      'Định danh: Firebase Authentication (Google SSO, FPT Mail)',
      'Lưu trữ tệp: Firebase Cloud Storage (PDF e-Certificates)',
      'Thông báo: Firebase Cloud Messaging (FCM Push)',
      'Lý do chọn: Đạt SLA 99.99%, real-time synchronization không cần duy trì máy chủ socket phức tạp.'
    ],
    colorTheme: 'green'
  });

  // 4. AI & Machine Learning
  d.addBox({
    x: 40, y: 350, w: cardWidth, h: cardHeight,
    title: '🤖 4. AI & AUTOMATION ENGINE',
    subtitle: 'Trí tuệ nhân tạo hỗ trợ phân tích và giải đáp',
    details: [
      'Mô hình: Google Gemini 1.5 Flash API (Google GenAI)',
      'Giao thức: Google REST Generative Language Endpoints',
      'Kiến trúc: Multi-Key Round Robin Pool (10 Official API Keys)',
      'Nhiệm vụ: Phân tích đánh giá sinh viên, gợi ý sự kiện phù hợp, phân loại câu hỏi Q&A trực tiếp',
      'Lý do chọn: Tốc độ suy luận dưới 1 giây, phản hồi tiếng Việt chuẩn xác.'
    ],
    colorTheme: 'purple'
  });

  // 5. Developer Tools & DevOps
  d.addBox({
    x: 510, y: 350, w: cardWidth, h: cardHeight,
    title: '🛠️ 5. DEVELOPER TOOLS & DEVOPS',
    subtitle: 'Công cụ phát triển, kiểm soát phiên bản & CI/CD',
    details: [
      'Kiểm soát phiên bản: Git & GitHub Repository',
      'IDE & Môi trường: Visual Studio Code, Antigravity Agentic IDE',
      'Thiết kế kiến trúc: Draw.io / diagrams.net, Mermaid UML',
      'API Testing: Postman, Firebase Emulator Suite',
      'Lý do chọn: Tiêu chuẩn hóa quy trình phát triển, dễ dàng kiểm tra vết thay đổi mã nguồn.'
    ],
    colorTheme: 'slate'
  });

  // 6. Testing & Quality Assurance
  d.addBox({
    x: 980, y: 350, w: cardWidth, h: cardHeight,
    title: '🧪 6. TESTING & QUALITY ASSURANCE',
    subtitle: 'Hệ thống kiểm thử tự động & giám sát lỗi thực tế',
    details: [
      'Framework: Flutter Test Suite (package:test, flutter_test)',
      'Độ bao phủ: 21/21 Unit & Widget Tests passed 100%',
      'Chính sách: Strict Zero-Mock Data Policy (Truy vấn Cloud thật)',
      'Giám sát: Firebase Crashlytics & Google Analytics DebugView',
      'Lý do chọn: Đảm bảo không xảy ra hồi quy lỗi (regression), kiểm soát nghiêm ngặt các quy tắc nghiệp vụ.'
    ],
    colorTheme: 'amber'
  });

  // Summary Table Bar
  d.addBox({
    x: 40, y: 600, w: 1370, h: 320,
    title: 'TỔNG HỢP ÁNH XẠ CÔNG NGHỆ ↔ TRÁCH NHIỆM TRONG DỰ ÁN (TRACEABILITY MATRIX)',
    subtitle: 'Chứng minh mọi công nghệ sử dụng đều giải quyết trực tiếp một nhu cầu thực tế của đề tài',
    details: [
      '• Flutter / Dart: Xây dựng UI phản hồi nhanh cho sinh viên tra cứu và nhận diện mã QR chỉ trong 1.5 giây.',
      '• Cloud Firestore: Lưu trữ 7 tập tài liệu (events, tickets, registrations, clubs, feedback, certificates, questions) với ACID Transactions.',
      '• Firebase Auth: Khóa chặt phạm vi truy cập nội bộ trường, chỉ chấp nhận đuôi email @fpt.edu.vn hoặc @fe.edu.vn.',
      '• Firebase Cloud Storage: Cung cấp kho lưu trữ an toàn cho file PDF chứng nhận theo đường dẫn tiêu chuẩn reports/{uid}/...',
      '• Firebase Remote Config: Thay đổi linh hoạt số lượng sự kiện nổi bật hiển thị (2 ↔ 5 sự kiện) từ xa mà không cần build lại app.',
      '• Google Gemini API: Tự động tổng hợp insight từ hàng trăm phản hồi sinh viên gửi về sau sự kiện phục vụ báo cáo CTSV.',
      '• Node.js Portal Server: Làm cầu nối bảo mật giữa Web Dashboard quản trị và hạ tầng đám mây Google.'
    ],
    colorTheme: 'slate'
  });

  return d;
}

// =========================================================================
// SLIDE 12: SEQUENCE DIAGRAM (Slide 18 & Check-In Cổng)
// =========================================================================
function buildSlide12SequenceDiagram() {
  const d = new DiagramBuilder('12_Sequence_Diagram', 1450, 1000);
  d.addTitle(
    '12. SEQUENCE DIAGRAM — QUY TRÌNH DUYỆT VÉ SLIDE 18 & CHECK-IN CỔNG',
    'Tương tác tuần tự chi tiết giữa Sinh viên, ViewModel, FirestoreService, Web Admin và Bàn soát vé',
    'SLIDE 12 • SEQUENCE DIAGRAM'
  );

  // Lifelines
  const actors = [
    { id: 'act_student', name: 'Sinh viên An\n(:Student)', x: 60 },
    { id: 'act_ui', name: 'Giao diện\n(:EventDetailScreen)', x: 230 },
    { id: 'act_vm', name: 'Bộ điều khiển\n(:RegistrationVM)', x: 420 },
    { id: 'act_svc', name: 'Dịch vụ\n(:FirestoreService)', x: 620 },
    { id: 'act_db', name: '<<Cloud>>\n:CloudFirestore', x: 830 },
    { id: 'act_web', name: 'Cổng Web Admin\n(:WebAdminPortal)', x: 1040 },
    { id: 'act_desk', name: 'Máy quét cổng\n(:MobileDeskScanner)', x: 1250 }
  ];

  actors.forEach(a => {
    d.addBox({
      id: a.id, x: a.x, y: 100, w: 140, h: 50,
      title: a.name, subtitle: '', colorTheme: 'blue', rx: 4
    });

    // Lifeline vertical dashed line
    const lineId = d.nextId();
    d.cells.push(`
      <mxCell id="${lineId}" value="" style="endArrow=none;dashed=1;html=1;strokeWidth=1.5;strokeColor=#94a3b8;" edge="1" parent="1" source="${a.id}">
        <mxGeometry width="50" height="50" relative="1" as="geometry">
          <mxPoint x="${a.x + 70}" y="150" as="sourcePoint" />
          <mxPoint x="${a.x + 70}" y="920" as="targetPoint" />
        </mxGeometry>
      </mxCell>
    `);
  });

  // Sequence Steps as Horizontal Arrows and Text Calls
  const steps = [
    { y: 180, x1: 130, x2: 300, label: '1. tap "Đăng ký tham gia"()' },
    { y: 220, x1: 300, x2: 490, label: '2. submitPendingRegistration(event, user)' },
    { y: 260, x1: 490, x2: 690, label: '3. submitRegistration(RegistrationModel)' },
    { y: 300, x1: 690, x2: 900, label: '4. setDoc(registrations/{regId}, status: "pending")' },
    { y: 350, x1: 900, x2: 1110, label: '5. onSnapshot() [Real-time notification: +1 Đơn chờ duyệt]' },
    { y: 400, x1: 1110, x2: 1110, label: '6. Cán bộ CTSV xem xét hồ sơ trên Web Admin (Slide 18)' },
    { y: 450, x1: 1110, x2: 900, label: '7. approveRegistration(regId) ➔ runTransaction' },
    { y: 500, x1: 900, x2: 900, label: '8. update(status: "approved") & create(tickets/{ticketId})' },
    { y: 550, x1: 900, x2: 490, label: '9. Stream push: Vé mới về thiết bị' },
    { y: 600, x1: 490, x2: 300, label: '10. setState(StateSuccess) ➔ Hiển thị DigitalTicket' },
    { y: 650, x1: 130, x2: 1320, label: '11. Sinh viên xuất trình QR tại Bàn kiểm soát cổng' },
    { y: 700, x1: 1320, x2: 690, label: '12. checkInTicket(qrToken) ➔ runTransaction' },
    { y: 750, x1: 690, x2: 900, label: '13. Atomic update(isUsed: true, checkedInAt: now)' },
    { y: 800, x1: 900, x2: 1320, label: '14. Return 200 OK (< 1.5s): Mở cổng thành công' },
    { y: 850, x1: 900, x2: 300, label: '15. Mở khóa nút Feedback (+5 Điểm rèn luyện) trên Mobile' }
  ];

  steps.forEach((s, idx) => {
    const isSelf = s.x1 === s.x2;
    const arrowId = d.nextId();
    if (isSelf) {
      d.cells.push(`
        <mxCell id="${arrowId}" value="${escapeXml(s.label)}" style="edgeStyle=orthogonalEdgeStyle;rounded=1;html=1;strokeColor=#7c3aed;strokeWidth=1.5;fontFamily=Segoe UI;fontSize=10;fontColor=#4c1d95;align=left;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="${s.x1}" y="${s.y}" as="sourcePoint" />
            <mxPoint x="${s.x1 + 100}" y="${s.y + 25}" as="targetPoint" />
            <Array as="points">
              <mxPoint x="${s.x1 + 60}" y="${s.y}" />
              <mxPoint x="${s.x1 + 60}" y="${s.y + 25}" />
            </Array>
          </mxGeometry>
        </mxCell>
      `);
    } else {
      d.cells.push(`
        <mxCell id="${arrowId}" value="${escapeXml(s.label)}" style="html=1;verticalAlign=bottom;endArrow=block;strokeColor=#2563eb;strokeWidth=1.5;fontFamily=Segoe UI;fontSize=10;fontColor=#0f172a;" edge="1" parent="1">
          <mxGeometry width="80" relative="1" as="geometry">
            <mxPoint x="${s.x1}" y="${s.y}" as="sourcePoint" />
            <mxPoint x="${s.x2}" y="${s.y}" as="targetPoint" />
          </mxGeometry>
        </mxCell>
      `);
    }
  });

  // Alt branch annotation box
  d.addBox({
    x: 40, y: 925, w: 1370, h: 55,
    title: 'NHÁNH NGOẠI LỆ (ALTERNATIVE FLOWS):',
    subtitle: '• alt [Sự kiện hết chỗ / Hết hạn BR-02, BR-03]: FirestoreService ném ngoại lệ ➔ UI hiển thị thông báo lỗi ➔ Hủy luồng.\n• alt [CTSV Từ chối đơn]: CTSV ghi rejectReason ➔ FCM Push thông báo sinh viên lý do từ chối ➔ Không phát hành vé.\n• alt [Quét vé giả hoặc vé đã dùng BR-05]: MobileDesk Scanner rung chuông cảnh báo đỏ "VÉ KHÔNG HỢP LỆ HOẶC ĐÃ QUÉT" ➔ Chặn vào cổng.',
    colorTheme: 'amber', rx: 4
  });

  return d;
}

// =========================================================================
// SLIDE 13: CLASS DESIGN (MVVM UML Class Diagram)
// =========================================================================
function buildSlide13ClassDesign() {
  const d = new DiagramBuilder('13_Class_Design', 1450, 1000);
  d.addTitle(
    '13. CLASS DESIGN — THIẾT KẾ CÁC LỚP TRONG MÃ NGUỒN (MVVM)',
    'Phân định trách nhiệm rõ ràng: Domain Models ➔ ViewModels (State) ➔ Business Services ➔ Cloud Layer',
    'SLIDE 13 • CLASS DESIGN'
  );

  // Group 1: Domain Entities (Models)
  d.addBox({
    x: 40, y: 100, w: 420, h: 840,
    title: '1. TẦNG DOMAIN MODELS (LIB/MODELS/)',
    subtitle: 'Thực thể dữ liệu bất biến, chuyển đổi JSON/Firestore Map',
    colorTheme: 'blue'
  });

  const cEvent = d.addBox({
    x: 60, y: 155, w: 380, h: 175,
    title: 'EventModel',
    subtitle: 'Entity sự kiện trường FPT',
    details: [
      '+ String id, title, description, location',
      '+ DateTime date, String timeRange',
      '+ String clubName, category',
      '+ int capacity, registeredCount',
      '+ String status // upcoming, happening, completed',
      '+ bool get isPast => DateTime.now().isAfter(date)',
      '+ bool get isRegistrationOpen',
      '+ fromMap(Map json), toMap(): Map<String, dynamic>'
    ],
    colorTheme: 'blue'
  });

  const cTicket = d.addBox({
    x: 60, y: 345, w: 380, h: 180,
    title: 'TicketModel',
    subtitle: 'Entity vé điện tử sinh viên',
    details: [
      '+ String id, eventId, eventTitle',
      '+ String userId, studentName, studentEmail',
      '+ String qrToken // mã băm bí mật',
      '+ bool isUsed // cờ đánh dấu check-in',
      '+ DateTime? checkedInAt',
      '+ bool feedbackSubmitted',
      '+ fromMap(Map json), toMap(): Map<String, dynamic>'
    ],
    colorTheme: 'green'
  });

  const cReg = d.addBox({
    x: 60, y: 540, w: 380, h: 170,
    title: 'RegistrationModel (Slide 18)',
    subtitle: 'Entity đơn đăng ký xét duyệt',
    details: [
      '+ String id, eventId, userId',
      '+ String studentName, studentId, studentEmail',
      '+ String status // pending, approved, rejected',
      '+ String? rejectReason',
      '+ DateTime createdAt, reviewedAt',
      '+ fromMap(Map json), toMap(): Map<String, dynamic>'
    ],
    colorTheme: 'purple'
  });

  const cUser = d.addBox({
    x: 60, y: 725, w: 380, h: 160,
    title: 'UserModel',
    subtitle: 'Entity tài khoản sinh viên FPT',
    details: [
      '+ String id, name, email, avatarUrl',
      '+ String major, role // student, admin, staff',
      '+ int activityPoints // điểm rèn luyện',
      '+ fromMap(Map json), toMap(): Map<String, dynamic>'
    ],
    colorTheme: 'slate'
  });

  // Group 2: ViewModels (State Controllers)
  d.addBox({
    x: 490, y: 100, w: 450, h: 840,
    title: '2. TẦNG VIEWMODELS (LIB/VIEWMODELS/)',
    subtitle: 'Kế thừa ChangeNotifier, quản lý trạng thái UI',
    colorTheme: 'purple'
  });

  const vmReg = d.addBox({
    x: 510, y: 155, w: 410, h: 175,
    title: 'RegistrationViewModel',
    subtitle: 'Điều khiển luồng nộp đơn và duyệt (Slide 18)',
    details: [
      '- FirestoreService _firestoreService',
      '+ UIState<RegistrationModel> state',
      '+ Future<void> submitRegistration(EventModel event)',
      '+ Stream<List<RegistrationModel>> streamPending()',
      '+ Future<void> approve(String regId)',
      '+ Future<void> reject(String regId, String reason)'
    ],
    colorTheme: 'purple'
  });

  const vmTickets = d.addBox({
    x: 510, y: 345, w: 410, h: 180,
    title: 'MyTicketsViewModel',
    subtitle: 'Quản lý vé Sắp diễn ra & Đã tham gia',
    details: [
      '- FirestoreService _firestoreService',
      '+ List<TicketModel> upcomingTickets',
      '+ List<TicketModel> attendedTickets',
      '+ void fetchUserTickets(String userId)',
      '+ void listenToTicketUpdates(String userId)',
      '+ Future<void> refresh()'
    ],
    colorTheme: 'green'
  });

  const vmAuth = d.addBox({
    x: 510, y: 540, w: 410, h: 170,
    title: 'AuthViewModel',
    subtitle: 'Quản lý phiên đăng nhập & điểm rèn luyện',
    details: [
      '- AuthService _authService',
      '+ UserModel? get currentUser',
      '+ Future<void> signInWithEmailPassword(...)',
      '+ Future<void> signInWithGoogle()',
      '+ Future<void> addActivityPoints(int points)',
      '+ Future<void> signOut()'
    ],
    colorTheme: 'blue'
  });

  const vmDesk = d.addBox({
    x: 510, y: 725, w: 410, h: 160,
    title: 'MobileDeskViewModel',
    subtitle: 'Điều khiển máy quét cổng & viễn trắc',
    details: [
      '- FirestoreService _firestoreService',
      '+ int scannedCount, totalCapacity',
      '+ double processingSpeedSeconds',
      '+ Future<bool> scanQrToken(String token)',
      '+ void switchMonitoredEvent(String eventId)'
    ],
    colorTheme: 'amber'
  });

  // Group 3: Services (Business Layer)
  d.addBox({
    x: 970, y: 100, w: 440, h: 840,
    title: '3. TẦNG DỊCH VỤ (LIB/SERVICES/)',
    subtitle: 'Triển khai Atomic Transactions & kết nối Cloud',
    colorTheme: 'green'
  });

  const sFire = d.addBox({
    x: 990, y: 155, w: 400, h: 260,
    title: 'FirestoreService',
    subtitle: 'Cung cấp toàn bộ thao tác cơ sở dữ liệu thật',
    details: [
      '- FirebaseFirestore _db',
      '+ Stream<List<EventModel>> getEventsStream()',
      '+ Stream<List<TicketModel>> getTicketsStream(String uid)',
      '+ Future<void> submitRegistration(RegistrationModel reg)',
      '+ Future<void> approveRegistration(String regId)',
      '+ Future<bool> checkInTicket(String qrToken) // RunTransaction',
      '+ Future<void> submitFeedback(FeedbackModel fb)',
      '+ Future<void> updateActivityPoints(String uid, int pts)'
    ],
    colorTheme: 'green'
  });

  const sAuthCls = d.addBox({
    x: 990, y: 430, w: 400, h: 200,
    title: 'AuthService',
    subtitle: 'Xác thực tài khoản & kiểm tra domain',
    details: [
      '- FirebaseAuth _firebaseAuth',
      '+ UserModel? _currentUser',
      '+ Stream<UserModel?> get authStateChanges',
      '+ Future<UserModel?> signInWithEmailPassword(...)',
      '+ Future<UserModel?> signInWithGoogle()',
      '+ Future<UserModel> _syncUserWithFirestore(...)',
      '+ Future<void> signOut()'
    ],
    colorTheme: 'blue'
  });

  const sAiCls = d.addBox({
    x: 990, y: 645, w: 400, h: 240,
    title: 'GeminiAiService',
    subtitle: 'Hệ thống AI xử lý ngôn ngữ tự nhiên',
    details: [
      '- List<String> _apiKeys // Pool 10 keys',
      '- int _currentKeyIndex',
      '+ Future<String> generateFeedbackInsight(...)',
      '+ Future<List<String>> recommendEvents(...)',
      '+ String _rotateToNextKey() // on HTTP 429'
    ],
    colorTheme: 'purple'
  });

  // Dependencies Connections
  d.addConnection({ source: vmReg, target: sFire, label: 'calls' });
  d.addConnection({ source: vmTickets, target: sFire, label: 'calls' });
  d.addConnection({ source: vmDesk, target: sFire, label: 'calls' });
  d.addConnection({ source: vmAuth, target: sAuthCls, label: 'calls' });
  d.addConnection({ source: vmReg, target: cReg, label: 'manages' });
  d.addConnection({ source: vmTickets, target: cTicket, label: 'manages' });

  return d;
}

// =========================================================================
// SLIDE 14: DATABASE DESIGN 1/2 (Conceptual ERD)
// =========================================================================
function buildSlide14DatabaseConceptual() {
  const d = new DiagramBuilder('14_Database_Conceptual', 1450, 950);
  d.addTitle(
    '14. DATABASE DESIGN 1/2 — MÔ HÌNH DỮ LIỆU KHÁI NIỆM (CONCEPTUAL ERD)',
    'Mô hình hóa ngữ nghĩa nghiệp vụ, thực thể, mối quan hệ và bản số (Cardinality) — Chưa phụ thuộc DBMS vật lý',
    'SLIDE 14 • DATABASE DESIGN 1/2'
  );

  // Entities as Clean Conceptual Cards
  const eUser = d.addBox({
    x: 60, y: 140, w: 240, h: 140,
    title: 'SINH VIÊN (USER)',
    subtitle: 'Thực thể người học FPT',
    details: ['* Mã sinh viên (MSSV)', '• Họ và tên', '• Email trường (@fpt.edu.vn)', '• Chuyên ngành đào tạo', '• Điểm rèn luyện tích lũy'],
    colorTheme: 'blue'
  });

  const eClub = d.addBox({
    x: 60, y: 400, w: 240, h: 140,
    title: 'CÂU LẠC BỘ (CLUB)',
    subtitle: 'Đơn vị tổ chức sự kiện',
    details: ['* Mã định danh CLB', '• Tên câu lạc bộ', '• Tên viết tắt', '• Lĩnh vực hoạt động', '• Cán bộ chủ nhiệm'],
    colorTheme: 'purple'
  });

  const eEvent = d.addBox({
    x: 420, y: 260, w: 260, h: 170,
    title: 'SỰ KIỆN (EVENT)',
    subtitle: 'Chương trình được phê duyệt',
    details: ['* Mã sự kiện', '• Tên chủ đề sự kiện', '• Ngày giờ diễn ra', '• Địa điểm / Hội trường', '• Sức chứa tối đa', '• Hạn chót đăng ký', '• Trạng thái vận hành'],
    colorTheme: 'green'
  });

  const eReg = d.addBox({
    x: 790, y: 140, w: 260, h: 150,
    title: 'ĐƠN ĐĂNG KÝ (REGISTRATION)',
    subtitle: 'Hồ sơ chờ duyệt (Slide 18)',
    details: ['* Mã đơn đăng ký', '• Thời điểm nộp đơn', '• Trạng thái xét duyệt (pending/approved/rejected)', '• Lý do từ chối (nếu có)', '• Cán bộ xét duyệt'],
    colorTheme: 'amber'
  });

  const eTicket = d.addBox({
    x: 790, y: 400, w: 260, h: 160,
    title: 'VÉ ĐIỆN TỬ (TICKET)',
    subtitle: 'Vé vào cổng kèm mã bảo mật',
    details: ['* Mã vé điện tử', '• Mã băm QR Token bí mật', '• Trạng thái sử dụng (isUsed)', '• Thời điểm check-in cổng', '• Đã gửi feedback hay chưa'],
    colorTheme: 'green'
  });

  const eFeedback = d.addBox({
    x: 1140, y: 300, w: 250, h: 140,
    title: 'ĐÁNH GIÁ (FEEDBACK)',
    subtitle: 'Khảo sát chất lượng sự kiện',
    details: ['* Mã phiếu đánh giá', '• Điểm số hài lòng (1-5 sao)', '• Nhận xét & góp ý chi tiết', '• Thời điểm nộp phiếu', '• Điểm rèn luyện đã cộng (+5)'],
    colorTheme: 'purple'
  });

  const eCert = d.addBox({
    x: 1140, y: 490, w: 250, h: 140,
    title: 'CHỨNG NHẬN (CERTIFICATE)',
    subtitle: 'Chứng chỉ e-Cert số hóa',
    details: ['* Số hiệu chứng nhận', '• Đường dẫn tệp PDF Cloud', '• Mã băm kiểm định SHA-256', '• Ngày cấp chứng nhận'],
    colorTheme: 'blue'
  });

  // Relationships with Crow's Foot & Cardinalities
  d.addConnection({ source: eClub, target: eEvent, label: '1 tổ chức (1,1) ➔ (0,N)', color: '#7c3aed', strokeWidth: 2 });
  d.addConnection({ source: eUser, target: eReg, label: 'nộp đơn (1,1) ➔ (0,N)', color: '#2563eb' });
  d.addConnection({ source: eEvent, target: eReg, label: 'tiếp nhận (1,1) ➔ (0,N)', color: '#059669' });
  d.addConnection({ source: eReg, target: eTicket, label: 'phê duyệt sinh vé (0,1) ➔ (0,1) [Slide 18]', color: '#d97706', strokeWidth: 2 });
  d.addConnection({ source: eEvent, target: eTicket, label: 'phát hành (1,1) ➔ (0,N)', color: '#059669' });
  d.addConnection({ source: eUser, target: eTicket, label: 'sở hữu (1,1) ➔ (0,N)', color: '#2563eb' });
  d.addConnection({ source: eTicket, target: eFeedback, label: 'mở khóa đánh giá (1,1) ➔ (0,1)', color: '#7c3aed' });
  d.addConnection({ source: eTicket, target: eCert, label: 'cấp chứng nhận (1,1) ➔ (0,1)', color: '#2563eb' });

  // Prominent Business Rules Box
  d.addBox({
    x: 60, y: 680, w: 1330, h: 220,
    title: 'CÁC QUY TẮC NGHIỆP VỤ (BUSINESS RULES) CHI PHỐI QUAN HỆ KHÁI NIỆM:',
    subtitle: 'Ràng buộc toàn vẹn dữ liệu được bảo vệ xuyên suốt từ mức thiết kế ý niệm đến ứng dụng thực tế',
    details: [
      '• BR-01 (Định danh duy nhất): Mỗi Vé điện tử (Ticket) thuộc về duy nhất một Sinh viên (User) và một Sự kiện (Event). Một sinh viên không thể có 2 vé trong cùng 1 sự kiện.',
      '• BR-02 (Ràng buộc sức chứa): Tổng số Vé điện tử được phát hành của một Sự kiện không bao giờ vượt quá chỉ số Sức chứa tối đa (Capacity) của Sự kiện đó.',
      '• BR-03 (Thời hạn nộp đơn): Đơn đăng ký chỉ có thể được tạo khi thời điểm hiện tại nhỏ hơn hoặc bằng Hạn chót đăng ký của Sự kiện.',
      '• BR-04 (Quy trình duyệt vé Slide 18): Một Vé điện tử chỉ được khởi tạo khi và chỉ khi Đơn đăng ký (Registration) tương ứng chuyển sang trạng thái "approved" bởi Cán bộ CTSV.',
      '• BR-05 (Ràng buộc Đánh giá & Chứng nhận): Phiếu Đánh giá (Feedback) và Chứng chỉ (Certificate) chỉ có thể được tạo sau khi Vé đã được xác thực Check-in cổng (isUsed == true).'
    ],
    colorTheme: 'slate'
  });

  return d;
}

// =========================================================================
// SLIDE 15: DATABASE DESIGN 2/2 (Logical -> Physical Schema Firestore)
// =========================================================================
function buildSlide15DatabasePhysical() {
  const d = new DiagramBuilder('15_Database_Physical', 1450, 1000);
  d.addTitle(
    '15. DATABASE DESIGN 2/2 — THIẾT KẾ VẬT LÝ CLOUD FIRESTORE NOSQL',
    'Cấu trúc Documents & Collections, Kiểu dữ liệu, Khóa chính, Chỉ mục phức hợp (Indexes) và Ràng buộc bảo mật',
    'SLIDE 15 • DATABASE DESIGN 2/2'
  );

  const colWidth = 320;
  const colHeight = 270;

  // Collection 1: users
  d.addBox({
    x: 40, y: 100, w: colWidth, h: colHeight,
    title: '📁 users/{uid}',
    subtitle: 'Collection tài khoản người dùng',
    details: [
      '• id: string [PK, Firebase UID]',
      '• name: string [Required]',
      '• email: string [Unique, @fpt.edu.vn]',
      '• avatarUrl: string [URL]',
      '• major: string [Chuyên ngành]',
      '• role: string ["student" | "admin" | "staff"]',
      '• activityPoints: number [Default: 0, >= 0]',
      '• createdAt: timestamp [ServerTimestamp]'
    ],
    colorTheme: 'blue'
  });

  // Collection 2: events
  d.addBox({
    x: 380, y: 100, w: colWidth + 20, h: colHeight,
    title: '📁 events/{eventId}',
    subtitle: 'Collection thông tin sự kiện',
    details: [
      '• id: string [PK, EVT-YYYY-XXXX]',
      '• title: string [Required, Index]',
      '• description: string',
      '• date: timestamp [Required, Index]',
      '• timeRange: string ["13:30 - 17:30"]',
      '• location: string [Hội trường / Phòng]',
      '• clubId: string [FK ➔ clubs.id]',
      '• capacity: number [Int, > 0]',
      '• registeredCount: number [Default: 0]',
      '• status: string ["upcoming" | "happening" | "completed"]'
    ],
    colorTheme: 'green'
  });

  // Collection 3: registrations (Slide 18)
  d.addBox({
    x: 740, y: 100, w: colWidth + 20, h: colHeight,
    title: '📁 registrations/{regId} (Slide 18)',
    subtitle: 'Hàng chờ thẩm định đơn xét duyệt',
    details: [
      '• id: string [PK, REG-XXXX]',
      '• eventId: string [FK ➔ events.id, Index]',
      '• userId: string [FK ➔ users.id, Index]',
      '• studentName: string',
      '• studentEmail: string',
      '• status: string ["pending" | "approved" | "rejected"]',
      '• rejectReason: string? [Optional]',
      '• createdAt: timestamp [Index DESC]'
    ],
    colorTheme: 'amber'
  });

  // Collection 4: tickets
  d.addBox({
    x: 1095, y: 100, w: colWidth + 15, h: colHeight,
    title: '📁 tickets/{ticketId}',
    subtitle: 'Collection vé điện tử & check-in',
    details: [
      '• id: string [PK, CE2026-XXXXXX]',
      '• eventId: string [FK ➔ events.id, Index]',
      '• userId: string [FK ➔ users.id, Index]',
      '• qrToken: string [Unique Hash Token]',
      '• isUsed: boolean [Default: false, Index]',
      '• checkedInAt: timestamp? [Nullable]',
      '• feedbackSubmitted: boolean [Default: false]',
      '• createdAt: timestamp'
    ],
    colorTheme: 'green'
  });

  // Collection 5: feedback
  d.addBox({
    x: 40, y: 390, w: colWidth, h: 220,
    title: '📁 feedback/{feedbackId}',
    subtitle: 'Collection đánh giá khảo sát',
    details: [
      '• id: string [PK]',
      '• eventId: string [FK ➔ events.id, Index]',
      '• userId: string [FK ➔ users.id]',
      '• ticketId: string [FK ➔ tickets.id, Unique]',
      '• rating: number [1..5, Required]',
      '• comment: string [Text]',
      '• createdAt: timestamp'
    ],
    colorTheme: 'purple'
  });

  // Collection 6: certificates
  d.addBox({
    x: 380, y: 390, w: colWidth + 20, h: 220,
    title: '📁 certificates/{certId}',
    subtitle: 'Collection chứng nhận e-Certificate',
    details: [
      '• id: string [PK, CERT-XXXX]',
      '• eventId: string [FK ➔ events.id]',
      '• userId: string [FK ➔ users.id, Index]',
      '• pdfStoragePath: string ["reports/{uid}/..."]',
      '• sha256Checksum: string [64-char Hash]',
      '• issuedAt: timestamp'
    ],
    colorTheme: 'blue'
  });

  // Collection 7: clubs
  d.addBox({
    x: 740, y: 390, w: colWidth + 20, h: 220,
    title: '📁 clubs/{clubId}',
    subtitle: 'Collection danh mục CLB',
    details: [
      '• id: string [PK, "fcode", "cocsaigon"]',
      '• name: string [Tên chính thức]',
      '• acronym: string ["F-Code"]',
      '• category: string ["Technology" | "Media"]',
      '• followerCount: number',
      '• logoUrl: string, fanpageUrl: string'
    ],
    colorTheme: 'slate'
  });

  // Subcollection 8: questions (Live Q&A)
  d.addBox({
    x: 1095, y: 390, w: colWidth + 15, h: 220,
    title: '📁 events/{id}/questions/{qId}',
    subtitle: 'Subcollection Q&A hội trường trực tiếp',
    details: [
      '• id: string [PK]',
      '• authorId: string [FK ➔ users.id]',
      '• authorName: string',
      '• question: string [Nội dung]',
      '• upvotes: number [Default: 0]',
      '• isAnswered: boolean [Default: false]',
      '• createdAt: timestamp'
    ],
    colorTheme: 'purple'
  });

  // Compound Indexes & Security Rules Specifications Box
  d.addBox({
    x: 40, y: 630, w: 1370, h: 320,
    title: 'CHỈ MỤC PHỨC HỢP (COMPOUND INDEXES) & BẢO MẬT FIRESTORE SECURITY RULES:',
    subtitle: 'Tối ưu hóa hiệu năng truy vấn sub-second và bảo vệ dữ liệu ở mức cơ sở dữ liệu đám mây',
    details: [
      '1. Compound Index: tickets ➔ userId (ASC) + isUsed (ASC) + createdAt (DESC) — Tối ưu truy vấn phân tách vé "Sắp diễn ra" (isUsed:false) và "Đã tham gia" (isUsed:true).',
      '2. Compound Index: events ➔ status (ASC) + date (ASC) — Hỗ trợ lọc danh sách sự kiện theo trạng thái vận hành và thứ tự thời gian.',
      '3. Compound Index: registrations ➔ eventId (ASC) + status (ASC) + createdAt (DESC) — Tối ưu hiển thị bảng Hàng chờ duyệt vé (Slide 18) trên Web Portal.',
      '4. Firestore Security Rule: allow read: if request.auth != null && request.auth.token.email.matches(".*@fpt[.]edu[.]vn$|.*@fe[.]edu[.]vn$"); — Khóa chặt truy cập.',
      '5. Atomic Check-in Rule: Chỉ cho phép cập nhật isUsed: true nếu document trước đó có isUsed == false, chặn hoàn toàn xung đột ghi đè đồng thời (Write Conflict).'
    ],
    colorTheme: 'slate'
  });

  return d;
}

// =========================================================================
// MAIN BUILDER: GENERATE ALL FILES
// =========================================================================
function main() {
  const outputDir = path.join(__dirname, '../docs/diagrams');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const generators = [
    { file: '07_business_flow.drawio', fn: buildSlide07BusinessFlow },
    { file: '08_state_machine.drawio', fn: buildSlide08StateMachine },
    { file: '09_system_architecture.drawio', fn: buildSlide09SystemArchitecture },
    { file: '10_technology_stack.drawio', fn: buildSlide10TechStack },
    { file: '12_sequence_diagram.drawio', fn: buildSlide12SequenceDiagram },
    { file: '13_class_design.drawio', fn: buildSlide13ClassDesign },
    { file: '14_database_conceptual.drawio', fn: buildSlide14DatabaseConceptual },
    { file: '15_database_physical.drawio', fn: buildSlide15DatabasePhysical },
  ];

  const builtDiagrams = [];

  generators.forEach(g => {
    const builder = g.fn();
    const xml = `<mxfile host="app.diagrams.net" modified="${new Date().toISOString()}" agent="Antigravity Architecture Builder" version="24.0.0">
  ${builder.toXml()}
</mxfile>`;
    const filePath = path.join(outputDir, g.file);
    fs.writeFileSync(filePath, xml, 'utf8');
    console.log(`Generated: ${g.file} (${xml.length} bytes)`);
    builtDiagrams.push(builder);
  });

  // Consolidated Master Draw.io File (All 8 Diagrams as Tabs in 1 Master File!)
  const masterXml = `<mxfile host="app.diagrams.net" modified="${new Date().toISOString()}" agent="Antigravity Architecture Builder" version="24.0.0">
  ${builtDiagrams.map(b => b.toXml()).join('\n  ')}
</mxfile>`;
  const masterPath = path.join(outputDir, 'campus_event_presentation_master.drawio');
  fs.writeFileSync(masterPath, masterXml, 'utf8');
  console.log(`Generated Master File: campus_event_presentation_master.drawio (${masterXml.length} bytes)`);
}

main();

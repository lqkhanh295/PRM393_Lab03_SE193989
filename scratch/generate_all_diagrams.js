const fs = require('fs');
const path = require('path');
const { DiagramBuilder, escapeXml } = require('./diagram_builder');

// =========================================================================
// SLIDE 07: BUSINESS FLOW (BPMN / Activity with Waterfall Non-crossing Flow)
// =========================================================================
function buildSlide07BusinessFlow() {
  const d = new DiagramBuilder('07_Business_Flow', 1600, 1680);
  d.addTitle(
    '07. BUSINESS FLOW — LUỒNG NGHIỆP VỤ TỔNG THỂ HỆ THỐNG (WATERFALL NON-CROSSING)',
    'Phối hợp 4 tác nhân: Sinh viên ➔ Hệ thống Cloud/Mobile ➔ Cán bộ CTSV (Duyệt vé Slide 18) ➔ Ban Soát vé Cổng',
    'SLIDE 07 • BUSINESS FLOW'
  );

  // 4 Swimlanes with generous width (360px each) & full height 1550px
  const laneHeight = 1530;
  const laneStudent = d.addSwimlane({ x: 40, y: 100, w: 350, h: laneHeight, title: 'SINH VIÊN (MOBILE APP)', subtitle: 'Tài khoản Email FPT (@fpt.edu.vn)', colorTheme: 'blue' });
  const laneSystem = d.addSwimlane({ x: 420, y: 100, w: 360, h: laneHeight, title: 'HỆ THỐNG (MOBILE VM & FIRESTORE)', subtitle: 'Atomic Engine, Rule Check & FCM Gateway', colorTheme: 'slate' });
  const laneCTSV = d.addSwimlane({ x: 810, y: 100, w: 360, h: laneHeight, title: 'CÁN BỘ CTSV (WEB ADMIN PORTAL)', subtitle: 'Hàng chờ thẩm định đơn đăng ký & cấp vé', colorTheme: 'purple' });
  const laneGate = d.addSwimlane({ x: 1200, y: 100, w: 350, h: laneHeight, title: 'BAN SOÁT VÉ / CTV CỔNG', subtitle: 'MobileDesk Scanner viễn trắc thời gian thực', colorTheme: 'emerald' });

  // Chronological Waterfall: Every single step is STRICTLY LOWER than the previous one!
  // Step 1 (Lane 1): y=65
  const nStart = d.addBox({
    parent: laneStudent, x: 25, y: 65, w: 300, h: 65,
    title: '1. Khởi động & Đăng nhập',
    subtitle: 'Đăng nhập Google SSO / Email FPT',
    details: ['Xác thực định danh @fpt.edu.vn'],
    colorTheme: 'blue'
  });

  // Step 2 (Lane 1): y=160
  const nSelectEvent = d.addBox({
    parent: laneStudent, x: 25, y: 160, w: 300, h: 65,
    title: '2. Duyệt & Chọn Sự kiện',
    subtitle: 'Màn hình Explore / Danh sách sự kiện',
    details: ['Xem ngày giờ, địa điểm, số chỗ còn lại'],
    colorTheme: 'blue'
  });

  // Step 3 (Lane 1): y=255
  const nSubmitReg = d.addBox({
    parent: laneStudent, x: 25, y: 255, w: 300, h: 65,
    title: '3. Bấm "Đăng ký tham gia"',
    subtitle: 'Mở Registration Modal',
    details: ['Xác nhận MSSV, họ tên, email, CLB tổ chức'],
    colorTheme: 'blue'
  });

  // Step 4 (Lane 2): y=355
  const nCheckBR03 = d.addBox({
    parent: laneSystem, x: 25, y: 355, w: 310, h: 80,
    title: '4. Kiểm tra Thời hạn Sự kiện [BR-03]',
    subtitle: 'Guard: DateTime.now() <= event.date',
    details: ['Chặn đăng ký nếu sự kiện đã trong quá khứ'],
    colorTheme: 'amber'
  });

  // Step 5 (Lane 2): y=475
  const nCheckBR02 = d.addBox({
    parent: laneSystem, x: 25, y: 475, w: 310, h: 80,
    title: '5. Kiểm tra Sức chứa [BR-02]',
    subtitle: 'Guard: registeredCount < capacity',
    details: ['Đảm bảo không vượt quá sức chứa hội trường'],
    colorTheme: 'amber'
  });

  // Step 6 (Lane 2): y=595
  const nCreatePending = d.addBox({
    parent: laneSystem, x: 25, y: 595, w: 310, h: 80,
    title: '6. Lưu Đơn Xét Duyệt (Pending)',
    subtitle: 'Ghi Firestore: registrations/{regId}',
    details: ['Status: "pending" • Real-time Snapshot Push'],
    colorTheme: 'purple'
  });

  // Step 7 (Lane 3): y=715
  const nReviewQueue = d.addBox({
    parent: laneCTSV, x: 25, y: 715, w: 310, h: 80,
    title: '7. Hàng Chờ Duyệt Vé (Slide 18)',
    subtitle: 'Web Admin Portal: Tab Hàng chờ duyệt',
    details: ['Real-time badge (+1) hiển thị tức thì'],
    colorTheme: 'purple'
  });

  // Step 8 (Lane 3): y=835
  const nDecision = d.addBox({
    parent: laneCTSV, x: 25, y: 835, w: 310, h: 85,
    title: '8. Thẩm định & Quyết định [BR-04]',
    subtitle: 'Kiểm tra tư cách sinh viên & hồ sơ CLB',
    details: ['Nhánh A: Phê duyệt (Approve) ➔ Cấp vé', 'Nhánh B: Từ chối (Reject) ➔ Nhập lý do'],
    colorTheme: 'amber'
  });

  // Step 9 (Lane 2): y=960
  const nIssueTicket = d.addBox({
    parent: laneSystem, x: 25, y: 960, w: 310, h: 85,
    title: '9. Phát hành Vé & Sinh Mã QR [BR-04]',
    subtitle: 'Atomic Transaction Cloud Firestore',
    details: ['Tạo tickets/{ticketId} • qrToken bảo mật', 'FCM Push: "Vé của bạn đã sẵn sàng"'],
    colorTheme: 'green'
  });

  // Step 10 (Lane 1): y=1085
  const nReceiveTicket = d.addBox({
    parent: laneStudent, x: 25, y: 1085, w: 300, h: 85,
    title: '10. Nhận Vé Trong Tab "Sắp diễn ra"',
    subtitle: 'DigitalTicketScreen hiển thị mã QR',
    details: ['Vé hợp lệ, sẵn sàng xuất trình tại cổng'],
    colorTheme: 'green'
  });

  // Step 11 (Lane 4): y=1210
  const nScanGate = d.addBox({
    parent: laneGate, x: 25, y: 1210, w: 300, h: 85,
    title: '11. Quét QR tại Bàn Soát Vé',
    subtitle: 'MobileDesk Camera Scanner (< 1.5s/lượt)',
    details: ['Đối chiếu qrToken với Firestore Ticket Record'],
    colorTheme: 'emerald'
  });

  // Step 12 (Lane 4): y=1335
  const nValidateQR = d.addBox({
    parent: laneGate, x: 25, y: 1335, w: 300, h: 85,
    title: '12. Xác thực Hợp lệ [BR-05]',
    subtitle: 'Guard: qrValid && !isUsed',
    details: ['Nhánh ĐÚNG: Check-in ➔ Đổi isUsed:true', 'Nhánh SAI: Báo động Vé giả/Đã quét'],
    colorTheme: 'amber'
  });

  // Step 13 (Lane 1): y=1460
  const nFeedbackReward = d.addBox({
    parent: laneStudent, x: 25, y: 1460, w: 300, h: 85,
    title: '13. Đánh giá & Nhận Điểm [BR-06]',
    subtitle: 'Mở khóa Feedback Screen',
    details: ['Đánh giá 1-5 sao ➔ +5 Điểm rèn luyện', 'Xuất chứng nhận e-Certificate PDF [BR-07]'],
    colorTheme: 'green'
  });

  // CONNECTORS: Clean, strictly orthogonal, NO overlapping!
  // Inside Lane 1 (vertical):
  d.addConnection({ source: nStart, target: nSelectEvent, exitX: 0.5, exitY: 1, entryX: 0.5, entryY: 0 });
  d.addConnection({ source: nSelectEvent, target: nSubmitReg, exitX: 0.5, exitY: 1, entryX: 0.5, entryY: 0 });

  // Lane 1 -> Lane 2:
  d.addConnection({ source: nSubmitReg, target: nCheckBR03, label: 'Gửi đăng ký', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.5, offsetY: -12 });

  // Inside Lane 2 (vertical with label to the RIGHT):
  d.addConnection({ source: nCheckBR03, target: nCheckBR02, label: 'Còn hạn [BR-03]', exitX: 0.5, exitY: 1, entryX: 0.5, entryY: 0, offsetX: 28, offsetY: 0 });
  d.addConnection({ source: nCheckBR02, target: nCreatePending, label: 'Còn chỗ [BR-02]', exitX: 0.5, exitY: 1, entryX: 0.5, entryY: 0, offsetX: 28, offsetY: 0 });

  // Lane 2 -> Lane 3:
  d.addConnection({ source: nCreatePending, target: nReviewQueue, label: 'Sync Hàng chờ (Slide 18)', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.5, offsetY: -12 });

  // Inside Lane 3 (vertical):
  d.addConnection({ source: nReviewQueue, target: nDecision, label: 'Thẩm định', exitX: 0.5, exitY: 1, entryX: 0.5, entryY: 0, offsetX: 28, offsetY: 0 });

  // Lane 3 -> Lane 2:
  d.addConnection({ source: nDecision, target: nIssueTicket, label: 'Duyệt đơn [BR-04]', exitX: 0, exitY: 0.5, entryX: 1, entryY: 0.5, color: '#059669', strokeWidth: 2, offsetY: -12 });

  // Lane 2 -> Lane 1:
  d.addConnection({ source: nIssueTicket, target: nReceiveTicket, label: 'FCM Push & Stream', exitX: 0, exitY: 0.5, entryX: 1, entryY: 0.5, color: '#059669', offsetY: -12 });

  // Lane 1 -> Lane 4 (Waterfalls across empty space below y=1085! Zero collision!):
  d.addConnection({ source: nReceiveTicket, target: nScanGate, label: 'Xuất trình QR tại cổng', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.5, color: '#2563eb', offsetY: -12 });

  // Inside Lane 4 (vertical):
  d.addConnection({ source: nScanGate, target: nValidateQR, label: 'Quét token', exitX: 0.5, exitY: 1, entryX: 0.5, entryY: 0, offsetX: 28, offsetY: 0 });

  // Lane 4 -> Lane 1 (Waterfalls across empty space below y=1335! Zero collision!):
  d.addConnection({ source: nValidateQR, target: nFeedbackReward, label: 'Check-in OK [BR-05]', exitX: 0, exitY: 0.5, entryX: 1, entryY: 0.5, color: '#059669', strokeWidth: 2, offsetY: -12 });

  // Floating Business Rules Summary Box at bottom
  d.addBox({
    x: 40, y: 1640, w: 1510, h: 50,
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
  const d = new DiagramBuilder('08_State_Machine', 1600, 1100);
  d.addTitle(
    '08. STATE MACHINE DIAGRAM — VÒNG ĐỜI THỰC THỂ KINH DOANH CHÍNH',
    'Đặc tả State, Event, Guard, Action và Các Chuyển Trạng Thái Bị Cấm (Forbidden Transitions)',
    'SLIDE 08 • STATE MACHINE'
  );

  // Group 1: Registration State Machine (Slide 18) - Generous size 730 x 440
  d.addBox({
    x: 40, y: 105, w: 730, h: 440,
    title: 'VÒNG ĐỜI ĐƠN ĐĂNG KÝ (REGISTRATION LIFECYCLE - SLIDE 18)',
    subtitle: 'Quản lý yêu cầu từ lúc sinh viên nộp đơn đến khi hoàn tất thẩm định',
    colorTheme: 'blue'
  });

  const rStart = d.addBox({
    x: 70, y: 220, w: 140, h: 65,
    title: '[*] Khởi tạo', subtitle: 'Sinh viên chọn sự kiện', colorTheme: 'slate'
  });

  const rPending = d.addBox({
    x: 310, y: 205, w: 180, h: 95,
    title: 'PENDING (Chờ duyệt)',
    subtitle: 'Đang nằm trên Hàng chờ',
    details: ['Khóa chỉnh sửa thông tin', 'Chờ cán bộ CTSV review'],
    colorTheme: 'amber'
  });

  const rApproved = d.addBox({
    x: 570, y: 145, w: 180, h: 90,
    title: 'APPROVED (Đã duyệt)',
    subtitle: 'Đạt điều kiện tham dự',
    details: ['Kích hoạt tạo Vé điện tử'],
    colorTheme: 'green'
  });

  const rRejected = d.addBox({
    x: 570, y: 310, w: 180, h: 90,
    title: 'REJECTED (Từ chối)',
    subtitle: 'Không đạt tiêu chí',
    details: ['Lưu lý do từ chối cụ thể'],
    colorTheme: 'red'
  });

  // Short, concise labels with white background pill
  d.addConnection({ source: rStart, target: rPending, label: 'submit() [BR-02,03]', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.5, offsetY: -14 });
  d.addConnection({ source: rPending, target: rApproved, label: 'approve() [BR-04]', exitX: 1, exitY: 0.3, entryX: 0, entryY: 0.5, color: '#059669', strokeWidth: 2, offsetY: -14 });
  d.addConnection({ source: rPending, target: rRejected, label: 'reject(lý do)', exitX: 1, exitY: 0.7, entryX: 0, entryY: 0.5, color: '#dc2626', offsetY: -14 });

  // Group 2: Digital Ticket State Machine (Core Entity) - Generous size 760 x 440
  d.addBox({
    x: 790, y: 105, w: 760, h: 440,
    title: 'VÒNG ĐỜI VÉ ĐIỆN TỬ (DIGITAL TICKET LIFECYCLE - CORE ENTITY)',
    subtitle: 'Thực thể kiểm soát an ninh cổng, điểm danh và tích lũy điểm rèn luyện',
    colorTheme: 'green'
  });

  const tIssued = d.addBox({
    x: 820, y: 165, w: 185, h: 95,
    title: 'ISSUED (Đã phát hành)',
    subtitle: 'Tab "Sắp diễn ra"',
    details: ['isUsed = false', 'Mã QR hoạt động'],
    colorTheme: 'blue'
  });

  const tUsed = d.addBox({
    x: 1095, y: 165, w: 190, h: 95,
    title: 'USED (Đã check-in)',
    subtitle: 'Tab "Đã tham gia"',
    details: ['isUsed = true', 'Ghi checkedInAt: now'],
    colorTheme: 'green'
  });

  const tFeedback = d.addBox({
    x: 1365, y: 165, w: 170, h: 95,
    title: 'FEEDBACK_DONE',
    subtitle: 'Hoàn thành đánh giá',
    details: ['activityPoints += 5', 'Mở khóa tải e-Cert'],
    colorTheme: 'purple'
  });

  const tExpired = d.addBox({
    x: 820, y: 330, w: 185, h: 85,
    title: 'EXPIRED (Quá hạn)',
    subtitle: 'Không đến dự sự kiện',
    details: ['Sự kiện đã kết thúc', 'Khóa quét QR'],
    colorTheme: 'slate'
  });

  const tCert = d.addBox({
    x: 1365, y: 330, w: 170, h: 85,
    title: 'CERT_CLAIMED',
    subtitle: 'Đã tải chứng nhận',
    details: ['e-Certificate PDF SHA-256', 'Lưu Cloud Storage'],
    colorTheme: 'blue'
  });

  // Horizontal edges: offsetY = -14
  d.addConnection({ source: tIssued, target: tUsed, label: 'scanQR() [BR-05]', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.5, color: '#059669', strokeWidth: 2, offsetY: -14 });
  d.addConnection({ source: tUsed, target: tFeedback, label: 'feedback() [+5đ]', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.5, color: '#7c3aed', strokeWidth: 2, offsetY: -14 });

  // Vertical edges: offsetX = 28, offsetY = 0 (cleanly to the right of line!)
  d.addConnection({ source: tIssued, target: tExpired, label: 'quá hạn [timeout]', exitX: 0.5, exitY: 1, entryX: 0.5, entryY: 0, color: '#64748b', offsetX: 28, offsetY: 0 });
  d.addConnection({ source: tFeedback, target: tCert, label: 'cấp e-Cert [BR-07]', exitX: 0.5, exitY: 1, entryX: 0.5, entryY: 0, color: '#2563eb', offsetX: 28, offsetY: 0 });

  // Group 3: Event Operational State Machine - 730 x 480
  d.addBox({
    x: 40, y: 575, w: 730, h: 480,
    title: 'TRẠNG THÁI VẬN HÀNH SỰ KIỆN (EVENT OPERATIONAL STATUS)',
    subtitle: 'Đồng bộ thời gian thực theo DateTime.now() và khung giờ tổ chức',
    colorTheme: 'purple'
  });

  const eUpcoming = d.addBox({
    x: 70, y: 670, w: 185, h: 95,
    title: 'UPCOMING (Sắp diễn ra)',
    subtitle: 'now < startDate',
    details: ['Mở đăng ký vé [BR-03]', 'Đếm ngược ngày diễn ra'],
    colorTheme: 'blue'
  });

  const eHappening = d.addBox({
    x: 335, y: 670, w: 195, h: 95,
    title: 'HAPPENING (Đang diễn ra)',
    subtitle: 'startDate <= now <= endDate',
    details: ['Mở cổng soát vé MobileDesk', 'Live Companion Q&A'],
    colorTheme: 'green'
  });

  const eCompleted = d.addBox({
    x: 605, y: 670, w: 155, h: 95,
    title: 'COMPLETED (Đã diễn ra)',
    subtitle: 'now > endDate',
    details: ['Đóng cổng soát vé', 'Tổng kết viễn trắc'],
    colorTheme: 'slate'
  });

  d.addConnection({ source: eUpcoming, target: eHappening, label: 'bắt đầu [giờ G]', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.5, offsetY: -14 });
  d.addConnection({ source: eHappening, target: eCompleted, label: 'kết thúc [hết giờ]', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.5, offsetY: -14 });

  // Event Status Note
  d.addBox({
    x: 70, y: 810, w: 680, h: 215,
    title: 'QUY TẮC CHUYỂN TRẠNG THÁI TỰ ĐỘNG CỦA SỰ KIỆN:',
    subtitle: 'Tính toán động (Dynamic Computation) dựa trên thời gian thực tế của hệ thống',
    details: [
      '• EventModel.isPast: Tự động chuyển true khi thời điểm hiện tại vượt qua thời điểm kết thúc sự kiện.',
      '• EventModel.isRegistrationOpen: Đóng đăng ký (false) ngay khi sự kiện bắt đầu hoặc khi hết chỗ.',
      '• Trạng thái Cổng MobileDesk: Tự động chuyển từ "Chưa mở" sang "Đang mở cổng" khi sự kiện diễn ra.',
      '• Tuân thủ nghiêm ngặt Chính sách Zero-Mock Data: Mọi mốc thời gian đều so khớp với DateTime.now() thật.'
    ],
    colorTheme: 'slate'
  });

  // Group 4: FORBIDDEN TRANSITIONS BOX (BẮT BUỘC THEO SLIDE 08 GUIDELINE) - 760 x 480
  d.addBox({
    x: 790, y: 575, w: 760, h: 480,
    title: 'CÁC CHUYỂN TRẠNG THÁI BỊ CẤM & RÀNG BUỘC TOÀN VẸN (FORBIDDEN TRANSITIONS)',
    subtitle: 'Bắt buộc kiểm thử tự động (Unit Test / Integration Test) để ngăn chặn lỗ hổng bảo mật',
    details: [
      '❌ CẤM: PENDING ➔ USED — Đơn chưa được CTSV duyệt tuyệt đối không được phép soát vé vào cổng.',
      '❌ CẤM: USED ➔ ISSUED — Vé đã check-in không được phép hoàn lại trạng thái chưa quét (Chống tấn công Replay Attack).',
      '❌ CẤM: EXPIRED ➔ USED — Vé của sự kiện đã kết thúc trong quá khứ không được phép check-in tại cổng.',
      '❌ CẤM: PENDING ➔ FEEDBACK_DONE — Sinh viên chưa tham dự sự kiện không được phép gửi đánh giá hay nhận điểm.',
      '❌ CẤM: DRAFT ➔ APPROVED — Phải đi qua hàng chờ PENDING để có vết kiểm toán (Audit Trail) của cán bộ CTSV.',
      '🔒 BẢO VỆ ATOMIC: Mọi thao tác đổi trạng thái vé và duyệt đơn đều chạy qua Firestore RunTransaction bảo đảm tính nhất quán cao.',
      '🧪 MINH CHỨNG KIỂM THỬ: Bộ kiểm thử test/widget_test.dart đã xác nhận toàn bộ 21/21 kịch bản kiểm thử pass 100%.'
    ],
    colorTheme: 'red'
  });

  return d;
}

// =========================================================================
// SLIDE 09: SYSTEM ARCHITECTURE (C4 Container & Deployment)
// =========================================================================
function buildSlide09SystemArchitecture() {
  const d = new DiagramBuilder('09_System_Architecture', 1600, 1150);
  d.addTitle(
    '09. SYSTEM ARCHITECTURE — KIẾN TRÚC HỆ THỐNG & NƠI TRIỂN KHAI',
    'Mô hình C4 Container: Client Presentation Layer ➔ Business Service Layer ➔ Google Firebase Cloud Backend',
    'SLIDE 09 • SYSTEM ARCHITECTURE'
  );

  // Layer 1: Client Layer
  d.addBox({
    x: 40, y: 100, w: 1510, h: 235,
    title: 'TẦNG GIAO DIỆN & TRẢI NGHIỆM KHÁCH (CLIENT PRESENTATION LAYER)',
    subtitle: 'Đa nền tảng: Ứng dụng Di động Native (Sinh viên, CTV) & Cổng Quản trị Web Desktop (Cán bộ CTSV)',
    colorTheme: 'blue'
  });

  d.addBox({
    x: 70, y: 155, w: 700, h: 155,
    title: '📱 Mobile Client — Flutter 3.24 / Dart 3.5 (iOS & Android)',
    subtitle: 'Kiến trúc MVVM sạch, phân tách giao diện và trạng thái dữ liệu (Provider Pattern)',
    details: [
      'Screens: HomeScreen, ExploreScreen, EventDetailScreen, DigitalTicketScreen, LiveCompanionScreen, MobileDeskScreen',
      'State Management: AuthViewModel, ExploreViewModel, RegistrationViewModel, MyTicketsViewModel, LiveEventViewModel',
      'Hardware Access: Camera Scanner QR (1.5s/lượt), Push Notifications (FCM), Local Storage Cache'
    ],
    colorTheme: 'blue'
  });

  d.addBox({
    x: 810, y: 155, w: 710, h: 155,
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
    x: 40, y: 360, w: 1510, h: 195,
    title: 'TẦNG DỊCH VỤ & NGHIỆP VỤ HỆ THỐNG (BUSINESS SERVICE LAYER - LIB/SERVICES/)',
    subtitle: 'Tập trung toàn bộ logic nghiệp vụ độc lập, đóng gói REST API và SDK giao tiếp',
    colorTheme: 'slate'
  });

  d.addBox({ x: 60, y: 415, w: 260, h: 115, title: 'AuthService', subtitle: 'Google SSO & Mail FPT', details: ['Enforce @fpt.edu.vn', 'Firebase Auth Token', 'User state sync'], colorTheme: 'blue' });
  d.addBox({ x: 350, y: 415, w: 290, h: 115, title: 'FirestoreService', subtitle: 'Atomic Transaction Engine', details: ['runTransaction: Check-in', 'Snapshot streams', 'Zero-mock policy'], colorTheme: 'green' });
  d.addBox({ x: 670, y: 415, w: 260, h: 115, title: 'StorageService', subtitle: 'Cloud Storage Handler', details: ['Upload PDF e-Cert', 'Path: reports/{uid}/', 'Signed download URL'], colorTheme: 'amber' });
  d.addBox({ x: 960, y: 415, w: 270, h: 115, title: 'FCMService & RemoteConfig', subtitle: 'Cloud Messaging & Config', details: ['Push thông báo duyệt vé', 'Topic broadcast', 'max_featured_events flag'], colorTheme: 'purple' });
  d.addBox({ x: 1260, y: 415, w: 270, h: 115, title: 'GeminiAiService', subtitle: 'Google GenAI Flash 1.5', details: ['Multi-key pool (10 keys)', 'Round-robin failover', 'Phân tích phản hồi sinh viên'], colorTheme: 'purple' });

  // Layer 3: Cloud Infrastructure Backend
  d.addBox({
    x: 40, y: 580, w: 1510, h: 235,
    title: 'HẠ TẦNG ĐÁM MÂY GOOGLE FIREBASE (CLOUD BACKEND - PROJECT: CAMPUS-EVENT-48443)',
    subtitle: 'Toàn bộ dữ liệu vận hành thực tế 100% trên đám mây Google Cloud Platform (GCP)',
    colorTheme: 'green'
  });

  d.addBox({ x: 60, y: 635, w: 280, h: 155, title: 'Firebase Authentication', subtitle: 'Identity Toolkit & OAuth2', details: ['Đăng nhập tài khoản trường FPT', 'Xác thực hai lớp qua Google', 'Cấp JWT Token định danh'], colorTheme: 'blue' });
  d.addBox({ x: 370, y: 635, w: 480, h: 155, title: 'Cloud Firestore (NoSQL Document Store)', subtitle: 'Multi-Region High Availability & Sub-second Query', details: ['Collections: events, tickets, registrations, clubs, feedback, certificates, announcements', 'Compound Indexes: Lọc vé theo sinh viên và trạng thái check-in', 'Security Rules: Phân quyền truy cập tài liệu nghiêm ngặt'], colorTheme: 'green' });
  d.addBox({ x: 880, y: 635, w: 300, h: 155, title: 'Firebase Cloud Storage', subtitle: 'Bảo mật lưu trữ chứng nhận số', details: ['Lưu trữ PDF e-Certificate SHA-256', 'Quy tắc bảo mật theo UID người dùng', 'Hỗ trợ tải ngoại tuyến'], colorTheme: 'amber' });
  d.addBox({ x: 1210, y: 635, w: 320, h: 155, title: 'FCM & Crashlytics / Analytics', subtitle: 'Hệ thống vận hành viễn trắc', details: ['FCM Push Gateway độ trễ thấp', 'Crashlytics bắt lỗi Crash thời gian thực', 'Google Analytics DebugView'], colorTheme: 'purple' });

  // Layer 4: Architectural Decisions Box
  d.addBox({
    x: 40, y: 840, w: 1510, h: 270,
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
  const d = new DiagramBuilder('10_Technology_Stack', 1600, 1100);
  d.addTitle(
    '10. TECHNOLOGY STACK — BẢNG CÔNG NGHỆ THEO NHÓM VÀ VAI TRÒ SỬ DỤNG',
    'Khớp 100% mã nguồn thực tế và môi trường triển khai của dự án Campus Event Management',
    'SLIDE 10 • TECHNOLOGY STACK'
  );

  const cardWidth = 475;
  const cardHeight = 255;

  d.addBox({
    x: 40, y: 105, w: cardWidth, h: cardHeight,
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

  d.addBox({
    x: 555, y: 105, w: cardWidth, h: cardHeight,
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

  d.addBox({
    x: 1070, y: 105, w: cardWidth, h: cardHeight,
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

  d.addBox({
    x: 40, y: 385, w: cardWidth, h: cardHeight,
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

  d.addBox({
    x: 555, y: 385, w: cardWidth, h: cardHeight,
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

  d.addBox({
    x: 1070, y: 385, w: cardWidth, h: cardHeight,
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

  d.addBox({
    x: 40, y: 665, w: 1505, h: 380,
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
  const d = new DiagramBuilder('12_Sequence_Diagram', 1600, 1220);
  d.addTitle(
    '12. SEQUENCE DIAGRAM — QUY TRÌNH DUYỆT VÉ SLIDE 18 & CHECK-IN CỔNG',
    'Tương tác tuần tự chi tiết giữa Sinh viên, ViewModel, FirestoreService, Web Admin và Bàn soát vé',
    'SLIDE 12 • SEQUENCE DIAGRAM'
  );

  // Lifelines
  const actors = [
    { id: 'act_student', name: 'Sinh viên An\n(:Student)', x: 60 },
    { id: 'act_ui', name: 'Giao diện\n(:EventDetailScreen)', x: 260 },
    { id: 'act_vm', name: 'Bộ điều khiển\n(:RegistrationVM)', x: 480 },
    { id: 'act_svc', name: 'Dịch vụ\n(:FirestoreService)', x: 710 },
    { id: 'act_db', name: '<<Cloud>>\n:CloudFirestore', x: 960 },
    { id: 'act_web', name: 'Cổng Web Admin\n(:WebAdminPortal)', x: 1200 },
    { id: 'act_desk', name: 'Máy quét cổng\n(:MobileDeskScanner)', x: 1410 }
  ];

  actors.forEach(a => {
    d.addBox({
      id: a.id, x: a.x, y: 105, w: 150, h: 55,
      title: a.name, subtitle: '', colorTheme: 'blue', rx: 4
    });

    const lineId = d.nextId();
    d.cells.push(`
      <mxCell id="${lineId}" value="" style="endArrow=none;dashed=1;html=1;strokeWidth=1.5;strokeColor=#94a3b8;" edge="1" parent="1" source="${a.id}">
        <mxGeometry width="50" height="50" relative="1" as="geometry">
          <mxPoint x="${a.x + 75}" y="160" as="sourcePoint" />
          <mxPoint x="${a.x + 75}" y="1080" as="targetPoint" />
        </mxGeometry>
      </mxCell>
    `);
  });

  const steps = [
    { y: 190, x1: 135, x2: 335, label: '1. tap "Đăng ký tham gia"()' },
    { y: 245, x1: 335, x2: 555, label: '2. submitPendingRegistration(event, user)' },
    { y: 300, x1: 555, x2: 785, label: '3. submitRegistration(RegistrationModel)' },
    { y: 355, x1: 785, x2: 1035, label: '4. setDoc(registrations/{regId}, status: "pending")' },
    { y: 415, x1: 1035, x2: 1275, label: '5. onSnapshot() [Thông báo đơn mới chờ duyệt +1]' },
    { y: 475, x1: 1275, x2: 1275, label: '6. Cán bộ CTSV xem xét hồ sơ trên Web Admin (Slide 18)' },
    { y: 535, x1: 1275, x2: 1035, label: '7. approveRegistration(regId) ➔ runTransaction' },
    { y: 595, x1: 1035, x2: 1035, label: '8. update(status: "approved") & create(tickets/{ticketId})' },
    { y: 655, x1: 1035, x2: 555, label: '9. Stream push: Vé mới về thiết bị sinh viên' },
    { y: 715, x1: 555, x2: 335, label: '10. setState(StateSuccess) ➔ Hiển thị DigitalTicket' },
    { y: 775, x1: 135, x2: 1485, label: '11. Sinh viên xuất trình QR tại Bàn kiểm soát cổng' },
    { y: 835, x1: 1485, x2: 785, label: '12. checkInTicket(qrToken) ➔ runTransaction' },
    { y: 895, x1: 785, x2: 1035, label: '13. Atomic update(isUsed: true, checkedInAt: now)' },
    { y: 955, x1: 1035, x2: 1485, label: '14. Return 200 OK (< 1.5s): Mở cổng thành công' },
    { y: 1015, x1: 1035, x2: 335, label: '15. Mở khóa nút Feedback (+5 Điểm rèn luyện) trên Mobile' }
  ];

  steps.forEach((s) => {
    const isSelf = s.x1 === s.x2;
    const arrowId = d.nextId();
    if (isSelf) {
      d.cells.push(`
        <mxCell id="${arrowId}" value="${escapeXml(s.label)}" style="edgeStyle=orthogonalEdgeStyle;rounded=1;html=1;strokeColor=#7c3aed;strokeWidth=1.5;fontFamily=Segoe UI;fontSize=10;fontStyle=1;fontColor=#4c1d95;labelBackgroundColor=#ffffff;labelBorderColor=#c4b5fd;align=left;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="${s.x1}" y="${s.y}" as="sourcePoint" />
            <mxPoint x="${s.x1 + 120}" y="${s.y + 30}" as="targetPoint" />
            <Array as="points">
              <mxPoint x="${s.x1 + 70}" y="${s.y}" />
              <mxPoint x="${s.x1 + 70}" y="${s.y + 30}" />
            </Array>
          </mxGeometry>
        </mxCell>
      `);
    } else {
      d.cells.push(`
        <mxCell id="${arrowId}" value="${escapeXml(s.label)}" style="html=1;verticalAlign=bottom;endArrow=block;strokeColor=#2563eb;strokeWidth=1.5;fontFamily=Segoe UI;fontSize=10;fontStyle=1;fontColor=#0f172a;labelBackgroundColor=#ffffff;labelBorderColor=#93c5fd;" edge="1" parent="1">
          <mxGeometry width="80" relative="1" as="geometry">
            <mxPoint x="${s.x1}" y="${s.y}" as="sourcePoint" />
            <mxPoint x="${s.x2}" y="${s.y}" as="targetPoint" />
            <mxPoint as="offset" y="-12" />
          </mxGeometry>
        </mxCell>
      `);
    }
  });

  d.addBox({
    x: 40, y: 1100, w: 1520, h: 80,
    title: 'NHÁNH NGOẠI LỆ (ALTERNATIVE FLOWS):',
    subtitle: '• alt [Sự kiện hết chỗ / Hết hạn BR-02, BR-03]: FirestoreService ném ngoại lệ ➔ UI hiển thị thông báo lỗi ➔ Hủy luồng.\n• alt [CTSV Từ chối đơn]: CTSV ghi rejectReason ➔ FCM Push thông báo sinh viên lý do từ chối ➔ Không phát hành vé.\n• alt [Quét vé giả hoặc vé đã dùng BR-05]: MobileDesk Scanner rung chuông cảnh báo đỏ "VÉ KHÔNG HỢP LỆ HOẶC ĐÃ QUÉT" ➔ Chặn vào cổng.',
    colorTheme: 'amber', rx: 4
  });

  return d;
}

// =========================================================================
// SLIDE 13: CLASS DESIGN (MVVM UML Class Diagram Non-crossing)
// =========================================================================
function buildSlide13ClassDesign() {
  const d = new DiagramBuilder('13_Class_Design', 1600, 1150);
  d.addTitle(
    '13. CLASS DESIGN — THIẾT KẾ CÁC LỚP TRONG MÃ NGUỒN (MVVM)',
    'Phân định trách nhiệm rõ ràng: Domain Models ➔ ViewModels (State) ➔ Business Services ➔ Cloud Layer',
    'SLIDE 13 • CLASS DESIGN'
  );

  // Group 1: Domain Entities (Models)
  d.addBox({
    x: 40, y: 100, w: 470, h: 980,
    title: '1. TẦNG DOMAIN MODELS (LIB/MODELS/)',
    subtitle: 'Thực thể dữ liệu bất biến, chuyển đổi JSON/Firestore Map',
    colorTheme: 'blue'
  });

  const cEvent = d.addBox({
    x: 60, y: 160, w: 430, h: 205,
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
    x: 60, y: 380, w: 430, h: 205,
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
    x: 60, y: 600, w: 430, h: 205,
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
    x: 60, y: 820, w: 430, h: 205,
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
    x: 545, y: 100, w: 490, h: 980,
    title: '2. TẦNG VIEWMODELS (LIB/VIEWMODELS/)',
    subtitle: 'Kế thừa ChangeNotifier, quản lý trạng thái UI',
    colorTheme: 'purple'
  });

  const vmReg = d.addBox({
    x: 565, y: 160, w: 450, h: 205,
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
    x: 565, y: 380, w: 450, h: 205,
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

  const vmDesk = d.addBox({
    x: 565, y: 600, w: 450, h: 205,
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

  const vmAuth = d.addBox({
    x: 565, y: 820, w: 450, h: 205,
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

  // Group 3: Services (Business Layer)
  d.addBox({
    x: 1070, y: 100, w: 490, h: 980,
    title: '3. TẦNG DỊCH VỤ (LIB/SERVICES/)',
    subtitle: 'Triển khai Atomic Transactions & kết nối Cloud',
    colorTheme: 'green'
  });

  const sFire = d.addBox({
    x: 1090, y: 160, w: 450, h: 320,
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

  const sAiCls = d.addBox({
    x: 1090, y: 505, w: 450, h: 250,
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

  const sAuthCls = d.addBox({
    x: 1090, y: 780, w: 450, h: 260,
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

  // Direct Horizontal Connections across adjacent columns (No crossing!):
  // Col 2 -> Col 3 (calls service):
  d.addConnection({ source: vmReg, target: sFire, label: 'calls', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.3, offsetY: -12 });
  d.addConnection({ source: vmTickets, target: sFire, label: 'calls', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.7, offsetY: -12 });
  d.addConnection({ source: vmDesk, target: sAiCls, label: 'calls', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.5, offsetY: -12 });
  d.addConnection({ source: vmAuth, target: sAuthCls, label: 'calls', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.5, offsetY: -12 });

  // Col 2 -> Col 1 (manages model):
  d.addConnection({ source: vmReg, target: cEvent, label: 'manages', exitX: 0, exitY: 0.5, entryX: 1, entryY: 0.5, offsetY: -12 });
  d.addConnection({ source: vmTickets, target: cTicket, label: 'manages', exitX: 0, exitY: 0.5, entryX: 1, entryY: 0.5, offsetY: -12 });
  d.addConnection({ source: vmAuth, target: cUser, label: 'manages', exitX: 0, exitY: 0.5, entryX: 1, entryY: 0.5, offsetY: -12 });

  return d;
}

// =========================================================================
// SLIDE 14: DATABASE DESIGN 1/2 (Conceptual ERD Non-crossing)
// =========================================================================
function buildSlide14DatabaseConceptual() {
  const d = new DiagramBuilder('14_Database_Conceptual', 1600, 1100);
  d.addTitle(
    '14. DATABASE DESIGN 1/2 — MÔ HÌNH DỮ LIỆU KHÁI NIỆM (CONCEPTUAL ERD)',
    'Mô hình hóa ngữ nghĩa nghiệp vụ, thực thể, mối quan hệ và bản số (Cardinality) — Chưa phụ thuộc DBMS vật lý',
    'SLIDE 14 • DATABASE DESIGN 1/2'
  );

  // Row 1 Entities: eClub -> eEvent -> eReg
  const eClub = d.addBox({
    x: 60, y: 140, w: 280, h: 175,
    title: 'CÂU LẠC BỘ (CLUB)',
    subtitle: 'Đơn vị tổ chức sự kiện',
    details: ['* Mã định danh CLB', '• Tên câu lạc bộ', '• Tên viết tắt', '• Lĩnh vực hoạt động', '• Cán bộ chủ nhiệm'],
    colorTheme: 'purple'
  });

  const eEvent = d.addBox({
    x: 480, y: 140, w: 320, h: 195,
    title: 'SỰ KIỆN (EVENT)',
    subtitle: 'Chương trình được phê duyệt',
    details: ['* Mã sự kiện', '• Tên chủ đề sự kiện', '• Ngày giờ diễn ra', '• Địa điểm / Hội trường', '• Sức chứa tối đa', '• Hạn chót đăng ký', '• Trạng thái vận hành'],
    colorTheme: 'green'
  });

  const eReg = d.addBox({
    x: 930, y: 140, w: 320, h: 185,
    title: 'ĐƠN ĐĂNG KÝ (REGISTRATION)',
    subtitle: 'Hồ sơ chờ duyệt (Slide 18)',
    details: ['* Mã đơn đăng ký', '• Thời điểm nộp đơn', '• Trạng thái xét duyệt (pending/approved/rejected)', '• Lý do từ chối (nếu có)', '• Cán bộ xét duyệt'],
    colorTheme: 'amber'
  });

  // Row 2 Entities: eUser -> eTicket -> eFeedback & eCert
  const eUser = d.addBox({
    x: 60, y: 440, w: 280, h: 180,
    title: 'SINH VIÊN (USER)',
    subtitle: 'Thực thể người học FPT',
    details: ['* Mã sinh viên (MSSV)', '• Họ và tên', '• Email trường (@fpt.edu.vn)', '• Chuyên ngành đào tạo', '• Điểm rèn luyện tích lũy'],
    colorTheme: 'blue'
  });

  const eTicket = d.addBox({
    x: 930, y: 440, w: 320, h: 195,
    title: 'VÉ ĐIỆN TỬ (TICKET)',
    subtitle: 'Vé vào cổng kèm mã bảo mật',
    details: ['* Mã vé điện tử', '• Mã băm QR Token bí mật', '• Trạng thái sử dụng (isUsed)', '• Thời điểm check-in cổng', '• Đã gửi feedback hay chưa'],
    colorTheme: 'green'
  });

  const eFeedback = d.addBox({
    x: 1320, y: 340, w: 250, h: 155,
    title: 'ĐÁNH GIÁ (FEEDBACK)',
    subtitle: 'Khảo sát chất lượng sự kiện',
    details: ['* Mã phiếu đánh giá', '• Điểm số hài lòng (1-5 sao)', '• Nhận xét & góp ý chi tiết', '• Thời điểm nộp phiếu', '• Điểm rèn luyện đã cộng (+5)'],
    colorTheme: 'purple'
  });

  const eCert = d.addBox({
    x: 1320, y: 530, w: 250, h: 155,
    title: 'CHỨNG NHẬN (CERTIFICATE)',
    subtitle: 'Chứng chỉ e-Cert số hóa',
    details: ['* Số hiệu chứng nhận', '• Đường dẫn tệp PDF Cloud', '• Mã băm kiểm định SHA-256', '• Ngày cấp chứng nhận'],
    colorTheme: 'blue'
  });

  // Clean Connections with Zero Crossing:
  // Row 1 horizontal:
  d.addConnection({ source: eClub, target: eEvent, label: 'tổ chức (1,1 ➔ 0,N)', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.5, color: '#7c3aed', strokeWidth: 2, offsetY: -12 });
  d.addConnection({ source: eEvent, target: eReg, label: 'tiếp nhận (1,1 ➔ 0,N)', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.5, color: '#059669', offsetY: -12 });

  // Direct vertical connection between eReg (Row 1) and eTicket (Row 2):
  d.addConnection({ source: eReg, target: eTicket, label: 'duyệt sinh vé [Slide 18]', exitX: 0.5, exitY: 1, entryX: 0.5, entryY: 0, color: '#d97706', strokeWidth: 2, offsetX: 35, offsetY: 0 });

  // Row 2 horizontal connection:
  d.addConnection({ source: eUser, target: eTicket, label: 'sở hữu (1,1 ➔ 0,N)', exitX: 1, exitY: 0.5, entryX: 0, entryY: 0.5, color: '#2563eb', offsetY: -12 });

  // eTicket to right components:
  d.addConnection({ source: eTicket, target: eFeedback, label: 'đánh giá (1,1 ➔ 0,1)', exitX: 1, exitY: 0.3, entryX: 0, entryY: 0.5, color: '#7c3aed', offsetY: -12 });
  d.addConnection({ source: eTicket, target: eCert, label: 'chứng nhận (1,1 ➔ 0,1)', exitX: 1, exitY: 0.7, entryX: 0, entryY: 0.5, color: '#2563eb', offsetY: -12 });

  // Prominent Business Rules Box
  d.addBox({
    x: 60, y: 730, w: 1510, h: 260,
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
  const d = new DiagramBuilder('15_Database_Physical', 1600, 1150);
  d.addTitle(
    '15. DATABASE DESIGN 2/2 — THIẾT KẾ VẬT LÝ CLOUD FIRESTORE NOSQL',
    'Cấu trúc Documents & Collections, Kiểu dữ liệu, Khóa chính, Chỉ mục phức hợp (Indexes) và Ràng buộc bảo mật',
    'SLIDE 15 • DATABASE DESIGN 2/2'
  );

  const colWidth = 355;
  const colHeight = 295;

  d.addBox({
    x: 40, y: 105, w: colWidth, h: colHeight,
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

  d.addBox({
    x: 425, y: 105, w: colWidth + 10, h: colHeight,
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

  d.addBox({
    x: 820, y: 105, w: colWidth + 10, h: colHeight,
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

  d.addBox({
    x: 1215, y: 105, w: colWidth + 10, h: colHeight,
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

  d.addBox({
    x: 40, y: 430, w: colWidth, h: 250,
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

  d.addBox({
    x: 425, y: 430, w: colWidth + 10, h: 250,
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

  d.addBox({
    x: 820, y: 430, w: colWidth + 10, h: 250,
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

  d.addBox({
    x: 1215, y: 430, w: colWidth + 10, h: 250,
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

  d.addBox({
    x: 40, y: 710, w: 1530, h: 360,
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
// MAIN BUILDER: RE-GENERATE ALL FILES WITH PERFECT LAYOUT
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

const fs = require('fs');
const path = require('path');

function toFirestoreFields(obj) {
  const fields = {};
  for (const [key, val] of Object.entries(obj)) {
    if (val === undefined || val === null) continue;
    if (typeof val === 'string') {
      fields[key] = { stringValue: val };
    } else if (typeof val === 'number') {
      fields[key] = Number.isInteger(val) ? { integerValue: String(val) } : { doubleValue: val };
    } else if (typeof val === 'boolean') {
      fields[key] = { booleanValue: val };
    } else if (Array.isArray(val)) {
      fields[key] = {
        arrayValue: {
          values: val.map(v => (typeof v === 'string' ? { stringValue: v } : { mapValue: { fields: toFirestoreFields(v) } }))
        }
      };
    } else if (typeof val === 'object') {
      fields[key] = { mapValue: { fields: toFirestoreFields(val) } };
    }
  }
  return fields;
}

function makeDoc(collection, id, data) {
  return {
    name: `projects/campus-event-48443/databases/(default)/documents/${collection}/${id}`,
    fields: toFirestoreFields(data),
    createTime: '2026-11-11T10:00:00.000000Z',
    updateTime: '2026-11-11T10:00:00.000000Z'
  };
}

const events = [
  {
    id: 'EVT-2026-01',
    title: 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
    description: 'Triển lãm công nghệ thường niên quy mô 500 sinh viên tại Đại học FPT TP.HCM. Cập nhật các xu hướng AI, Generative Agents và cơ hội nghề nghiệp cùng chuyên gia Google, FPT Software.',
    category: 'Technology',
    clubId: 'fcode',
    clubName: 'CLB F-Code',
    date: '28/10/2026',
    time: '13:30 - 17:30',
    location: 'Hội trường Trịnh Công Sơn',
    capacity: 400,
    registeredCount: 342,
    bannerUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800',
    isFeatured: true,
    safetyStatus: 'passed',
    budgetTotal: 15000000,
    budgetSpent: 12500000,
    createdAt: '2026-11-01T08:00:00.000Z'
  },
  {
    id: 'EVT-2026-02',
    title: 'Workshop: Thiết kế UI/UX Chuẩn Công Thái Học Di Động',
    description: 'Khám phá bí quyết thiết kế UI/UX theo 10 Heuristics của Jakob Nielsen, tối ưu Touch Target và đo lường tương phản WCAG 2.1 AA cho ứng dụng di động.',
    category: 'Design',
    clubId: 'media_club',
    clubName: 'CLB Cóc Sài Gòn',
    date: '30/10/2026',
    time: '09:00 - 11:30',
    location: 'Phòng Hội thảo Alpha Building (Phòng 301)',
    capacity: 120,
    registeredCount: 94,
    bannerUrl: 'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?w=800',
    isFeatured: true,
    safetyStatus: 'passed',
    budgetTotal: 5000000,
    budgetSpent: 3800000,
    createdAt: '2026-11-02T08:00:00.000Z'
  },
  {
    id: 'EVT-2026-03',
    title: 'Giải Đấu Thể Thao Điện Tử FPTU Champions League',
    description: 'Vòng chung kết giải thể thao điện tử sinh viên toàn trường, phát sóng trực tiếp kèm quà tặng áo đấu độc quyền FPTU.',
    category: 'Entertainment',
    clubId: 'fcode',
    clubName: 'CLB F-Code',
    date: '05/11/2026',
    time: '18:00 - 21:30',
    location: 'Sân khấu Hội trường Lớn A2',
    capacity: 300,
    registeredCount: 288,
    bannerUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800',
    isFeatured: false,
    safetyStatus: 'passed',
    budgetTotal: 8000000,
    budgetSpent: 6200000,
    createdAt: '2026-11-03T08:00:00.000Z'
  }
];

const gateAssignments = [
  {
    id: 'DUTY-2026-01',
    email: 'kkk@fpt.edu.vn',
    studentName: 'Kkk',
    studentId: 'KKK',
    eventId: 'EVT-2026-01',
    eventTitle: 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
    gateName: 'Cổng Chính (Cửa 1)',
    role: 'Trưởng Bàn Soát Vé (Leader)',
    shiftTime: '13:00 - 17:30',
    status: 'active',
    assignedBy: 'Phòng CTSV',
    assignedAt: '2026-11-11T10:00:00.000Z'
  },
  {
    id: 'DUTY-2026-02',
    email: 'hoangtm.se18@fpt.edu.vn',
    studentName: 'Trần Minh Hoàng',
    studentId: 'SE180123',
    eventId: 'EVT-2026-02',
    eventTitle: 'Workshop: Thiết kế UI/UX Chuẩn Công Thái Học Di Động',
    gateName: 'Phòng Hội thảo Alpha',
    role: 'Cộng Tác Viên (Scanner)',
    shiftTime: '08:30 - 11:30',
    status: 'active',
    assignedBy: 'Phòng CTSV',
    assignedAt: '2026-11-11T10:00:00.000Z'
  },
  {
    id: 'DUTY-2026-03',
    email: 'trongvd.ia18@fpt.edu.vn',
    studentName: 'Vũ Đình Trọng',
    studentId: 'IA184592',
    eventId: 'EVT-2026-03',
    eventTitle: 'Giải Đấu Thể Thao Điện Tử FPTU Champions League',
    gateName: 'Sảnh A Tòa nhà Innovation',
    role: 'Giám Sát An Ninh Cửa',
    shiftTime: '17:30 - 21:30',
    status: 'active',
    assignedBy: 'Phòng CTSV',
    assignedAt: '2026-11-11T10:00:00.000Z'
  }
];

const tickets = [
  {
    id: 'TICKET-2026-01',
    eventId: 'EVT-2026-01',
    userId: 'USR-FPTU-2026',
    eventTitle: 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
    eventDate: '28/10/2026',
    eventTime: '13:30 - 17:30',
    eventLocation: 'Hội trường Trịnh Công Sơn',
    studentName: 'Nguyễn Văn An',
    studentId: 'SE183291',
    ticketCode: 'CE2026-083291',
    qrData: 'FPTU-CE-EVT-2026-01-USR-FPTU-2026-CE2026-083291',
    status: 'checked_in',
    checkInStatus: true,
    checkedInAt: '2026-11-11T10:15:32.000Z',
    gate: 'Cổng Chính (Cửa 1)',
    createdAt: '2026-11-01T09:00:00.000Z'
  },
  {
    id: 'TICKET-2026-02',
    eventId: 'EVT-2026-01',
    userId: 'USR-FPTU-2027',
    eventTitle: 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
    eventDate: '28/10/2026',
    eventTime: '13:30 - 17:30',
    eventLocation: 'Hội trường Trịnh Công Sơn',
    studentName: 'Lê Bảo Long',
    studentId: 'SE181144',
    ticketCode: 'CE2026-081144',
    qrData: 'FPTU-CE-EVT-2026-01-USR-FPTU-2027-CE2026-081144',
    status: 'checked_in',
    checkInStatus: true,
    checkedInAt: '2026-11-11T10:16:04.000Z',
    gate: 'Cổng Chính (Cửa 1)',
    createdAt: '2026-11-01T09:10:00.000Z'
  },
  {
    id: 'TICKET-2026-03',
    eventId: 'EVT-2026-01',
    userId: 'USR-FPTU-2028',
    eventTitle: 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
    eventDate: '28/10/2026',
    eventTime: '13:30 - 17:30',
    eventLocation: 'Hội trường Trịnh Công Sơn',
    studentName: 'Trần Mai Phương',
    studentId: 'SS170889',
    ticketCode: 'CE2026-070889',
    qrData: 'FPTU-CE-EVT-2026-01-USR-FPTU-2028-CE2026-070889',
    status: 'confirmed',
    checkInStatus: false,
    createdAt: '2026-11-01T09:15:00.000Z'
  },
  {
    id: 'TICKET-2026-04',
    eventId: 'EVT-2026-02',
    userId: 'USR-FPTU-2029',
    eventTitle: 'Workshop: Thiết kế UI/UX Chuẩn Công Thái Học Di Động',
    eventDate: '30/10/2026',
    eventTime: '09:00 - 11:30',
    eventLocation: 'Phòng Hội thảo Alpha Building (Phòng 301)',
    studentName: 'Phạm Đăng Khôi',
    studentId: 'GD180231',
    ticketCode: 'CE2026-080231',
    qrData: 'FPTU-CE-EVT-2026-02-USR-FPTU-2029-CE2026-080231',
    status: 'checked_in',
    checkInStatus: true,
    checkedInAt: '2026-11-11T09:45:10.000Z',
    gate: 'Phòng Hội thảo Alpha',
    createdAt: '2026-11-02T10:00:00.000Z'
  },
  {
    id: 'TICKET-2026-05',
    eventId: 'EVT-2026-03',
    userId: 'USR-FPTU-2030',
    eventTitle: 'Giải Đấu Thể Thao Điện Tử FPTU Champions League',
    eventDate: '05/11/2026',
    eventTime: '18:00 - 21:30',
    eventLocation: 'Sân khấu Hội trường Lớn A2',
    studentName: 'Đỗ Hữu Nghĩa',
    studentId: 'IT182219',
    ticketCode: 'CE2026-082219',
    qrData: 'FPTU-CE-EVT-2026-03-USR-FPTU-2030-CE2026-082219',
    status: 'confirmed',
    checkInStatus: false,
    createdAt: '2026-11-03T11:00:00.000Z'
  }
];

const clubs = [
  { id: 'fcode', name: 'CLB F-Code', category: 'Học thuật', membersCount: 120, foundedYear: 2014 },
  { id: 'media_club', name: 'CLB Cóc Sài Gòn', category: 'Truyền thông', membersCount: 85, foundedYear: 2016 },
  { id: 'fpt_dance', name: 'CLB FPT Dance Crew', category: 'Nghệ thuật', membersCount: 65, foundedYear: 2017 }
];

const registrations = [
  {
    id: 'REG-2026-01',
    eventId: 'EVT-2026-01',
    eventTitle: 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
    studentName: 'Hoàng Kim Ngân',
    studentId: 'SE189912',
    studentEmail: 'nganhk.se18@fpt.edu.vn',
    status: 'pending',
    submittedAt: '2026-11-11T09:00:00.000Z'
  },
  {
    id: 'REG-2026-02',
    eventId: 'EVT-2026-01',
    eventTitle: 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
    studentName: 'Đặng Tuấn Anh',
    studentId: 'IA180451',
    studentEmail: 'anhdt.ia18@fpt.edu.vn',
    status: 'pending',
    submittedAt: '2026-11-11T09:30:00.000Z'
  }
];

const announcements = [
  {
    id: 'ANN-01',
    title: 'Khai mạc FPTU Tech Expo 2026 tại Hội trường Trịnh Công Sơn',
    category: 'official',
    categoryLabel: 'Phát thanh CTSV',
    message: 'Toàn bộ sinh viên đã đăng ký vui lòng xuất trình mã QR tại Bàn Điểm Danh Cổng 1 hoặc Cổng 2 trước 13:30.',
    pinned: true,
    createdAt: '2026-11-11T07:00:00.000Z',
    status: 'published'
  }
];

const cache = {
  'GET:/events': {
    timestamp: Date.now(),
    data: { documents: events.map(e => makeDoc('events', e.id, e)) }
  },
  'GET:/gate_assignments': {
    timestamp: Date.now(),
    data: { documents: gateAssignments.map(g => makeDoc('gate_assignments', g.id, g)) }
  },
  'GET:/tickets': {
    timestamp: Date.now(),
    data: { documents: tickets.map(t => makeDoc('tickets', t.id, t)) }
  },
  'GET:/clubs': {
    timestamp: Date.now(),
    data: { documents: clubs.map(c => makeDoc('clubs', c.id, c)) }
  },
  'GET:/registrations': {
    timestamp: Date.now(),
    data: { documents: registrations.map(r => makeDoc('registrations', r.id, r)) }
  },
  'GET:/announcements': {
    timestamp: Date.now(),
    data: { documents: announcements.map(a => makeDoc('announcements', a.id, a)) }
  }
};

const targetPath = path.join(__dirname, '.firestore_cache.json');
fs.writeFileSync(targetPath, JSON.stringify(cache, null, 2), 'utf8');
console.log(`[Cache Generator] Wrote ${Object.keys(cache).length} collections snapshot to ${targetPath}`);

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
  },
  {
    id: 'EVT-2026-04',
    title: 'FPT Hackathon 2026: Sáng Tạo Ứng Dụng Di Động & AI',
    description: 'Cuộc thi lập trình 24 giờ thử thách sinh viên FPT xây dựng ứng dụng di động thông minh tích hợp AI Agent và Cloud Firestore.',
    category: 'Technology',
    clubId: 'fcode',
    clubName: 'CLB F-Code',
    date: '25/11/2026',
    time: '08:00 - 17:30',
    location: 'Hội trường Trịnh Công Sơn',
    capacity: 200,
    registeredCount: 0,
    bannerUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800',
    isFeatured: true,
    safetyStatus: 'passed',
    budgetTotal: 12000000,
    budgetSpent: 4500000,
    createdAt: '2026-11-11T16:00:00.000Z'
  },
  {
    id: 'EVT-2026-05',
    title: 'FPTU Music Festival & Gala Chào Tân Sinh Viên 2026',
    description: 'Đại nhạc hội sinh viên chào đón K20 với sự góp mặt của các ban nhạc acoustic và vũ đoàn Cóc Sài Gòn.',
    category: 'Entertainment',
    clubId: 'media_club',
    clubName: 'CLB Cóc Sài Gòn',
    date: '28/11/2026',
    time: '18:30 - 22:00',
    location: 'Sân khấu Hội trường Lớn A2',
    capacity: 350,
    registeredCount: 0,
    bannerUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
    isFeatured: true,
    safetyStatus: 'passed',
    budgetTotal: 20000000,
    budgetSpent: 8000000,
    createdAt: '2026-11-11T16:00:00.000Z'
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
  {
    "id": "fcode",
    "name": "F-Code",
    "acronym": "F-Code",
    "category": "Technology",
    "description": "Câu lạc bộ Học thuật Lập trình và Thuật toán hàng đầu Đại học FPT TP.HCM.",
    "followerCount": 2450,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/11/logo-f-code.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/f-code/",
    "fanpageUrl": "https://www.facebook.com/fcodefpt/",
    "email": "fcode.fptuhcm@gmail.com"
  },
  {
    "id": "ai_95",
    "name": "Câu lạc bộ 9.5AI – FPTU HCM AI Club",
    "acronym": "9.5AI",
    "category": "Technology",
    "description": "Cộng đồng nghiên cứu và phát triển Trí tuệ Nhân tạo tại FPTU HCM.",
    "followerCount": 1320,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2024/01/logo-9.5ai.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/cau-lac-bo-9-5ai-fptu-hcm-ai-club/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/cau-lac-bo-sinh-vien/cau-lac-bo-9-5ai/",
    "email": "9.5aifptuclub@gmail.com"
  },
  {
    "id": "ai4sd",
    "name": "Exploring AI Applications in Software Development Club",
    "acronym": "AI4SD",
    "category": "Technology",
    "description": "Nghiên cứu ứng dụng thực chiến của AI và LLM trong quy trình phát triển phần mềm.",
    "followerCount": 980,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2024/03/logo-ai4sd.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/exploring-ai-applications-in-software-development-club/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/hcm/exploring-ai-applications-in-software-development-club/"
  },
  {
    "id": "farpc",
    "name": "AIoT Research Pioneer Club",
    "acronym": "FARPC",
    "category": "Technology",
    "description": "Nghiên cứu kết hợp Trí tuệ Nhân tạo và Internet vạn vật (AIoT).",
    "followerCount": 870,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2024/02/logo-farpc.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/aiot-research-pioneer-club/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/hcm/aiot-research-pioneer-club/"
  },
  {
    "id": "gdoc",
    "name": "Google Developer Group on Campus FPTU",
    "acronym": "GDGoC",
    "category": "Technology",
    "description": "Cộng đồng lập trình viên sinh viên do Google hỗ trợ tại Đại học FPT TP.HCM.",
    "followerCount": 3100,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/10/logo-gdgoc.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/google-developer-group-on-campus-fptu/",
    "fanpageUrl": "https://gdg.community.dev/events/details/google-gdg-on-campus-fpt-university-ho-chi-minh-city-vietnam-presents-gdgoc-fptu-hcmc-core-members-recruitment-gen-20/",
    "email": "gdsc.fpt.hcm23@gmail.com"
  },
  {
    "id": "fia",
    "name": "FPT Information Assurance Club",
    "acronym": "FIA",
    "category": "Technology",
    "description": "Cộng đồng nghiên cứu An toàn thông tin, Cyber Security và CTF tại FPTU HCM.",
    "followerCount": 1950,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/09/logo-fia.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-information-assurance-club/",
    "fanpageUrl": "https://www.facebook.com/fptinformationassurance/",
    "email": "fiafptinformationassurance@gmail.com"
  },
  {
    "id": "blockuni",
    "name": "BlockUni – The Blockchain Academic Community",
    "acronym": "BlockUni",
    "category": "Technology",
    "description": "Cộng đồng học thuật nghiên cứu công nghệ Blockchain, Web3 và Smart Contract.",
    "followerCount": 1120,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2024/01/logo-blockuni.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/blockuni-the-blockchain-academic-community/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/en/hm/blockuni-the-blockchain-academic-community/"
  },
  {
    "id": "icd",
    "name": "FPT Integrated Circuit Club",
    "acronym": "ICD",
    "category": "Technology",
    "description": "Câu lạc bộ Thiết kế Vi mạch và Bán dẫn tại Đại học FPT TP.HCM.",
    "followerCount": 760,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2024/04/logo-icd.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-integrated-circuit-club/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/en/hm/FPT-Integrated-Circuit-Club/"
  },
  {
    "id": "devsecops_02h",
    "name": "DevSecOps Club",
    "acronym": "02H",
    "category": "Technology",
    "description": "Thực hành văn hóa DevOps, tự động hóa CI/CD và an toàn hạ tầng đám mây.",
    "followerCount": 890,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2024/03/logo-devsecops.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/devsecops-club/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/cau-lac-bo-tp-ho-chi-minh/"
  },
  {
    "id": "mtc",
    "name": "Mathematics Thinking Club",
    "acronym": "MTC",
    "category": "Academic",
    "description": "Rèn luyện và phát triển tư duy toán học ứng dụng trong khoa học máy tính.",
    "followerCount": 1050,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/12/logo-mtc.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/mathematics-thinking-club/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/hcm/mathematics-thinking-club/"
  },
  {
    "id": "dac",
    "name": "Dynamic Art Club",
    "acronym": "DAC",
    "category": "Design",
    "description": "Sáng tạo mỹ thuật số, thiết kế đồ họa 2D/3D và nghệ thuật thị giác.",
    "followerCount": 1750,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/11/logo-dac.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/dynamic-art-club/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/en/student-club/dynamic-art-club/"
  },
  {
    "id": "bec",
    "name": "Business Economics Club",
    "acronym": "BEC",
    "category": "Business",
    "description": "Cộng đồng sinh viên đam mê kinh tế, tài chính và phân tích kinh doanh.",
    "followerCount": 2100,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/08/logo-bec.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/business-economics-club/",
    "fanpageUrl": "https://www.facebook.com/bec.fptuhcm/",
    "email": "bec.fptuhcm@gmail.com"
  },
  {
    "id": "fip",
    "name": "FPT Innovation Path Club",
    "acronym": "FIP",
    "category": "Business",
    "description": "Thúc đẩy tinh thần khởi nghiệp, sáng tạo dự án kinh doanh công nghệ sinh viên.",
    "followerCount": 930,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2024/02/logo-fip.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-innovation-path-club/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-innovation-path-club/"
  },
  {
    "id": "flsc",
    "name": "FPT Logistics & Supply Chain Club",
    "acronym": "F-LSC",
    "category": "Business",
    "description": "Chia sẻ chuyên môn về quản lý chuỗi cung ứng, xuất nhập khẩu và logistics.",
    "followerCount": 1420,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/12/logo-flsc.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-logistics-supply-chain-club/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-logistics-supply-chain-club/",
    "email": "flsc.fptuhcm@gmail.com"
  },
  {
    "id": "skillcetera",
    "name": "Skillcetera – Skills and Languages Club",
    "acronym": "Skillcetera",
    "category": "Languages",
    "description": "Rèn luyện kỹ năng mềm, thuyết trình và giao tiếp ngoại ngữ đa văn hóa.",
    "followerCount": 1680,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/09/logo-skillcetera.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/skillcetera-skills-and-languages-club/",
    "fanpageUrl": "https://www.facebook.com/skillcetera/",
    "email": "skillcetera@gmail.com"
  },
  {
    "id": "ssc",
    "name": "Soft Skills Club",
    "acronym": "SSC",
    "category": "Skills",
    "description": "Môi trường phát triển kỹ năng lãnh đạo, làm việc nhóm và giao tiếp chuyên nghiệp.",
    "followerCount": 1850,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/10/logo-ssc.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/soft-skills-club/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/hcm/soft-skills-club/"
  },
  {
    "id": "eac",
    "name": "ELF Academic Club",
    "acronym": "EAC",
    "category": "Languages",
    "description": "Nâng cao năng lực tiếng Anh học thuật qua trải nghiệm thực tế và cuộc thi Skill Show.",
    "followerCount": 1290,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/11/logo-eac.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/elf-academic-club/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-skill-show-mua-3-hoc-tieng-anh-qua-trai-nghiem-thuc-te/",
    "email": "eldepartmentfptu@gmail.com"
  },
  {
    "id": "jcl",
    "name": "Japanese Chinese Language",
    "acronym": "JCL",
    "category": "Languages",
    "description": "Giao lưu ngôn ngữ, văn hóa và nâng cao năng lực tiếng Nhật và tiếng Trung.",
    "followerCount": 1150,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2024/01/logo-jcl.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/japanese-chinese-language/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/hcm/japanese-chinese-language/"
  },
  {
    "id": "csg",
    "name": "Câu lạc bộ Truyền thông Cóc Sài Gòn",
    "acronym": "CSG",
    "category": "Media",
    "description": "Kênh thông tin truyền thông sinh viên hàng đầu tại Đại học FPT TP.HCM.",
    "followerCount": 5200,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/07/logo-coc-sai-gon.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/cau-lac-bo-truyen-thong-coc-sai-gon-2/",
    "fanpageUrl": "https://www.facebook.com/cocsaigonfuhcm/",
    "email": "csg.fptuhcm@gmail.com"
  },
  {
    "id": "media_club",
    "name": "Câu lạc bộ Truyền thông Cóc Sài Gòn (Legacy ID)",
    "acronym": "CSG",
    "category": "Media",
    "description": "Kênh thông tin truyền thông sinh viên hàng đầu tại Đại học FPT TP.HCM.",
    "followerCount": 5200,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/07/logo-coc-sai-gon.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/cau-lac-bo-truyen-thong-coc-sai-gon-2/",
    "fanpageUrl": "https://www.facebook.com/cocsaigonfuhcm/",
    "email": "csg.fptuhcm@gmail.com"
  },
  {
    "id": "fev",
    "name": "Câu lạc bộ Tổ chức Sự kiện Trường Đại học FPT",
    "acronym": "FEV",
    "category": "Media",
    "description": "Chuyên nghiệp trong tổ chức các đại nhạc hội và ngày hội văn hóa sinh viên.",
    "followerCount": 4600,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/08/logo-fev.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/cau-lac-bo-to-chuc-su-kien-truong-dai-hoc-fpt/",
    "fanpageUrl": "https://www.facebook.com/FPTEventClub/",
    "email": "fpteventclub@gmail.com"
  },
  {
    "id": "mec",
    "name": "MEC – Multimedia & Entertainment Club",
    "acronym": "MEC",
    "category": "Media",
    "description": "Sản xuất hình ảnh, video và nội dung giải trí đa phương tiện sinh viên.",
    "followerCount": 2300,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/09/logo-mec.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/mec-multimedia-entertainment-club/",
    "fanpageUrl": "https://www.facebook.com/Mec.Fptuhcm/"
  },
  {
    "id": "frc",
    "name": "FPT RadiSound Club",
    "acronym": "FRC",
    "category": "Arts",
    "description": "Câu lạc bộ phát thanh, sản xuất podcast và âm thanh cảm xúc kết nối sinh viên.",
    "followerCount": 1350,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/10/logo-frc.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-radisound-club/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-radisound-club/"
  },
  {
    "id": "fstyle",
    "name": "FStyle Hiphop Club (FStyle Crew)",
    "acronym": "FStyle",
    "category": "Arts",
    "description": "Đội nhóm vũ đạo Hip-hop năng động, biểu diễn tại các sân khấu lớn của trường.",
    "followerCount": 3400,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/07/logo-fstyle.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/fstyle-hiphop-club/",
    "fanpageUrl": "https://www.facebook.com/FStyleFamily/",
    "email": "fstyle.hcmfptu@gmail.com"
  },
  {
    "id": "fsharp",
    "name": "F# Live Music Club",
    "acronym": "F#",
    "category": "Arts",
    "description": "Ban nhạc sinh viên FPTU, nơi hội tụ các tài năng thanh nhạc và nhạc cụ.",
    "followerCount": 2950,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/08/logo-fsharp.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/f-live-music-club/",
    "fanpageUrl": "https://www.facebook.com/FsharpLiveMusicClub/",
    "email": "fsharp.fpthcm@gmail.com"
  },
  {
    "id": "fbk",
    "name": "FPT Beat King Club",
    "acronym": "FBK",
    "category": "Arts",
    "description": "Cộng đồng Beatbox, Rap và âm nhạc đường phố năng động tại FPTU.",
    "followerCount": 1870,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/09/logo-fbk.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-beat-king-club/",
    "fanpageUrl": "https://www.facebook.com/FPTBeatKingClub/",
    "email": "fbk.fptuhcm@gmail.com"
  },
  {
    "id": "fti",
    "name": "FPTU Traditional Instruments",
    "acronym": "FTI",
    "category": "Arts",
    "description": "Bảo tồn và biểu diễn nhạc cụ truyền thống dân tộc: Tranh, Bầu, Sáo, Nhị, Nguyệt.",
    "followerCount": 2150,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/08/logo-fti.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/fptu-traditional-instruments/",
    "fanpageUrl": "https://www.facebook.com/ftihcm/",
    "email": "fti.fptuhcm@gmail.com"
  },
  {
    "id": "jsclub",
    "name": "Japan Style Club – CLB Phong Cách Nhật Bản",
    "acronym": "JSC",
    "category": "Culture",
    "description": "Cộng đồng giao lưu văn hóa Nhật Bản, Cosplay, Anime và tổ chức lễ hội văn hóa.",
    "followerCount": 2600,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/09/logo-jsc.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/japan-style-club/",
    "fanpageUrl": "https://www.facebook.com/clbJSC/",
    "email": "jsc.fptuhcm@gmail.com"
  },
  {
    "id": "fcf",
    "name": "FPT Cooking Forever (Cộng đồng FCF)",
    "acronym": "FCF",
    "category": "Lifestyle",
    "description": "Cộng đồng giao lưu ẩm thực, chia sẻ công thức nấu ăn và gắn kết sinh viên.",
    "followerCount": 1250,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/11/logo-fcf.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-cooking-forever/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/en/hm/FPT-Cooking-Forever/",
    "email": "fptcookingforever.host@gmail.com"
  },
  {
    "id": "fvc",
    "name": "FPT Vovinam Club",
    "acronym": "FVC",
    "category": "Sports",
    "description": "Rèn luyện thể lực và tinh thần võ đạo Việt Võ Đạo đặc trưng của FPT.",
    "followerCount": 3800,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/07/logo-fvc.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-vovinam-club/",
    "fanpageUrl": "https://www.facebook.com/fvchcm/",
    "email": "fptuvovinamclub@gmail.com"
  },
  {
    "id": "ffc",
    "name": "FFC – Câu Lạc Bộ Bóng Đá FPTU HCM",
    "acronym": "FFC",
    "category": "Sports",
    "description": "Sân chơi bóng đá phong trào và đại diện thi đấu các giải sinh viên toàn thành.",
    "followerCount": 3100,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/07/logo-ffc.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/ffc-cau-lac-bo-bong-da-fptu-hcm/",
    "fanpageUrl": "https://www.facebook.com/FFC.FPTUHCM/",
    "email": "ffc.fptuhcm@gmail.com"
  },
  {
    "id": "fvb",
    "name": "FPT Volleyball Club",
    "acronym": "FVB",
    "category": "Sports",
    "description": "Cộng đồng đam mê bóng chuyền nam & nữ, rèn luyện thể lực và tinh thần đồng đội.",
    "followerCount": 2250,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/08/logo-fvb.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-volleyball-club/",
    "fanpageUrl": "https://www.facebook.com/volleyballfpt/",
    "email": "fptuhcmfvb@gmail.com"
  },
  {
    "id": "fuv",
    "name": "FPT University Volleyball",
    "acronym": "FUV",
    "category": "Sports",
    "description": "Đội tuyển và nhóm rèn luyện bóng chuyền nâng cao tại cơ sở TP.HCM.",
    "followerCount": 1400,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/10/logo-fuv.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/cau-lac-bo-sinh-vien/clbhcm/the-thao/fpt-university-volleyball/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/chuyen-muc/cau-lac-bo-sinh-vien/clbhcm/the-thao/"
  },
  {
    "id": "fbc",
    "name": "FPTU HCM Basketball Club",
    "acronym": "FBC",
    "category": "Sports",
    "description": "Cộng đồng bóng rổ sôi động, giao lưu thi đấu và nâng cao kỹ năng bóng rổ.",
    "followerCount": 2500,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/08/logo-fbc.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/trai-nghiem-sinh-vien/hoat-dong-sinh-vien/danh-sach-cac-cau-lac-bo/",
    "fanpageUrl": "https://www.facebook.com/fptuhcmbasketballclub/",
    "email": "fbc.fptuhcm@gmail.com"
  },
  {
    "id": "fba",
    "name": "FBA – FPTU HCM Badminton Club",
    "acronym": "FBA",
    "category": "Sports",
    "description": "Sân chơi cầu lông năng động cho sinh viên giao lưu, giải trí và rèn luyện thể thao.",
    "followerCount": 2380,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/09/logo-fba.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/en/student-experience/student-activities/list-of-clubs/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/en/student-experience/student-activities/list-of-clubs/",
    "email": "fptuba0123@gmail.com"
  },
  {
    "id": "fcc",
    "name": "FPT Chess Club",
    "acronym": "FCC",
    "category": "Sports",
    "description": "Bộ môn cờ vua, cờ tướng và rèn luyện tư duy chiến thuật bàn cờ.",
    "followerCount": 1320,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/10/logo-fcc.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-chess-club/",
    "fanpageUrl": "https://www.facebook.com/FptChessClubFcc/",
    "email": "fcc.fptuhcm@gmail.com"
  },
  {
    "id": "fbg",
    "name": "FBG – FPT Boardgame Club",
    "acronym": "FBG",
    "category": "Sports",
    "description": "Sân chơi gắn kết sinh viên qua các trò chơi board game chiến thuật và tương tác.",
    "followerCount": 1650,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/11/logo-fbg.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hoat-dong-sinh-vien-2/sinh-vien-truong-f-noi-gi-ve-bo-mon-boardgame/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/trai-nghiem-sinh-vien/hoat-dong-sinh-vien/danh-sach-cac-cau-lac-bo/",
    "email": "fbghcm.fptboardgameclub@gmail.com"
  },
  {
    "id": "fsc",
    "name": "FPT Southern Calisthenics (FPT Styles and Calisthenics)",
    "acronym": "FSC",
    "category": "Sports",
    "description": "Bộ môn thể hình đường phố (Calisthenics), rèn luyện sức bền và thể lực tự nhiên.",
    "followerCount": 1200,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/12/logo-fsc.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-southern-calisthenics/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/cau-lac-bo-sinh-vien/fpt-southern-calisthenics/",
    "email": "fsc.fptuhcm23@gmail.com"
  },
  {
    "id": "esf",
    "name": "ESports FPTU HCMC",
    "acronym": "ESF",
    "category": "Sports",
    "description": "Cộng đồng thể thao điện tử, tổ chức giải đấu Liên Minh Huyền Thoại, Valorant.",
    "followerCount": 3600,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/07/logo-esf.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/esports-fptu-hcmc/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/chuyen-muc/cau-lac-bo-sinh-vien/clbhcm/the-thao/"
  },
  {
    "id": "sitigroup",
    "name": "Cộng đồng Sinh viên Tình nguyện SiTiGroup",
    "acronym": "SiTiGroup",
    "category": "Community",
    "description": "Cộng đồng sinh viên tình nguyện lớn nhất FPTU TP.HCM với các dự án vì cộng đồng.",
    "followerCount": 4900,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/07/logo-sitigroup.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/cong-dong-sinh-vien-tinh-nguyen-sitigroup/",
    "fanpageUrl": "https://www.facebook.com/sititgroupfuhcm/",
    "email": "sitigroup.fptuhcm@gmail.com"
  },
  {
    "id": "elf4c",
    "name": "ELF for Community Club",
    "acronym": "ELF-4-C",
    "category": "Community",
    "description": "Dự án mang giáo dục tiếng Anh và trải nghiệm đến các trường học và cộng đồng địa phương.",
    "followerCount": 1180,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/12/logo-elf4c.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/elf-for-community-club/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/hcm/fpt-university-and-its-students-bring-educational-activities-to-local-schools-and-communities-through-lectures-demonstrations-classes-and-outreach-projects-organised-on-a-programmed-and-ad-hoc-basis/"
  },
  {
    "id": "fsa",
    "name": "CLB Đại Sứ Sinh Viên",
    "acronym": "FSA",
    "category": "Community",
    "description": "Đại sứ hình ảnh, dẫn đoàn và hỗ trợ các chương trình tiếp đón đối tác của nhà trường.",
    "followerCount": 2200,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/08/logo-fsa.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/hcm/clb-dai-su-sinh-vien/",
    "fanpageUrl": "https://daihoc.fpt.edu.vn/cau-lac-bo-sinh-vien/clb-dai-su-sinh-vien/"
  },
  {
    "id": "hnf",
    "name": "Hardware Network FPTU",
    "acronym": "HNF",
    "category": "Technology",
    "description": "Nghiên cứu kiến trúc máy tính, mạng máy tính và phần cứng hệ thống.",
    "followerCount": 950,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/09/logo-hnf.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/trai-nghiem-sinh-vien/hoat-dong-sinh-vien/diem-danh-tat-tan-tat-cac-clb-tai-dai-hoc-fpt-3-mien/",
    "fanpageUrl": "https://www.facebook.com/hnffptu/"
  },
  {
    "id": "fps",
    "name": "FPTU Public Speaking",
    "acronym": "FPS",
    "category": "Skills",
    "description": "Rèn luyện kỹ năng diễn thuyết, tranh biện và thuyết phục trước đám đông.",
    "followerCount": 1480,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/10/logo-fps.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/trai-nghiem-sinh-vien/hoat-dong-sinh-vien/diem-danh-tat-tan-tat-cac-clb-tai-dai-hoc-fpt-3-mien/",
    "fanpageUrl": "https://www.facebook.com/FPTUPublicSpeakingClub/"
  },
  {
    "id": "fac",
    "name": "FPT Art and Culture Community",
    "acronym": "FAC",
    "category": "Culture",
    "description": "Kết nối và lan tỏa các giá trị văn hóa nghệ thuật truyền thống và đương đại.",
    "followerCount": 1360,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/11/logo-fac.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/trai-nghiem-sinh-vien/hoat-dong-sinh-vien/diem-danh-tat-tan-tat-cac-clb-tai-dai-hoc-fpt-3-mien/",
    "fanpageUrl": "https://www.facebook.com/fac.fptuhcm/"
  },
  {
    "id": "udc",
    "name": "Unity Dance Crew",
    "acronym": "UDC",
    "category": "Arts",
    "description": "Nhóm nhảy hiện đại phong trào, cống hiến những màn vũ đạo sôi động cho sinh viên.",
    "followerCount": 1890,
    "logoUrl": "https://daihoc.fpt.edu.vn/wp-content/uploads/2023/08/logo-udc.png",
    "officialUrl": "https://daihoc.fpt.edu.vn/trai-nghiem-sinh-vien/hoat-dong-sinh-vien/diem-danh-tat-tan-tat-cac-clb-tai-dai-hoc-fpt-3-mien/",
    "fanpageUrl": "https://www.facebook.com/udcsg.fpt/"
  }
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

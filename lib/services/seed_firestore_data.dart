import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// One-click Cloud Firestore Database Seeder
/// Populates all required FPT University collections with structured demo documents.
class FirestoreSeeder {
  static Future<int> seedAll(FirebaseFirestore firestore) async {
    int count = 0;
    final batch = firestore.batch();

    // 1. Seed Users Collection
    final userRef = firestore.collection('users').doc('USR-FPTU-2026');
    batch.set(userRef, {
      'id': 'USR-FPTU-2026',
      'name': 'Nguyễn Văn An',
      'email': 'an.nv@fptu.edu.vn',
      'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      'major': 'Kỹ thuật Phần mềm (SE18)',
      'activityPoints': 25,
      'role': 'student',
      'followedClubs': ['fcode', 'media_club'],
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    count++;

    // 2. Seed Clubs Collection
    final clubs = [
      {
        'id': 'fcode',
        'name': 'CLB Học thuật F-Code',
        'category': 'Technology',
        'description': 'Câu lạc bộ Lập trình và Thuật toán hàng đầu Đại học FPT TP.HCM.',
        'followerCount': 2450,
        'logoUrl': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=120',
      },
      {
        'id': 'jsclub',
        'name': 'CLB Kỹ sư phần mềm Nhật Bản',
        'category': 'Technology',
        'description': 'Cộng đồng sinh viên định hướng làm việc tại các tập đoàn công nghệ Nhật Bản.',
        'followerCount': 1820,
        'logoUrl': 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=120',
      },
      {
        'id': 'media_club',
        'name': 'CLB Truyền thông Cóc Sài Gòn',
        'category': 'Media',
        'description': 'Tổ chức các sự kiện văn hóa, truyền thông và giải trí sinh viên FPTU.',
        'followerCount': 3890,
        'logoUrl': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=120',
      },
    ];

    for (final club in clubs) {
      final docRef = firestore.collection('clubs').doc(club['id'] as String);
      batch.set(docRef, club, SetOptions(merge: true));
      count++;
    }

    // 3. Seed Events Collection
    final events = [
      {
        'id': 'EVT-2026-01',
        'title': 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
        'description': 'Triển lãm công nghệ thường niên quy mô 500 sinh viên tại Đại học FPT TP.HCM. Cập nhật các xu hướng AI, Generative Agents và cơ hội nghề nghiệp cùng chuyên gia Google, FPT Software.',
        'category': 'Technology',
        'clubId': 'fcode',
        'clubName': 'CLB F-Code',
        'date': '28/10/2026',
        'time': '13:30 - 17:30',
        'location': 'Hội trường Trịnh Công Sơn',
        'capacity': 400,
        'registeredCount': 342,
        'bannerUrl': 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800',
        'isFeatured': true,
        'speakers': [
          {
            'name': 'TS. Nguyễn Văn Hùng',
            'role': 'Trưởng ban Nghiên cứu AI, FPT Software',
            'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120',
          },
          {
            'name': 'ThS. Trần Thu Hà',
            'role': 'Product Lead, Google Developer Group',
            'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120',
          },
        ],
        'sessions': [
          {'time': '13:30', 'title': 'Đón tiếp sinh viên & Check-in QR', 'speakerName': 'Ban Tổ Chức'},
          {'time': '14:00', 'title': 'Keynote: Kỷ nguyên Autonomous Coding Agents', 'speakerName': 'TS. Nguyễn Văn Hùng'},
          {'time': '15:15', 'title': 'Workshop: Xây dựng Mobile App với Flutter & Firebase', 'speakerName': 'ThS. Trần Thu Hà'},
          {'time': '16:30', 'title': 'Q&A trực tiếp cùng Diễn giả & Trao chứng nhận', 'speakerName': 'Toàn thể Diễn giả'},
        ],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'EVT-2026-02',
        'title': 'Workshop: Thiết kế UI/UX Chuẩn Công Thái Học Di Động',
        'description': 'Khám phá bí quyết thiết kế UI/UX theo 10 Heuristics của Jakob Nielsen, tối ưu Touch Target và đo lường tương phản WCAG 2.1 AA cho ứng dụng di động.',
        'category': 'Design',
        'clubId': 'media_club',
        'clubName': 'CLB Cóc Sài Gòn',
        'date': '30/10/2026',
        'time': '09:00 - 11:30',
        'location': 'Phòng Hội thảo Alpha Building (Phòng 301)',
        'capacity': 120,
        'registeredCount': 94,
        'bannerUrl': 'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?w=800',
        'isFeatured': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'EVT-2026-03',
        'title': 'Giải Đấu Thể Thao Điện Tử FPTU Champions League',
        'description': 'Vòng chung kết giải thể thao điện tử sinh viên toàn trường, phát sóng trực tiếp kèm quà tặng áo đấu độc quyền FPTU.',
        'category': 'Entertainment',
        'clubId': 'fcode',
        'clubName': 'CLB F-Code',
        'date': '05/11/2026',
        'time': '18:00 - 21:30',
        'location': 'Sân khấu Hội trường Lớn A2',
        'capacity': 300,
        'registeredCount': 288,
        'bannerUrl': 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800',
        'isFeatured': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final evt in events) {
      final docRef = firestore.collection('events').doc(evt['id'] as String);
      batch.set(docRef, evt, SetOptions(merge: true));
      count++;
    }

    // 4. Seed Tickets Collection
    final ticketRef = firestore.collection('tickets').doc('TICKET-2026-01');
    batch.set(ticketRef, {
      'id': 'TICKET-2026-01',
      'eventId': 'EVT-2026-01',
      'userId': 'USR-FPTU-2026',
      'eventTitle': 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
      'eventDate': '28/10/2026',
      'eventTime': '13:30 - 17:30',
      'eventLocation': 'Hội trường Trịnh Công Sơn',
      'studentName': 'Nguyễn Văn An',
      'studentId': 'SE183291',
      'ticketCode': 'CE2026-083291',
      'qrData': 'FPTU-CE-EVT-2026-01-USR-FPTU-2026-CE2026-083291',
      'status': 'confirmed',
      'checkInStatus': false,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    count++;

    // 5. Seed Questions Subcollection
    final questions = [
      {
        'id': 'Q-01',
        'eventId': 'EVT-2026-01',
        'userId': 'USR-TEST-02',
        'studentName': 'Lê Minh Quân (SE17)',
        'question': 'Diễn giả đánh giá thế nào về tốc độ suy luận của Gemini 1.5 Flash so với GPT-4o trên thiết bị di động?',
        'upvotes': 18,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'Q-02',
        'eventId': 'EVT-2026-01',
        'userId': 'USR-TEST-03',
        'studentName': 'Trần Hoài Nam (IA18)',
        'question': 'Sinh viên năm 2 nên bắt đầu học Machine Learning từ nền tảng toán nào trước ạ?',
        'upvotes': 12,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final q in questions) {
      final docRef = firestore
          .collection('events')
          .doc('EVT-2026-01')
          .collection('questions')
          .doc(q['id'] as String);
      batch.set(docRef, q, SetOptions(merge: true));
      count++;
    }

    // 6. Seed Certificates Collection
    final certRef = firestore.collection('certificates').doc('CERT-2026-9901');
    batch.set(certRef, {
      'id': 'CERT-2026-9901',
      'eventId': 'EVT-2026-01',
      'eventTitle': 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
      'userId': 'USR-FPTU-2026',
      'studentName': 'Nguyễn Văn An',
      'issueDate': '28/10/2026',
      'verificationHash': 'HASH-FPTU-CERT-CE2026-083291',
      'downloadUrl': 'https://firebasestorage.googleapis.com/v0/b/campus-event-48443.firebasestorage.app/o/reports%2FUSR-FPTU-2026%2Fcert.pdf?alt=media',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    count++;

    // 7. Seed Announcements Collection (Final Assignment Inbox)
    final announcements = [
      {
        'id': 'ANN-2026-01',
        'title': 'Chào mừng Lễ hội Công nghệ FPTU Tech Expo 2026! 🚀',
        'content': 'Sự kiện công nghệ thường niên quy mô 500 sinh viên tại Đại học FPT TP.HCM đã chính thức mở cổng đăng ký. Hãy ghé thăm các gian hàng triển lãm và khu vực trải nghiệm AI.',
        'category': 'general',
        'authorRole': 'organizer',
        'eventId': 'EVT-2026-01',
        'isPinned': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'ANN-2026-02',
        'title': 'Hướng dẫn quét mã vé QR tại bàn Check-in Cổng 1',
        'content': 'Sinh viên vui lòng mở sẵn màn hình "Vé của tôi" hoặc vé điện tử tại Cổng 1 trước 15 phút giờ khai mạc để cán bộ bàn check-in quét mã QR nhanh chóng.',
        'category': 'reminder',
        'authorRole': 'staff',
        'eventId': 'EVT-2026-01',
        'isPinned': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'ANN-2026-03',
        'title': 'Đơn đăng ký Workshop UI/UX đã được Ban Tổ Chức duyệt! 🎉',
        'content': 'Chúc mừng bạn! Hồ sơ tham dự workshop Thiết kế UI/UX Chuẩn Công Thái Học đã được phê duyệt. Vé tham gia đã được cấp tự động trong tài khoản của bạn.',
        'category': 'ticket_approved',
        'authorRole': 'organizer',
        'eventId': 'EVT-2026-02',
        'isPinned': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final ann in announcements) {
      final docRef = firestore.collection('announcements').doc(ann['id'] as String);
      batch.set(docRef, ann, SetOptions(merge: true));
      count++;
    }

    // 8. Seed Registrations Collection (Final Assignment Cross-Role Flow)
    final regRef = firestore.collection('registrations').doc('REG-2026-01');
    batch.set(regRef, {
      'id': 'REG-2026-01',
      'eventId': 'EVT-2026-02',
      'eventTitle': 'Workshop: Thiết kế UI/UX Chuẩn Công Thái Học Di Động',
      'userId': 'USR-FPTU-2026',
      'uid': 'USR-FPTU-2026',
      'studentName': 'Nguyễn Văn An',
      'studentEmail': 'an.nv@fptu.edu.vn',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    count++;

    await batch.commit();
    debugPrint('[FirestoreSeeder] Successfully seeded $count documents into Cloud Firestore!');
    return count;
  }
}

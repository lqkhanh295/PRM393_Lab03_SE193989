import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_event/widgets/app_button.dart';
import 'package:campus_event/widgets/points_badge.dart';
import 'package:campus_event/widgets/rating_bar.dart';
import 'package:campus_event/widgets/ticket_card.dart';
import 'package:campus_event/widgets/event_card.dart';
import 'package:campus_event/models/ticket_model.dart';
import 'package:campus_event/models/event_model.dart';
import 'package:campus_event/models/club_model.dart';
import 'package:campus_event/widgets/club_card.dart';
import 'package:campus_event/viewmodels/explore_viewmodel.dart';
import 'package:campus_event/services/firestore_service.dart';
import 'package:campus_event/services/analytics_service.dart';
import 'package:campus_event/services/auth_service.dart';
import 'package:campus_event/services/storage_service.dart';
import 'package:campus_event/services/pdf_export_service.dart';
import 'package:campus_event/models/certificate_model.dart';
import 'package:campus_event/models/user_model.dart';
import 'package:campus_event/models/screen_state.dart';
import 'package:campus_event/viewmodels/my_tickets_vm.dart';
import 'package:campus_event/services/crashlytics_service.dart';
import 'package:campus_event/viewmodels/auth_viewmodel.dart';
import 'package:campus_event/screens/tickets/digital_ticket_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:campus_event/services/gemini_ai_service.dart';
import 'package:campus_event/services/remote_config_service.dart';
import 'dart:convert';

void main() {
  testWidgets('AppPrimaryButton renders label and triggers onPressed', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(
            label: 'Test Button',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
    await tester.tap(find.text('Test Button'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('AppPrimaryButton and AppOutlinedButton do not overflow with long text in narrow container', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 260,
              child: Column(
                children: [
                  AppPrimaryButton(
                    icon: Icons.upload_file_rounded,
                    label: 'Xuất chứng nhận PDF & Upload Cloud Storage',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                  AppOutlinedButton(
                    icon: Icons.notification_add_rounded,
                    label: 'Mô phỏng nhận Push Notification (FCM)',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                  AppOutlinedButton(
                    icon: Icons.tune_rounded,
                    label: 'Chuyển đổi Remote Config (5 <-> 2 sự kiện)',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Xuất chứng nhận PDF & Upload Cloud Storage'), findsOneWidget);
    expect(find.text('Mô phỏng nhận Push Notification (FCM)'), findsOneWidget);
    expect(find.text('Chuyển đổi Remote Config (5 <-> 2 sự kiện)'), findsOneWidget);
  });

  testWidgets('TicketCard does not overflow with long student name and event location in narrow container', (WidgetTester tester) async {
    final ticket = TicketModel(
      id: 'CE2026-083291-VERY-LONG-TICKET-ID',
      eventId: 'EVT-01',
      eventTitle: 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai Công nghệ',
      eventDate: '28/10/2026',
      eventTime: '13:30 - 17:30',
      eventLocation: 'Hội trường Trịnh Công Sơn, Tòa nhà Innovation, Khu Công nghệ cao TP.HCM',
      userId: 'USER-01',
      studentName: 'Nguyễn Đặng Hoàng Phúc Minh Trí',
      studentEmail: 'tri.ndhp@fptu.edu.vn',
      qrToken: 'QR-TEST',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: TicketCard(ticket: ticket),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('EventGlassCard does not overflow with long club name in narrow container', (WidgetTester tester) async {
    final event = EventModel(
      id: 'EVT-01',
      title: 'Workshop: Lập trình Ứng dụng Di động với Flutter & Firebase Toàn diện',
      description: 'Mô tả chi tiết sự kiện',
      category: 'Công nghệ',
      date: '28/11/2026',
      time: '13:30 - 17:30',
      location: 'Phòng Lab 204 Tòa nhà Alpha',
      bannerUrl: 'https://picsum.photos/600/300',
      clubId: 'CLUB-01',
      clubName: 'Câu lạc bộ Lập trình Phần mềm F-Code FPT University HCMC',
      capacity: 100,
      registeredCount: 85,
      speakers: [],
      sessions: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              child: SingleChildScrollView(
                child: EventGlassCard(event: event, onTap: () {}),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('ActivityPointsBadge renders correct points value', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ActivityPointsBadge(points: 250),
        ),
      ),
    );

    expect(find.text('+250 Điểm Rèn Luyện'), findsOneWidget);
  });

  testWidgets('StarRatingBar renders stars and handles taps', (WidgetTester tester) async {
    int selectedRating = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StarRatingBar(
            rating: 4,
            onRatingChanged: (val) => selectedRating = val,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(1));

    // Tap on the 5th star
    await tester.tap(find.byIcon(Icons.star_outline_rounded));
    await tester.pump();
    expect(selectedRating, equals(5));
  });

  test('AuthService.signInWithEmailPassword validates FPT email domains', () async {
    final authService = AuthService();

    // Valid FPT email
    final user = await authService.signInWithEmailPassword(
      email: 'an.nv@fpt.edu.vn',
      password: 'secretPassword123',
    );
    expect(user, isNotNull);
    expect(user!.email, equals('an.nv@fpt.edu.vn'));

    // Invalid non-FPT email
    expect(
      () => authService.signInWithEmailPassword(
        email: 'attacker@gmail.com',
        password: 'password123',
      ),
      throwsException,
    );

    // Short password
    expect(
      () => authService.signInWithEmailPassword(
        email: 'an.nv@fe.edu.vn',
        password: '123',
      ),
      throwsException,
    );
  });

  testWidgets('ClubCard does not overflow with long club name in narrow container', (WidgetTester tester) async {
    const club = ClubModel(
      id: 'fcode',
      name: 'Câu lạc bộ Học thuật Lập trình và Thuật toán F-Code Đại học FPT TP.HCM',
      acronym: 'F-Code',
      category: 'Technology',
      description: 'Cộng đồng sinh viên đam mê lập trình, thuật toán và thi đấu ICPC toàn quốc.',
      followerCount: 2450,
      logoUrl: 'https://daihoc.fpt.edu.vn/logo.png',
      officialUrl: 'https://daihoc.fpt.edu.vn/hcm/f-code/',
      fanpageUrl: 'https://www.facebook.com/fcodefpt/',
      email: 'fcode.fptuhcm@gmail.com',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 260,
              child: ClubCard(club: club),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Technology'), findsOneWidget);
    expect(find.text('F-Code'), findsWidgets);
  });

  test('ClubModel roundtrip preserves all attributes and URLs', () {
    const club = ClubModel(
      id: 'ai4sd',
      name: 'Exploring AI Applications in Software Development Club',
      acronym: 'AI4SD',
      category: 'Technology',
      description: 'Nghiên cứu ứng dụng LLM trong phát triển phần mềm.',
      followerCount: 980,
      logoUrl: 'https://daihoc.fpt.edu.vn/logo.png',
      officialUrl: 'https://daihoc.fpt.edu.vn/hcm/ai4sd/',
      fanpageUrl: 'https://www.facebook.com/ai4sd/',
      email: 'ai4sd.fptu@gmail.com',
    );

    final map = club.toMap();
    final restored = ClubModel.fromMap(map, club.id);

    expect(restored.id, equals('ai4sd'));
    expect(restored.name, equals(club.name));
    expect(restored.acronym, equals('AI4SD'));
    expect(restored.officialUrl, equals('https://daihoc.fpt.edu.vn/hcm/ai4sd/'));
    expect(restored.email, equals('ai4sd.fptu@gmail.com'));
    expect(restored.followerCount, equals(980));

    // String followerCount fallback
    final mapWithStringCount = {
      'name': 'GDGoC FPTU',
      'category': 'Technology',
      'followerCount': '3100',
    };
    final clubParsed = ClubModel.fromMap(mapWithStringCount, 'gdoc');
    expect(clubParsed.followerCount, equals(3100));

    // Empty logoUrl remains empty for monogram fallback
    final mapWithEmptyLogo = {
      'name': 'CLB Cóc Sài Gòn',
      'category': 'Media',
      'logoUrl': '',
    };
    final clubWithEmptyLogo = ClubModel.fromMap(mapWithEmptyLogo, 'csg');
    expect(clubWithEmptyLogo.logoUrl, equals(''));
  });

  testWidgets('ClubCard with empty logoUrl renders Monogram acronym', (WidgetTester tester) async {
    const club = ClubModel(
      id: 'csg',
      name: 'Câu lạc bộ Truyền thông Cóc Sài Gòn',
      acronym: 'CSG',
      category: 'Media',
      description: 'Kênh thông tin truyền thông sinh viên.',
      followerCount: 5200,
      logoUrl: '',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ClubCard(club: club),
        ),
      ),
    );

    expect(find.text('CSG'), findsWidgets);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('ClubCard with valid logoUrl renders Image widget', (WidgetTester tester) async {
    const club = ClubModel(
      id: 'fcode',
      name: 'CLB F-Code',
      acronym: 'F-Code',
      category: 'Technology',
      description: 'CLB Lập trình',
      followerCount: 2450,
      logoUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=120',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ClubCard(club: club),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  test('ExploreViewModel filteredClubs supports Vietnamese accent-free search', () async {
    final firestoreService = FirestoreService();
    final analyticsService = AnalyticsService();
    final vm = ExploreViewModel(
      firestoreService: firestoreService,
      analyticsService: analyticsService,
    );

    await vm.loadExploreData();
    expect(vm.clubs.length, greaterThanOrEqualTo(45));

    // Search with accent
    await vm.searchEvents(query: 'Bóng đá');
    final accentResults = vm.filteredClubs;
    expect(accentResults.any((c) => c.id == 'ffc'), isTrue);

    // Search WITHOUT accent: "bong da"
    await vm.searchEvents(query: 'bong da');
    final noAccentResults = vm.filteredClubs;
    expect(noAccentResults.any((c) => c.id == 'ffc'), isTrue);

    // Search "vovinam"
    await vm.searchEvents(query: 'vovinam');
    expect(vm.filteredClubs.any((c) => c.id == 'fvc'), isTrue);

    // Search "coc sai gon" (matches both official 'csg' and legacy 'media_club')
    await vm.searchEvents(query: 'coc sai gon');
    expect(vm.filteredClubs.any((c) => c.id == 'csg' || c.id == 'media_club'), isTrue);
  });

  testWidgets('DigitalTicketScreen locks feedback button when ticket is not checked in (BR-005)', (WidgetTester tester) async {
    const unCheckedInTicket = TicketModel(
      id: 'CE2026-111111',
      eventId: 'fcode_ai_challenge_2026',
      eventTitle: 'F-Code AI Challenge 2026',
      eventDate: '28/10/2026',
      eventTime: '13:30 - 17:30',
      eventLocation: 'Hội trường Trịnh Công Sơn',
      userId: 'test_user',
      studentName: 'Nguyen Van A',
      studentEmail: 'a.nv@fpt.edu.vn',
      qrToken: 'TOKEN-CE2026-111111',
      status: TicketStatus.active,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: DigitalTicketScreen(ticket: unCheckedInTicket),
      ),
    );

    // Should indicate the locked button
    expect(find.text('Đánh giá & Nhận Điểm Rèn Luyện (Đang khóa)'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
  });

  testWidgets('DigitalTicketScreen unlocks feedback button when ticket is checked in (BR-005)', (WidgetTester tester) async {
    final checkedInTicket = TicketModel(
      id: 'CE2026-222222',
      eventId: 'fcode_ai_challenge_2026',
      eventTitle: 'F-Code AI Challenge 2026',
      eventDate: '28/10/2026',
      eventTime: '13:30 - 17:30',
      eventLocation: 'Hội trường Trịnh Công Sơn',
      userId: 'test_user',
      studentName: 'Nguyen Van A',
      studentEmail: 'a.nv@fpt.edu.vn',
      qrToken: 'TOKEN-CE2026-222222',
      status: TicketStatus.checkedIn,
      checkedInAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DigitalTicketScreen(ticket: checkedInTicket),
      ),
    );

    // Should show the unlocked evaluation button and success banner
    expect(find.text('Đánh giá sự kiện & Nhận Điểm Rèn Luyện'), findsOneWidget);
    expect(find.byIcon(Icons.star_rate_rounded), findsOneWidget);
    expect(find.textContaining('Đã điểm danh tại cổng'), findsOneWidget);
  });

  test('generateCertificatePdf handles Vietnamese diacritics without crashing', () async {
    final storageService = StorageService(null);
    final pdfService = PdfExportService(storageService);
    const cert = CertificateModel(
      id: 'CERT-123456',
      eventId: 'evt-1',
      eventTitle: 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
      userId: 'usr-1',
      studentName: 'Nguyễn Quốc Khánh',
      issueDate: '28/10/2026',
      verificationHash: 'HASH-TEST-123',
      downloadUrl: '',
    );

    final bytes = await pdfService.generateCertificatePdf(cert);
    expect(bytes, isNotEmpty);
  });

  test('MyTicketsViewModel reacts to check-in and transitions ticket from upcoming to attended tab', () async {
    final firestoreService = FirestoreService(null);
    final myTicketsVM = MyTicketsViewModel(firestoreService: firestoreService);

    // Register a ticket for test student
    const event = EventModel(
      id: 'EVT-TEST-1',
      title: 'FPTU Tech Expo 2026',
      description: 'Test Event',
      category: 'Technology',
      clubId: 'fcode',
      clubName: 'CLB F-Code',
      date: '28/11/2026',
      time: '13:30 - 17:30',
      location: 'Hội trường Trịnh Công Sơn',
      capacity: 100,
      registeredCount: 10,
      bannerUrl: '',
    );
    const user = UserModel(
      id: 'student_tester_01',
      name: 'Nguyen Van Test',
      email: 'test@fpt.edu.vn',
      avatarUrl: '',
      major: 'Software Engineering',
      role: 'student',
      activityPoints: 0,
    );

    final ticket = await firestoreService.registerForEvent(event: event, user: user);
    await myTicketsVM.loadUserTickets(user.id);

    // Tab 0: Upcoming
    myTicketsVM.selectTab(0);
    expect(myTicketsVM.state, isA<StateData<List<TicketModel>>>());
    final upcoming = (myTicketsVM.state as StateData<List<TicketModel>>).data;
    expect(upcoming.any((t) => t.id == ticket.id), isTrue);

    // Tab 1: Attended (should be empty initially)
    myTicketsVM.selectTab(1);
    expect(myTicketsVM.state, isA<StateEmpty<List<TicketModel>>>());

    // Perform check-in at gate desk
    final result = await firestoreService.validateAndCheckInTicket(
      qrToken: ticket.qrToken,
      eventId: event.id,
    );
    expect(result.isValid, isTrue);

    // Allow event loop / ValueNotifier to notify MyTicketsViewModel
    await Future.delayed(const Duration(milliseconds: 10));

    // In Tab 1: Attended, ticket must now appear with checkedIn status
    myTicketsVM.selectTab(1);
    expect(myTicketsVM.state, isA<StateData<List<TicketModel>>>());
    final attended = (myTicketsVM.state as StateData<List<TicketModel>>).data;
    expect(attended.any((t) => t.id == ticket.id && t.isCheckedIn), isTrue);

    // In Tab 0: Upcoming, ticket must no longer appear
    myTicketsVM.selectTab(0);
    expect(myTicketsVM.state, isA<StateEmpty<List<TicketModel>>>());

    myTicketsVM.dispose();
  });

  test('AuthViewModel and AuthService update activity points (+5) and sync with user state', () async {
    final authService = AuthService();
    final analyticsService = AnalyticsService();
    final crashlyticsService = CrashlyticsService();
    final authVM = AuthViewModel(
      authService: authService,
      analyticsService: analyticsService,
      crashlyticsService: crashlyticsService,
    );

    await authVM.signInWithEmailPassword(
      email: 'student.test@fpt.edu.vn',
      password: 'password123',
    );
    expect(authVM.currentUser?.activityPoints, equals(0));

    // Submit feedback grants +5 points
    await authVM.addActivityPoints(5);
    expect(authVM.currentUser?.activityPoints, equals(5));

    // Another feedback grants another +5 points
    await authVM.addActivityPoints(5);
    expect(authVM.currentUser?.activityPoints, equals(10));

    authVM.dispose();
  });
  test('EventModel.isPast and isRegistrationOpen accurately track expiration based on current runtime date', () {
    const pastEvent = EventModel(
      id: 'EVT-PAST',
      title: 'Past Event',
      description: 'Already finished',
      category: 'Technology',
      clubId: 'fcode',
      clubName: 'CLB F-Code',
      date: '28/10/2026',
      time: '13:30 - 17:30',
      location: 'Halls',
      capacity: 100,
      registeredCount: 10,
      bannerUrl: '',
    );
    expect(pastEvent.isPast, isTrue);
    expect(pastEvent.isRegistrationOpen, isFalse);

    const futureEvent = EventModel(
      id: 'EVT-FUTURE',
      title: 'Future Event',
      description: 'Upcoming',
      category: 'Technology',
      clubId: 'fcode',
      clubName: 'CLB F-Code',
      date: '28/11/2026',
      time: '13:30 - 17:30',
      location: 'Halls',
      capacity: 100,
      registeredCount: 10,
      bannerUrl: '',
    );
    expect(futureEvent.isPast, isFalse);
    expect(futureEvent.isRegistrationOpen, isTrue);
  });

  test('FirestoreService blocks registration for past events (BR-004)', () async {
    final firestoreService = FirestoreService(null);
    const pastEvent = EventModel(
      id: 'EVT-PAST-2',
      title: 'Past Event 2',
      description: 'Already finished',
      category: 'Technology',
      clubId: 'fcode',
      clubName: 'CLB F-Code',
      date: '28/10/2026',
      time: '13:30 - 17:30',
      location: 'Halls',
      capacity: 100,
      registeredCount: 10,
      bannerUrl: '',
    );
    const user = UserModel(
      id: 'student_tester_02',
      name: 'Nguyen Van Test',
      email: 'test2@fpt.edu.vn',
      avatarUrl: '',
      major: 'Software Engineering',
      role: 'student',
      activityPoints: 0,
    );

    expect(
      () => firestoreService.registerForEvent(event: pastEvent, user: user),
      throwsA(isA<Exception>().having(
        (e) => e.toString(),
        'message',
        contains('Sự kiện đã kết thúc, không thể đăng ký tham gia'),
      )),
    );
  });

  test('GeminiAiService initializes with 10 official API keys and supports round-robin rotation', () async {
    final aiService = GeminiAiService(
      remoteConfigService: RemoteConfigService(null),
      analyticsService: AnalyticsService(null),
    );

    expect(aiService.totalKeys, equals(10));
    expect(aiService.currentKeyIndex, equals(0));
    expect(aiService.currentApiKeyPreview, isNotEmpty);

    // Manual rotation
    aiService.rotateToNextKey();
    expect(aiService.currentKeyIndex, equals(1));
  });

  test('GeminiAiService automatically rotates key on HTTP 429 quota error and uses next available key', () async {
    int callCount = 0;
    final mockClient = MockClient((request) async {
      callCount++;
      if (request.url.queryParameters['key'] == GeminiAiService.officialGeminiApiKeys[0]) {
        // First key hits quota 429
        return http.Response('{"error":{"code":429,"message":"Quota exceeded"}}', 429);
      }
      // Second key succeeds
      return http.Response(
        jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'text': jsonEncode({
                      'summary': 'Tóm tắt tự động qua Gemini AI',
                      'keyTakeaways': ['Điểm 1', 'Điểm 2'],
                      'recommendedAudience': ['Sinh viên FPTU'],
                      'suggestedQuestions': ['Câu hỏi 1?']
                    })
                  }
                ]
              }
            }
          ]
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final aiService = GeminiAiService(
      remoteConfigService: RemoteConfigService(null),
      analyticsService: AnalyticsService(null),
      httpClient: mockClient,
    );

    const testEvent = EventModel(
      id: 'EVT-AI-ROTATION',
      title: 'Hội thảo AI 2026',
      description: 'Khám phá GenAI',
      category: 'Technology',
      clubId: 'fcode',
      clubName: 'CLB F-Code',
      date: '20/11/2026',
      time: '14:00 - 17:00',
      location: 'Hội trường Trịnh Công Sơn',
      capacity: 100,
      registeredCount: 10,
      bannerUrl: '',
      isFeatured: false,
    );

    final insight = await aiService.generateEventInsights(testEvent);

    expect(callCount, equals(2)); // Key 1 tried (429), rotated to Key 2 (200)
    expect(aiService.currentKeyIndex, equals(1)); // Key 2 is now active
    expect(insight.isFallback, isFalse);
    expect(insight.summary, equals('Tóm tắt tự động qua Gemini AI'));
    expect(insight.keyTakeaways, contains('Điểm 1'));
  });

}

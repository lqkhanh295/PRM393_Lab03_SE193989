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
      date: '28/10/2026',
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
}

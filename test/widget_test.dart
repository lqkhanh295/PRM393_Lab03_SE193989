import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_event/widgets/app_button.dart';
import 'package:campus_event/widgets/points_badge.dart';
import 'package:campus_event/widgets/rating_bar.dart';

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
}

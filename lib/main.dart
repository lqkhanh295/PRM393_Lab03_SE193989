import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/fcm_service.dart';
import 'services/analytics_service.dart';
import 'services/crashlytics_service.dart';
import 'services/remote_config_service.dart';
import 'services/pdf_export_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/explore_viewmodel.dart';
import 'viewmodels/event_detail_vm.dart';
import 'viewmodels/registration_vm.dart';
import 'viewmodels/my_tickets_vm.dart';
import 'viewmodels/live_event_vm.dart';
import 'viewmodels/feedback_vm.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/mobile_desk_vm.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Cloud Services
  try {
    await Firebase.initializeApp();
    debugPrint('[Firebase] Successfully initialized with native options.');
  } catch (e) {
    debugPrint('[Firebase] Native init fallback notice: $e');
  }

  // Instantiate Cloud & Foundation Services (Native instances on Mobile, graceful fallback on Web)
  final authService = AuthService(!kIsWeb ? FirebaseAuth.instance : null, !kIsWeb ? FirebaseFirestore.instance : null);
  final firestoreService = FirestoreService(!kIsWeb ? FirebaseFirestore.instance : null);
  final storageService = StorageService(!kIsWeb ? FirebaseStorage.instance : null);
  final fcmService = FCMService(!kIsWeb ? FirebaseMessaging.instance : null);
  final analyticsService = AnalyticsService(!kIsWeb ? FirebaseAnalytics.instance : null);
  final crashlyticsService = CrashlyticsService(!kIsWeb ? FirebaseCrashlytics.instance : null);
  final remoteConfigService = RemoteConfigService(!kIsWeb ? FirebaseRemoteConfig.instance : null);
  final pdfExportService = PdfExportService(storageService);

  // Initialize background listeners and ensure real Cloud Firestore data
  await fcmService.initialize();
  await remoteConfigService.initialize();
  await firestoreService.ensureDatabaseInitialized();

  runApp(
    MultiProvider(
      providers: [
        // Services Injection
        Provider<AuthService>.value(value: authService),
        Provider<FirestoreService>.value(value: firestoreService),
        Provider<StorageService>.value(value: storageService),
        Provider<FCMService>.value(value: fcmService),
        Provider<AnalyticsService>.value(value: analyticsService),
        Provider<CrashlyticsService>.value(value: crashlyticsService),
        Provider<RemoteConfigService>.value(value: remoteConfigService),
        Provider<PdfExportService>.value(value: pdfExportService),

        // ViewModels Injection
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            authService: authService,
            analyticsService: analyticsService,
            crashlyticsService: crashlyticsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(
            firestoreService: firestoreService,
            remoteConfigService: remoteConfigService,
            analyticsService: analyticsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ExploreViewModel(
            firestoreService: firestoreService,
            analyticsService: analyticsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EventDetailViewModel(
            firestoreService: firestoreService,
            analyticsService: analyticsService,
            crashlyticsService: crashlyticsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RegistrationViewModel(
            firestoreService: firestoreService,
            analyticsService: analyticsService,
            crashlyticsService: crashlyticsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MyTicketsViewModel(
            firestoreService: firestoreService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LiveEventViewModel(
            firestoreService: firestoreService,
            analyticsService: analyticsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FeedbackViewModel(
            analyticsService: analyticsService,
            pdfExportService: pdfExportService,
            firestoreService: firestoreService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(
            firestoreService: firestoreService,
            storageService: storageService,
            remoteConfigService: remoteConfigService,
            crashlyticsService: crashlyticsService,
            fcmService: fcmService,
            analyticsService: analyticsService,
            pdfExportService: pdfExportService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MobileDeskViewModel(
            firestoreService: firestoreService,
            crashlyticsService: crashlyticsService,
            analyticsService: analyticsService,
          ),
        ),
      ],
      child: const CampusEventApp(),
    ),
  );
}

class CampusEventApp extends StatelessWidget {
  const CampusEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return MaterialApp(
      title: 'Campus Event',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authVM.isAuthenticated
          ? const MainNavigationScreen()
          : const LoginScreen(),
    );
  }
}

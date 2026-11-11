import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../services/crashlytics_service.dart';

/// MVVM AuthViewModel
/// Coordinates user authentication lifecycle and emits explicit screen states.
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final AnalyticsService _analyticsService;
  final CrashlyticsService _crashlyticsService;

  ScreenState<UserModel?> _state = const StateInitial();
  ScreenState<UserModel?> get state => _state;

  UserModel? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;

  AuthViewModel({
    required AuthService authService,
    required AnalyticsService analyticsService,
    required CrashlyticsService crashlyticsService,
  })  : _authService = authService,
        _analyticsService = analyticsService,
        _crashlyticsService = crashlyticsService {
    // Synchronize initial state
    if (_authService.currentUser != null) {
      _state = StateData(_authService.currentUser);
    }
    _authService.authStateChanges.listen((user) {
      _state = user != null ? StateData(user) : const StateInitial();
      notifyListeners();
    });
  }

  Future<bool> signInWithGoogle() async {
    _state = const StateLoading('Đang kết nối tài khoản Google FPT...');
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        await _analyticsService.setUserId(user.id);
        await _analyticsService.logLogin(method: 'google', role: user.role);
        await _crashlyticsService.setUserId(user.id);
        _state = StateData(user);
        notifyListeners();
        return true;
      }
      _state = const StateInitial();
      notifyListeners();
      return false;
    } catch (e, stack) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg.contains('hủy') || msg.contains('cancel')) {
        _state = const StateInitial();
        notifyListeners();
        return false;
      }
      debugPrint('[AuthViewModel] Google sign-in error: $e');
      await _crashlyticsService.recordHandledError(e, stack, reason: 'Google sign-in error');
      _state = StateError(msg);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _state = const StateLoading('Đang xác thực tài khoản email FPT...');
    notifyListeners();

    try {
      final user = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        await _analyticsService.setUserId(user.id);
        await _analyticsService.logLogin(method: 'email_fpt', role: user.role);
        await _crashlyticsService.setUserId(user.id);
        _state = StateData(user);
        notifyListeners();
        return true;
      }
      _state = const StateInitial();
      notifyListeners();
      return false;
    } catch (e, stack) {
      debugPrint('[AuthViewModel] Email sign-in error: $e');
      await _crashlyticsService.recordHandledError(e, stack, reason: 'Email FPT sign-in error');
      _state = StateError(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
      return false;
    }
  }

  void switchDemoRole(String role) {
    _authService.switchDemoRole(role);
    notifyListeners();
  }

  /// Add activity points (+5) upon completing event feedback
  Future<void> addActivityPoints(int points) async {
    await _authService.addActivityPoints(points);
    if (_authService.currentUser != null) {
      _state = StateData(_authService.currentUser);
      notifyListeners();
    }
  }

  /// Reload latest user profile data from Cloud Firestore
  Future<void> refreshProfile() async {
    final updated = await _authService.reloadCurrentUser();
    if (updated != null) {
      _state = StateData(updated);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _analyticsService.logLogout(sessionMinutes: 15);
      await _authService.signOut();
      _state = const StateInitial();
      notifyListeners();
    } catch (e, stack) {
      await _crashlyticsService.recordHandledError(e, stack);
    }
  }
}

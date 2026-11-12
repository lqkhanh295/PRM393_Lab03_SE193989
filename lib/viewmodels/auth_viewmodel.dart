import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../services/crashlytics_service.dart';

/// ViewModel quản lý toàn bộ vòng đời xác thực người dùng trong mô hình MVVM.
///
/// Điều phối đăng nhập Google, Email FPT, đồng bộ hồ sơ, phát ra các trạng thái
/// màn hình rõ ràng ([StateInitial], [StateLoading], [StateData], [StateError])
/// và ghi nhận nhật ký chẩn đoán qua Firebase Analytics & Crashlytics.
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final AnalyticsService _analyticsService;
  final CrashlyticsService _crashlyticsService;

  ScreenState<UserModel?> _state = const StateInitial();

  /// Trạng thái hiện tại của màn hình xác thực (Initial, Loading, Data, Error).
  ScreenState<UserModel?> get state => _state;

  /// Đối tượng người dùng hiện tại đang đăng nhập trong hệ thống.
  UserModel? get currentUser => _authService.currentUser;

  /// Cho biết người dùng hiện tại đã đăng nhập hay chưa.
  bool get isAuthenticated => _authService.isAuthenticated;

  /// Khởi tạo [AuthViewModel] và đăng ký lắng nghe các thay đổi trạng thái xác thực.
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

  /// Thực hiện đăng nhập bằng tài khoản Google với OAuth 2.0.
  ///
  /// Trả về `true` nếu đăng nhập thành công, ngược lại trả về `false`.
  Future<bool> signInWithGoogle() async {
    _state = const StateLoading('Đang kết nối tài khoản Google...');
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

  /// Thực hiện đăng nhập bằng [email] trường FPT và [password].
  ///
  /// Trả về `true` nếu xác thực thành công, ngược lại trả về `false` và cập nhật thông báo lỗi.
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

  /// Chuyển đổi vai trò người dùng [role] linh hoạt trong quá trình thuyết trình demo nghiệm thu.
  void switchDemoRole(String role) {
    _authService.switchDemoRole(role);
    notifyListeners();
  }

  /// Cộng điểm rèn luyện [points] sau khi sinh viên hoàn tất đánh giá sự kiện.
  Future<void> addActivityPoints(int points) async {
    await _authService.addActivityPoints(points);
    if (_authService.currentUser != null) {
      _state = StateData(_authService.currentUser);
      notifyListeners();
    }
  }

  /// Tải lại dữ liệu hồ sơ sinh viên mới nhất từ Cloud Firestore và cập nhật giao diện.
  Future<void> refreshProfile() async {
    final updated = await _authService.reloadCurrentUser();
    if (updated != null) {
      _state = StateData(updated);
      notifyListeners();
    }
  }

  /// Đăng xuất khỏi tài khoản, xóa phiên làm việc và đưa giao diện về trạng thái ban đầu.
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

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// Dịch vụ quản lý xác thực người dùng (Authentication Service).
///
/// Cung cấp cơ chế đăng nhập bằng Google Sign-In, Email/Password trường FPT,
/// và tự động đồng bộ hồ sơ, vai trò, điểm rèn luyện thời gian thực với Cloud Firestore.
class AuthService {
  final FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;

  static const String _webClientId = '74927582053-u55o35mih7dnssub0g5c3cmm3mmtcnil.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _webClientId : null,
    serverClientId: kIsWeb ? null : _webClientId,
    scopes: const ['email', 'profile'],
  );

  UserModel? _currentUser;
  final _authStateController = StreamController<UserModel?>.broadcast();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSubscription;

  UserModel _buildUserFromFirebaseUser(User user, {String? fallbackName, String? fallbackEmail, String? fallbackAvatar}) {
    final email = (user.email != null && user.email!.isNotEmpty) ? user.email! : (fallbackEmail ?? '');
    final prefix = email.split('@').first;
    final formattedName = prefix
        .split('.')
        .map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '')
        .join(' ')
        .trim();
    final resolvedName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : (fallbackName != null && fallbackName.trim().isNotEmpty)
            ? fallbackName.trim()
            : (formattedName.isNotEmpty ? formattedName : 'Sinh viên FPTU');
    final resolvedAvatar = (user.photoURL != null && user.photoURL!.trim().isNotEmpty)
        ? user.photoURL!
        : (fallbackAvatar != null && fallbackAvatar.trim().isNotEmpty)
            ? fallbackAvatar
            : 'https://i.pravatar.cc/150?u=${user.uid}';

    return UserModel(
      id: user.uid,
      name: resolvedName,
      email: email,
      avatarUrl: resolvedAvatar,
      major: 'Sinh viên FPTU',
      activityPoints: 0,
      role: 'student',
    );
  }

  /// Khởi tạo [AuthService] và thiết lập lắng nghe luồng thay đổi trạng thái xác thực.
  AuthService([this._firebaseAuth, this._firestore]) {
    // If Firebase Auth is provided, listen to its auth state changes
    _firebaseAuth?.authStateChanges().listen((User? user) async {
      if (user != null) {
        final basicUser = _buildUserFromFirebaseUser(user);
        _currentUser = await _syncUserWithFirestore(basicUser);
        _listenToUserDocument(_currentUser!.id);
      } else {
        _userDocSubscription?.cancel();
        _currentUser = null;
      }
      _authStateController.add(_currentUser);
    });
  }

  /// Lắng nghe các thay đổi thời gian thực trên tài liệu người dùng [userId] từ Cloud Firestore.
  void _listenToUserDocument(String userId) {
    _userDocSubscription?.cancel();
    if (_firestore != null) {
      _userDocSubscription = _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((snap) {
        if (snap.exists && snap.data() != null && _currentUser != null) {
          final updated = UserModel.fromMap(snap.data()!, userId);
          if (updated.activityPoints != _currentUser!.activityPoints ||
              updated.role != _currentUser!.role ||
              updated.name != _currentUser!.name) {
            _currentUser = updated;
            _authStateController.add(_currentUser);
            debugPrint('[AuthService] Realtime Firestore points update: ${_currentUser?.activityPoints}');
          }
        }
      }, onError: (e) {
        debugPrint('[AuthService] User doc stream error: $e');
      });
    }
  }

  /// Đồng bộ thông tin [basicUser] với bộ sưu tập `users` trên Cloud Firestore.
  Future<UserModel> _syncUserWithFirestore(UserModel basicUser) async {
    if (_firestore != null) {
      try {
        final docRef = _firestore.collection('users').doc(basicUser.id);
        final snap = await docRef.get();
        if (snap.exists && snap.data() != null) {
          return UserModel.fromMap(snap.data()!, basicUser.id);
        } else {
          await docRef.set(basicUser.toMap(), SetOptions(merge: true));
          return basicUser;
        }
      } catch (e) {
        debugPrint('[AuthService] Firestore user sync note: $e');
        return basicUser;
      }
    }

    // Best-effort profile sync via local Web Portal REST bridge when Firestore SDK is null (Web)
    try {
      final getRes = await http
          .get(Uri.parse('http://localhost:3000/api/users/${Uri.encodeComponent(basicUser.id)}'))
          .timeout(const Duration(milliseconds: 1200));
      if (getRes.statusCode == 200 && getRes.body.trim().isNotEmpty) {
        final decoded = jsonDecode(getRes.body);
        if (decoded is Map && (decoded['email']?.toString().isNotEmpty ?? false)) {
          final existing = UserModel.fromMap(Map<String, dynamic>.from(decoded), basicUser.id);
          return existing.copyWith(
            name: basicUser.name.isNotEmpty ? basicUser.name : existing.name,
            email: basicUser.email.isNotEmpty ? basicUser.email : existing.email,
            avatarUrl: basicUser.avatarUrl.isNotEmpty ? basicUser.avatarUrl : existing.avatarUrl,
          );
        }
      }
      await http
          .patch(
            Uri.parse('http://localhost:3000/api/users/${Uri.encodeComponent(basicUser.id)}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(basicUser.toMap()),
          )
          .timeout(const Duration(milliseconds: 1200));
    } catch (_) {}
    return basicUser;
  }

  /// Thông tin đối tượng người dùng hiện tại đang đăng nhập.
  UserModel? get currentUser => _currentUser;

  /// Cho biết người dùng đã đăng nhập vào hệ thống hay chưa.
  bool get isAuthenticated => _currentUser != null;

  /// Luồng phát tín hiệu khi có sự thay đổi về phiên đăng nhập hoặc dữ liệu hồ sơ người dùng.
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  /// Đăng nhập tài khoản bằng cơ chế Google Sign-In với xác thực OAuth 2.0
  /// (sử dụng Firebase Auth Popup trên Web để tránh lỗi GIS origin_mismatch, SDK GoogleSignIn trên Mobile).
  Future<UserModel?> signInWithGoogle() async {
    try {
      debugPrint('[AuthService] Initiating Google Sign-In...');

      if (kIsWeb && _firebaseAuth != null) {
        final googleProvider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile')
          ..setCustomParameters({'prompt': 'select_account'});

        final UserCredential userCred = await _firebaseAuth.signInWithPopup(googleProvider);
        final User? user = userCred.user;
        if (user != null) {
          final basicUser = _buildUserFromFirebaseUser(user);
          _currentUser = await _syncUserWithFirestore(basicUser);
          _listenToUserDocument(_currentUser!.id);
        }
        _authStateController.add(_currentUser);
        debugPrint('[AuthService] Web Google Sign-in successful: ${_currentUser?.email}');
        return _currentUser;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('[AuthService] Google Sign-In cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (_firebaseAuth != null) {
        final UserCredential userCred = await _firebaseAuth.signInWithCredential(credential);
        final User? user = userCred.user;
        if (user != null) {
          final basicUser = _buildUserFromFirebaseUser(
            user,
            fallbackName: googleUser.displayName,
            fallbackEmail: googleUser.email,
            fallbackAvatar: googleUser.photoUrl,
          );
          _currentUser = await _syncUserWithFirestore(basicUser);
          _listenToUserDocument(_currentUser!.id);
        }
      } else {
        final email = googleUser.email;
        final prefix = email.split('@').first;
        final formattedName = prefix.split('.').map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '').join(' ').trim();
        final basicUser = UserModel(
          id: googleUser.id,
          name: (googleUser.displayName != null && googleUser.displayName!.trim().isNotEmpty)
              ? googleUser.displayName!.trim()
              : (formattedName.isNotEmpty ? formattedName : 'Sinh viên FPTU'),
          email: email,
          avatarUrl: googleUser.photoUrl ?? 'https://i.pravatar.cc/150?u=${googleUser.id}',
          major: 'Sinh viên FPTU',
          activityPoints: 0,
          role: 'student',
        );
        _currentUser = await _syncUserWithFirestore(basicUser);
        _listenToUserDocument(_currentUser!.id);
      }

      _authStateController.add(_currentUser);
      debugPrint('[AuthService] Google Sign-in successful: ${_currentUser?.email}');
      return _currentUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] Firebase Auth error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'popup-closed-by-user':
        case 'cancelled-popup-request':
        case 'user-cancelled':
          debugPrint('[AuthService] Google Sign-In popup cancelled by user');
          return null;
        case 'popup-blocked':
          throw Exception('Trình duyệt đã chặn cửa sổ đăng nhập Google. Vui lòng bật Pop-up và thử lại.');
        case 'unauthorized-domain':
          throw Exception('Tên miền hiện tại chưa được cấp phép trên Firebase Auth.');
        case 'account-exists-with-different-credential':
          throw Exception('Tài khoản này đã được liên kết với một phương thức đăng nhập khác.');
        case 'invalid-credential':
          throw Exception('Thông tin xác thực Google không hợp lệ hoặc đã hết hạn.');
        case 'user-disabled':
          throw Exception('Tài khoản đã bị tạm khóa. Vui lòng liên hệ ban quản trị FPTU.');
        case 'network-request-failed':
          throw Exception('Lỗi kết nối mạng. Vui lòng kiểm tra Wifi/4G và thử lại.');
        default:
          throw Exception(e.message ?? 'Đăng nhập Google thất bại. Vui lòng thử lại.');
      }
    } catch (e) {
      debugPrint('[AuthService] Sign-in error: $e');
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('popup_closed') || errStr.contains('popup-closed') || errStr.contains('cancel')) {
        return null;
      }
      rethrow;
    }
  }

  /// Đăng nhập tài khoản bằng [email] trường FPT và [password].
  ///
  /// Kiểm tra chặt chẽ tên miền (@fpt.edu.vn, @fe.edu.vn, @fptu.edu.vn)
  /// và tự động cấp tài khoản nếu người dùng đăng nhập lần đầu tiên.
  Future<UserModel?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // Domain validation check for FPT University
    final isFptDomain = cleanEmail.endsWith('@fpt.edu.vn') ||
        cleanEmail.endsWith('@fe.edu.vn') ||
        cleanEmail.endsWith('@fptu.edu.vn');

    if (!isFptDomain) {
      throw Exception('Vui lòng sử dụng địa chỉ email FPT (@fpt.edu.vn, @fe.edu.vn hoặc @fptu.edu.vn)');
    }

    if (password.trim().length < 6) {
      throw Exception('Mật khẩu phải chứa ít nhất 6 ký tự.');
    }

    try {
      debugPrint('[AuthService] Initiating Email/Password Sign-In: $cleanEmail');
      if (_firebaseAuth != null) {
        UserCredential userCred;
        try {
          userCred = await _firebaseAuth.signInWithEmailAndPassword(
            email: cleanEmail,
            password: password,
          );
        } on FirebaseAuthException catch (e) {
          // If user doesn't exist yet, auto-register seamless onboarding
          if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
            try {
              userCred = await _firebaseAuth.createUserWithEmailAndPassword(
                email: cleanEmail,
                password: password,
              );
            } on FirebaseAuthException catch (createErr) {
              if (createErr.code == 'email-already-in-use') {
                throw Exception('Mật khẩu không chính xác.');
              }
              rethrow;
            }
          } else {
            rethrow;
          }
        }

        final User? user = userCred.user;
        if (user != null) {
          final basicUser = _buildUserFromFirebaseUser(user, fallbackEmail: cleanEmail);
          _currentUser = await _syncUserWithFirestore(basicUser);
          _listenToUserDocument(_currentUser!.id);
        }
      } else {
        // Authenticate via Firebase REST Auth API (Identity Toolkit)
        const apiKey = 'AIzaSyCg0vHOVyIPb4LZoVln0d4clDx8dW54CJI';
        final verifyUrl = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey');
        final verifyRes = await http.post(
          verifyUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': cleanEmail,
            'password': password,
            'returnSecureToken': true,
          }),
        );

        String? firebaseUid;
        if (verifyRes.statusCode == 200 && verifyRes.body.trim().isNotEmpty) {
          try {
            final resData = jsonDecode(verifyRes.body);
            firebaseUid = resData['localId'] as String?;
          } catch (_) {}
        } else if (verifyRes.body.trim().isNotEmpty) {
          try {
            final errBody = jsonDecode(verifyRes.body);
            final errMsg = errBody['error']?['message']?.toString() ?? '';
            if (errMsg == 'EMAIL_NOT_FOUND') {
              final signUpUrl = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey');
              final signUpRes = await http.post(
                signUpUrl,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'email': cleanEmail,
                  'password': password,
                  'returnSecureToken': true,
                }),
              );
              if (signUpRes.statusCode == 200 && signUpRes.body.trim().isNotEmpty) {
                final signUpData = jsonDecode(signUpRes.body);
                firebaseUid = signUpData['localId'] as String?;
              } else {
                throw Exception('Không thể tạo tài khoản sinh viên trên hệ thống.');
              }
            } else if (errMsg == 'INVALID_PASSWORD' || errMsg == 'INVALID_LOGIN_CREDENTIALS') {
              throw Exception('Mật khẩu không chính xác.');
            } else if (errMsg.isNotEmpty) {
              throw Exception('Đăng nhập thất bại: $errMsg');
            }
          } catch (e) {
            if (e is Exception && !e.toString().contains('FormatException')) {
              rethrow;
            }
          }
        }

        final prefix = cleanEmail.split('@').first;
        final formattedName = prefix.split('.').map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '').join(' ');

        final basicUser = UserModel(
          id: firebaseUid != null && firebaseUid.isNotEmpty ? firebaseUid : 'USR-${cleanEmail.hashCode.abs()}',
          name: formattedName.isNotEmpty ? formattedName : 'Sinh viên FPTU',
          email: cleanEmail,
          avatarUrl: 'https://i.pravatar.cc/150?u=${cleanEmail.hashCode}',
          major: 'Sinh viên FPTU',
          activityPoints: 0,
          role: 'student',
        );
        _currentUser = await _syncUserWithFirestore(basicUser);
        _listenToUserDocument(_currentUser!.id);
      }

      _authStateController.add(_currentUser);
      debugPrint('[AuthService] Email Sign-in successful: ${_currentUser?.email}');
      return _currentUser;
    } catch (e) {
      debugPrint('[AuthService] Email Sign-in error: $e');
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            throw Exception('Mật khẩu không chính xác.');
          case 'user-disabled':
            throw Exception('Tài khoản sinh viên này đã bị tạm khóa.');
          case 'too-many-requests':
            throw Exception('Quá nhiều lần thử thất bại. Vui lòng thử lại sau.');
          default:
            throw Exception(e.message ?? 'Đăng nhập không thành công.');
        }
      }
      rethrow;
    }
  }

  /// Cộng điểm rèn luyện [points] trực tiếp vào hồ sơ sinh viên và đồng bộ nguyên tử lên Cloud Firestore.
  Future<void> addActivityPoints(int points) async {
    if (_currentUser == null) return;
    final updatedPoints = _currentUser!.activityPoints + points;
    _currentUser = _currentUser!.copyWith(activityPoints: updatedPoints);
    _authStateController.add(_currentUser);

    if (_firestore != null) {
      try {
        await _firestore.collection('users').doc(_currentUser!.id).update({
          'activityPoints': FieldValue.increment(points),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('[AuthService] Incremented points by $points for ${_currentUser!.id}');
      } catch (e) {
        debugPrint('[AuthService] addActivityPoints update note: $e');
      }
    } else {
      try {
        await http
            .patch(
              Uri.parse('http://localhost:3000/api/users/${Uri.encodeComponent(_currentUser!.id)}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'activityPoints': updatedPoints}),
            )
            .timeout(const Duration(milliseconds: 1200));
      } catch (_) {}
    }
  }

  /// Tải lại bản ghi hồ sơ sinh viên mới nhất từ Cloud Firestore.
  Future<UserModel?> reloadCurrentUser() async {
    if (_currentUser == null) return null;
    if (_firestore != null) {
      try {
        final snap = await _firestore.collection('users').doc(_currentUser!.id).get();
        if (snap.exists && snap.data() != null) {
          _currentUser = UserModel.fromMap(snap.data()!, _currentUser!.id);
          _authStateController.add(_currentUser);
          return _currentUser;
        }
      } catch (e) {
        debugPrint('[AuthService] reloadCurrentUser error: $e');
      }
    } else {
      try {
        final res = await http
            .get(Uri.parse('http://localhost:3000/api/users/${Uri.encodeComponent(_currentUser!.id)}'))
            .timeout(const Duration(milliseconds: 1200));
        if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
          final decoded = jsonDecode(res.body);
          if (decoded is Map && (decoded['email']?.toString().isNotEmpty ?? false)) {
            _currentUser = UserModel.fromMap(Map<String, dynamic>.from(decoded), _currentUser!.id);
            _authStateController.add(_currentUser);
            return _currentUser;
          }
        }
      } catch (_) {}
    }
    return _currentUser;
  }

  /// Chuyển đổi vai trò người dùng [newRole] linh hoạt phục vụ mục đích kiểm thử và demo đồ án.
  void switchDemoRole(String newRole) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: newRole);
      _authStateController.add(_currentUser);
      debugPrint('[AuthService] Role switched to: $newRole');
    }
  }

  /// Đăng xuất khỏi tài khoản, hủy các kết nối thời gian thực và xóa sạch phiên làm việc trên máy.
  Future<void> signOut() async {
    try {
      _userDocSubscription?.cancel();
      _userDocSubscription = null;
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _firebaseAuth?.signOut();
    } catch (e) {
      debugPrint('[AuthService] Error during SDK signOut: $e');
    } finally {
      _currentUser = null;
      _authStateController.add(null);
      debugPrint('[AuthService] User signed out and local session cleared');
    }
  }

  /// Giải phóng tài nguyên và đóng luồng phát tín hiệu xác thực.
  void dispose() {
    _userDocSubscription?.cancel();
    _authStateController.close();
  }
}

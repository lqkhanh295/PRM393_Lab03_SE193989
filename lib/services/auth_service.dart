import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// Authentication Service Wrapper
/// Provides Google Sign-In, Email/Password, and Real Firestore Profile synchronization.
class AuthService {
  final FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;

  static const String _webClientId = '74927582053-u55o35mih7dnssub0g5c3cmm3mmtcnil.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _webClientId : null,
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  UserModel? _currentUser;
  final _authStateController = StreamController<UserModel?>.broadcast();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSubscription;

  AuthService([this._firebaseAuth, this._firestore]) {
    // If Firebase Auth is provided, listen to its auth state changes
    _firebaseAuth?.authStateChanges().listen((User? user) async {
      if (user != null) {
        final prefix = (user.email ?? '').split('@').first;
        final formattedName = prefix.split('.').map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '').join(' ');
        final basicUser = UserModel(
          id: user.uid,
          name: user.displayName ?? (formattedName.isNotEmpty ? formattedName : 'Sinh viên FPTU'),
          email: user.email ?? '',
          avatarUrl: user.photoURL ?? 'https://i.pravatar.cc/150?u=${user.uid}',
          major: 'Sinh viên FPTU',
          activityPoints: 0,
          role: 'student',
        );
        _currentUser = await _syncUserWithFirestore(basicUser);
        _listenToUserDocument(_currentUser!.id);
      } else {
        _userDocSubscription?.cancel();
        _currentUser = null;
      }
      _authStateController.add(_currentUser);
    });
  }

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

  Future<UserModel> _syncUserWithFirestore(UserModel basicUser) async {
    if (_firestore == null) return basicUser;
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

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  /// Google Sign-In implementation
  Future<UserModel?> signInWithGoogle() async {
    try {
      debugPrint('[AuthService] Initiating Google Sign-In...');
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
          final email = user.email ?? googleUser.email;
          final prefix = email.split('@').first;
          final formattedName = prefix.split('.').map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '').join(' ');
          
          final basicUser = UserModel(
            id: user.uid,
            name: user.displayName ?? googleUser.displayName ?? (formattedName.isNotEmpty ? formattedName : 'Sinh viên FPTU'),
            email: email,
            avatarUrl: user.photoURL ?? googleUser.photoUrl ?? 'https://i.pravatar.cc/150?u=${user.uid}',
            major: 'Kỹ thuật Phần mềm (SE)',
            activityPoints: 0,
            role: 'student',
          );
          _currentUser = await _syncUserWithFirestore(basicUser);
          _listenToUserDocument(_currentUser!.id);
        }
      } else {
        final email = googleUser.email;
        final prefix = email.split('@').first;
        final formattedName = prefix.split('.').map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '').join(' ');
        final basicUser = UserModel(
          id: googleUser.id,
          name: googleUser.displayName ?? (formattedName.isNotEmpty ? formattedName : 'Sinh viên FPTU'),
          email: email,
          avatarUrl: googleUser.photoUrl ?? 'https://i.pravatar.cc/150?u=${googleUser.id}',
          major: 'Kỹ thuật Phần mềm (SE)',
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
      rethrow;
    }
  }

  /// Sign-in with FPT Email & Password implementation
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
            } catch (_) {
              rethrow;
            }
          } else {
            rethrow;
          }
        }

        final User? user = userCred.user;
        if (user != null) {
          final prefix = cleanEmail.split('@').first;
          final formattedName = prefix.split('.').map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '').join(' ');

          final basicUser = UserModel(
            id: user.uid,
            name: user.displayName ?? (formattedName.isNotEmpty ? formattedName : 'Sinh viên FPTU'),
            email: user.email ?? cleanEmail,
            avatarUrl: user.photoURL ?? 'https://i.pravatar.cc/150?u=${user.uid}',
            major: 'Sinh viên FPTU',
            activityPoints: 0,
            role: 'student',
          );
          _currentUser = await _syncUserWithFirestore(basicUser);
          _listenToUserDocument(_currentUser!.id);
        }
      } else {
        // Standalone fallback
        final prefix = cleanEmail.split('@').first;
        final formattedName = prefix.split('.').map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '').join(' ');

        final basicUser = UserModel(
          id: 'USR-${cleanEmail.hashCode.abs()}',
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

  /// Add activity points directly and synchronize with Cloud Firestore
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
    }
  }

  /// Manually reload user document from Cloud Firestore
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
    }
    return _currentUser;
  }

  /// Toggle staff/leader role for demo testing
  void switchDemoRole(String newRole) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: newRole);
      _authStateController.add(_currentUser);
      debugPrint('[AuthService] Role switched to: $newRole');
    }
  }

  /// Sign out & purge local user session data
  Future<void> signOut() async {
    try {
      _userDocSubscription?.cancel();
      _userDocSubscription = null;
      await _googleSignIn.signOut();
      await _firebaseAuth?.signOut();
    } catch (e) {
      debugPrint('[AuthService] Error during SDK signOut: $e');
    } finally {
      _currentUser = null;
      _authStateController.add(null);
      debugPrint('[AuthService] User signed out and local session cleared');
    }
  }

  void dispose() {
    _userDocSubscription?.cancel();
    _authStateController.close();
  }
}

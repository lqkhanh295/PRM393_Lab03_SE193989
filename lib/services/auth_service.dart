import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// Authentication Service Wrapper
/// Provides Google Sign-In and Auth state routing with session purge.
class AuthService {
  final FirebaseAuth? _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn(clientId: kIsWeb ? '1053429994801-campusevent.apps.googleusercontent.com' : null, scopes: ['email', 'profile']);

  UserModel? _currentUser;
  final _authStateController = StreamController<UserModel?>.broadcast();

  AuthService([this._firebaseAuth]) {
    // If Firebase Auth is provided, listen to its auth state changes
    _firebaseAuth?.authStateChanges().listen((User? user) {
      if (user != null) {
        _currentUser = UserModel(
          id: user.uid,
          name: user.displayName ?? 'Nguyễn Văn An',
          email: user.email ?? 'an.nv@fptu.edu.vn',
          avatarUrl: user.photoURL ?? 'https://i.pravatar.cc/150?u=${user.uid}',
          major: 'Kỹ thuật Phần mềm (SE)',
          activityPoints: 25,
          role: 'student',
        );
      } else {
        _currentUser = null;
      }
      _authStateController.add(_currentUser);
    });
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
        throw Exception('Người dùng đã hủy đăng nhập Google.');
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
          _currentUser = UserModel(
            id: user.uid,
            name: user.displayName ?? googleUser.displayName ?? 'Nguyễn Văn An',
            email: user.email ?? googleUser.email,
            avatarUrl: user.photoURL ?? googleUser.photoUrl ?? 'https://i.pravatar.cc/150?u=${user.uid}',
            major: 'Kỹ thuật Phần mềm (SE)',
            activityPoints: 25,
            role: 'student',
          );
        }
      } else {
        // Standalone / offline demo fallback
        _currentUser = UserModel(
          id: googleUser.id,
          name: googleUser.displayName ?? 'Nguyễn Văn An',
          email: googleUser.email,
          avatarUrl: googleUser.photoUrl ?? 'https://i.pravatar.cc/150?u=${googleUser.id}',
          major: 'Kỹ thuật Phần mềm (SE)',
          activityPoints: 25,
          role: 'student',
        );
      }

      _authStateController.add(_currentUser);
      debugPrint('[AuthService] Sign-in successful: ${_currentUser?.email}');
      return _currentUser;
    } catch (e) {
      debugPrint('[AuthService] Sign-in error: $e');
      rethrow;
    }
  }

  /// Demo quick login helper for emulator / testing
  Future<UserModel> signInDemoStudent({String role = 'student'}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = UserModel(
      id: 'USR-FPTU-2026',
      name: 'Nguyễn Văn An',
      email: 'an.nv@fptu.edu.vn',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      major: 'Kỹ thuật Phần mềm (SE18)',
      activityPoints: 25,
      role: role,
      followedClubs: ['fcode', 'media_club'],
    );
    _authStateController.add(_currentUser);
    return _currentUser!;
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
    _authStateController.close();
  }
}

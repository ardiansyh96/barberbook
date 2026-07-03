import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../../main.dart';
import '../../../../shared/services/fcm_service.dart';

/// Singleton auth service instance
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provider that listens to Firebase auth state and returns the UserModel.
///
/// This is the core auth state provider used by:
/// - GoRouter for redirect logic (RBAC)
/// - UI widgets for showing/hiding auth-dependent content
/// - Splash screen for navigation decisions
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);

  debugPrint('[AuthProvider] Setting up authStateChanges stream listener');

  return authService.authStateChanges.asyncMap((firebaseUser) async {
    if (firebaseUser == null) {
      debugPrint('[AuthProvider] 🚫 No Firebase user (not logged in)');
      return null;
    }

    debugPrint('[AuthProvider] ✅ Firebase user found: ${firebaseUser.uid}');
    debugPrint('[AuthProvider] Fetching user profile from Firestore...');

    final userProfile = await authService.getUserProfile(firebaseUser.uid);

    if (userProfile != null) {
      debugPrint('[AuthProvider] ✅ User Profile Loaded:');
      debugPrint('[AuthProvider]   - Name: ${userProfile.nama}');
      debugPrint('[AuthProvider]   - Email: ${userProfile.email}');
      debugPrint('[AuthProvider]   - Role: ${userProfile.role}');
      return userProfile;
    }

    debugPrint('[AuthProvider] ⚠️ User profile not found in Firestore. Falling back to Firebase auth data.');
    return UserModel(
      uid: firebaseUser.uid,
      nama: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      role: 'customer',
      createdAt: DateTime.now(),
    );
  });
});

/// Provider for auth-related UI state (loading, errors)
class AuthState {
  final bool isLoading;
  final String? errorMessage;

  const AuthState({this.isLoading = false, this.errorMessage});

  AuthState copyWith({bool? isLoading, String? errorMessage}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}


class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  /// Login with email and password.
  ///
  /// If [rememberMe] is true, saves the email to SharedPreferences
  /// for auto-fill on next login.
  Future<UserModel?> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.login(email: email, password: password);

      final fcmService = FcmService();

      await fcmService.getToken(user.uid);

      await fcmService.subscribeToTopics(user);

      // Handle Remember Me persistence
      if (rememberMe) {
        await sharedPrefsService.setRememberMe(true);
        await sharedPrefsService.setSavedEmail(email);
      } else {
        await sharedPrefsService.setRememberMe(false);
        await sharedPrefsService.remove('user_email');
      }

      state = state.copyWith(isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  /// Register a new customer account.
  ///
  /// Creates Firebase Auth user + Firestore document.
  /// Sends verification email automatically.
  Future<UserModel?> register({
    required String nama,
    required String email,
    required String password,
    String? nomorHP,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.register(
        nama: nama,
        email: email,
        password: password,
        nomorHP: nomorHP,
      );
      state = state.copyWith(isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  /// Logout the current user and clear preferences if needed.
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
      await FcmService().unsubscribeFromAllTopics();
      await sharedPrefsService.setRememberMe(false);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.resetPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Send email verification to the current user
  Future<bool> sendVerificationEmail() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.sendVerificationEmail();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Check if the current user's email has been verified.
  /// Reloads the user data from Firebase to get fresh verification status.
  Future<bool> checkEmailVerified() async {
    try {
      await _authService.reloadUser();
      return _authService.isEmailVerified;
    } catch (e) {
      return false;
    }
  }

  /// Re-authenticate the current user with email and password.
  /// Required before sensitive operations like changing password.
  Future<void> reauthenticate(String email, String password) async {
    await _authService.reauthenticate(email, password);
  }

  /// Change the current user's password.
  /// Should call [reauthenticate] first to verify identity.
  Future<void> changePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.changePassword(newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

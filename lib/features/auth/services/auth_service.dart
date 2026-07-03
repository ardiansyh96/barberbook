import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firebase_collections.dart';
import '../../../core/utils/logger.dart';
import '../models/user_model.dart';

/// Authentication service handling Firebase Auth operations.
///
/// Provides methods for:
/// - Email/Password registration and login
/// - Password reset
/// - Email verification
/// - Sign out
/// - Fetching the current user's profile from Firestore
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current Firebase user (null if not signed in)
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges {
    debugPrint('[AuthService] Creating authStateChanges stream');
    return _auth.authStateChanges().map((user) {
      if (user != null) {
        debugPrint('[AuthService] 📡 Firebase auth state: user=${user.uid}, email=${user.email}');
      } else {
        debugPrint('[AuthService] 📡 Firebase auth state: no user');
      }
      return user;
    });
  }

  /// Whether the current user's email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Reload the current user's data from Firebase
  /// (needed after email verification to refresh the status)
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Send email verification to the current user
  Future<void> sendVerificationEmail() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user is signed in');
      await user.sendEmailVerification();
      logger.info('Verification email sent to: ${user.email}');
    } on FirebaseAuthException catch (e) {
      logger.error('Send verification email error: ${e.code}');
      throw _mapAuthError(e);
    }
  }

  /// Register a new customer account.
  ///
  /// Creates both the Firebase Auth user and the Firestore user document.
  /// Returns the [UserModel] on success, throws on failure.
  Future<UserModel> register({
    required String nama,
    required String email,
    required String password,
    String? nomorHP,
  }) async {
    try {
      // 1. Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Registration failed: user is null');

      // 2. Update display name
      await user.updateDisplayName(nama);

      // 3. Send email verification
      await user.sendEmailVerification();

      // 4. Create Firestore user document with 'customer' role
      final userModel = UserModel(
        uid: user.uid,
        nama: nama,
        email: email,
        nomorHP: nomorHP,
        role: 'customer',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .set(userModel.toJson());

      logger.info('User registered successfully: ${user.uid}');
      return userModel;
    } on FirebaseAuthException catch (e) {
      logger.error('Registration error: ${e.code} - ${e.message}');
      throw _mapAuthError(e);
    } catch (e) {
      logger.error('Registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  /// Login with email and password.
  ///
  /// Returns the [UserModel] from Firestore on success.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Login failed: user is null');

      // Fetch user profile from Firestore
      final userModel = await getUserProfile(user.uid);
      if (userModel == null) {
        throw Exception('User profile not found in database');
      }

      logger.info('User logged in: ${user.uid} (role: ${userModel.role})');
      return userModel;
    } on FirebaseAuthException catch (e) {
      logger.error('Login error: ${e.code} - ${e.message}');
      throw _mapAuthError(e);
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      logger.info('Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      logger.error('Password reset error: ${e.code}');
      throw _mapAuthError(e);
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      // Clear FCM token before signing out
      final user = currentUser;
      if (user != null) {
        await _firestore
            .collection(FirebaseCollections.users)
            .doc(user.uid)
            .update({'fcmToken': FieldValue.delete()});
      }
      await _auth.signOut();
      logger.info('User logged out');
    } catch (e) {
      logger.error('Logout error: $e');
      throw Exception('Logout failed: $e');
    }
  }

  /// Change password for the current user
  Future<void> changePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user is signed in');
      await user.updatePassword(newPassword);
      logger.info('Password changed for user: ${user.uid}');
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Re-authenticate user before sensitive operations (e.g., password change)
  Future<void> reauthenticate(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Fetch user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      debugPrint('[AuthService] 🔍 Fetching user profile from Firestore: $uid');
      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .get();

      if (!doc.exists) {
        debugPrint('[AuthService] ⚠️ User document not found in Firestore');
        return null;
      }
      
      final userModel = UserModel.fromFirestore(doc);
      debugPrint('[AuthService] ✅ User profile fetched successfully');
      return userModel;
    } catch (e) {
      debugPrint('[AuthService] ❌ Failed to fetch user profile: $e');
      logger.error('Failed to fetch user profile: $e');
      return null;
    }
  }

  /// Update user profile fields in Firestore
  Future<void> updateProfile(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update(updates);
      logger.info('Profile updated for user: $uid');
    } catch (e) {
      logger.error('Profile update error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Delete user account (both Auth and Firestore document)
  Future<void> deleteAccount(String uid) async {
    try {
      await _firestore.collection(FirebaseCollections.users).doc(uid).delete();
      await currentUser?.delete();
      logger.info('Account deleted: $uid');
    } catch (e) {
      logger.error('Delete account error: $e');
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Map Firebase Auth error codes to user-friendly messages
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters';
      case 'invalid-email':
        return 'Invalid email address';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'operation-not-allowed':
        return 'Email/password sign-up is currently disabled in Firebase Authentication. Please enable the Email/Password provider in the Firebase console.';
      default:
        return e.message ?? 'Authentication error';
    }
  }
}

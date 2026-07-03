import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

/// Wrapper service for SharedPreferences to handle local data persistence.
///
/// Manages:
/// - Remember me state
/// - Cached user email
/// - Theme preference
/// - Onboarding completion flag
class SharedPrefsService {
  late SharedPreferences _prefs;

  /// Initialize SharedPreferences (must be called before using other methods)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    logger.info('SharedPreferences initialized');
  }

  // ─── Remember Me ────────────────────────────────────────────────────

  bool get rememberMe => _prefs.getBool(AppConstants.prefRememberMe) ?? false;

  Future<void> setRememberMe(bool value) async {
    await _prefs.setBool(AppConstants.prefRememberMe, value);
  }

  String? get savedEmail => _prefs.getString(AppConstants.prefUserEmail);

  Future<void> setSavedEmail(String email) async {
    await _prefs.setString(AppConstants.prefUserEmail, email);
  }

  // ─── Theme ──────────────────────────────────────────────────────────

  String get themeMode => _prefs.getString(AppConstants.prefThemeMode) ?? 'light';

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(AppConstants.prefThemeMode, mode);
  }

  // ─── Onboarding ─────────────────────────────────────────────────────

  bool get onboardingComplete =>
      _prefs.getBool(AppConstants.prefOnboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(AppConstants.prefOnboardingComplete, value);
  }

  // ─── Generic Helpers ────────────────────────────────────────────────

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) => _prefs.getString(key);

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) => _prefs.getInt(key);

  /// Clear all stored preferences (used on logout)
  Future<void> clearAll() async {
    await _prefs.clear();
    logger.info('All SharedPreferences cleared');
  }

  /// Remove a specific key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}

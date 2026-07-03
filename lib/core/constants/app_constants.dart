/// Application-wide constants for BarberBook.
///
/// Centralizes all magic strings, numeric limits, and configuration values
/// to ensure consistency across the entire application.
class AppConstants {
  AppConstants._();

  // ─── Application Info ───────────────────────────────────────────────
  static const String appName = 'BarberBook';
  static const String appVersion = '1.0.0';

  // ─── Booking Constraints ────────────────────────────────────────────
  /// Maximum number of days in advance a customer can book
  static const int maxBookingDaysAhead = 30;

  /// Minimum minutes before a booking time that cancellation is allowed
  static const int minCancellationMinutes = 60;

  /// Time slot interval in minutes for booking
  static const int timeSlotIntervalMinutes = 30;

  // ─── Pagination ─────────────────────────────────────────────────────
  /// Default number of items per page for list views
  static const int defaultPageSize = 20;

  // ─── Image Constraints ──────────────────────────────────────────────
  /// Maximum image file size in bytes (5 MB)
  static const int maxImageSizeBytes = 5 * 1024 * 1024;

  /// Maximum image dimension for compression
  static const int maxImageDimension = 1080;

  /// Image quality for compression (0-100)
  static const int imageQuality = 85;

  // ─── Rating ─────────────────────────────────────────────────────────
  static const int minRating = 1;
  static const int maxRating = 5;

  // ─── Password ───────────────────────────────────────────────────────
  static const int minPasswordLength = 8;

  // ─── Animation Durations ────────────────────────────────────────────
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // ─── Debounce ───────────────────────────────────────────────────────
  /// Debounce duration for search input
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // ─── Timeout ────────────────────────────────────────────────────────
  /// Timeout duration for network operations
  static const Duration networkTimeout = Duration(seconds: 30);

  // ─── User Roles ─────────────────────────────────────────────────────
  static const String roleCustomer = 'customer';
  static const String roleAdmin = 'admin';

  // ─── Booking Status ─────────────────────────────────────────────────
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusProcessing = 'processing';
  static const String statusCompleted = 'completed';
  static const String statusRejected = 'rejected';
  static const String statusCancelled = 'cancelled';

  // ─── Shared Preferences Keys ────────────────────────────────────────
  static const String prefRememberMe = 'remember_me';
  static const String prefUserEmail = 'user_email';
  static const String prefThemeMode = 'theme_mode';
  static const String prefOnboardingComplete = 'onboarding_complete';

  // ─── FCM Topics ─────────────────────────────────────────────────────
  static const String topicAllCustomers = 'all_customers';
  static const String topicAllAdmins = 'all_admins';
  static const String topicPromotions = 'promotions';
}

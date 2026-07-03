/// Asset path constants for images and icons used in the app.
///
/// Using constants prevents typos in asset paths and provides
/// a single source of truth for all asset references.
class AssetConstants {
  AssetConstants._();

  // ─── Images ─────────────────────────────────────────────────────────
  static const String basePath = 'assets/images';
  static const String logoApp = '$basePath/logo_app.png';
  static const String logoSplash = '$basePath/logo_splash.png';
  static const String placeholderAvatar = '$basePath/placeholder_avatar.png';
  static const String placeholderBarber = '$basePath/placeholder_barber.png';
  static const String emptyState = '$basePath/empty_state.png';
  static const String noInternet = '$basePath/no_internet.png';

  // ─── Icons ──────────────────────────────────────────────────────────
  static const String iconBasePath = 'assets/icons';
  static const String iconScissors = '$iconBasePath/ic_scissors.png';
  static const String iconBooking = '$iconBasePath/ic_booking.png';
}

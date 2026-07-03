/// Firestore collection names used throughout the application.
///
/// Centralizing collection names prevents typos and makes it easier
/// to rename collections across the entire codebase.
class FirebaseCollections {
  FirebaseCollections._();

  static const String users = 'users';
  static const String barbers = 'barbers';
  static const String services = 'services';
  static const String bookings = 'bookings';
  static const String reviews = 'reviews';
  static const String notifications = 'notifications';
  static const String banners = 'banners';

  // ─── Sub-collection / Field References ──────────────────────────────
  /// Storage bucket paths
  static const String storageBarberPhotos = 'barber_photos';
  static const String storageServiceImages = 'service_images';
  static const String storageBannerImages = 'banner_images';
  static const String storageUserPhotos = 'user_photos';
}

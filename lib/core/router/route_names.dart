/// Centralized route path constants for GoRouter navigation.
///
/// Using constants prevents typos in route paths and makes
/// navigation changes traceable across the codebase.
class RouteNames {
  RouteNames._();

  // ─── Auth Routes ────────────────────────────────────────────────────
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';

  // ─── Customer Routes ────────────────────────────────────────────────
  static const String customerShell = '/customer';
  static const String customerHome = '/customer/home';
  static const String customerSearch = '/customer/search';
  static const String customerBooking = '/customer/booking';
  static const String customerProfile = '/customer/profile';

  // Customer sub-routes
  static const String barberList = '/customer/barbers';
  static const String barberDetail = '/customer/barbers/:barberId';
  static const String bookingCreate = '/customer/booking/create';
  static const String bookingDetail = '/customer/booking/:bookingId';
  static const String bookingHistory = '/customer/booking/history';
  static const String rating = '/customer/rating/:bookingId';
  static const String editProfile = '/customer/profile/edit';
  static const String changePassword = '/customer/profile/change-password';
  static const String notifications = '/customer/notifications';

  // ─── Admin Routes ───────────────────────────────────────────────────
  static const String adminShell = '/admin';
  static const String adminHome = '/admin/home';
  static const adminBarberDetail = "/admin/barber/:barberId";

  // Admin sub-routes
  static const String adminBarberList = '/admin/barbers';
  static const String adminBarberAdd = '/admin/barbers/add';
  static const String adminBarberEdit = '/admin/barbers/:barberId/edit';
  static const String adminServiceList = '/admin/services';
  static const String adminServiceAdd = '/admin/services/add';
  static const String adminServiceDetail = '/admin/services/:serviceId';
  static const String adminServiceEdit = '/admin/services/:serviceId/edit';
  static const String adminBookingList = '/admin/bookings';
  static const String adminBookingDetail = '/admin/bookings/:bookingId';
  static const String adminCustomerList = '/admin/customers';
  static const String adminCustomerDetail = '/admin/customers/:customerId';
  static const String adminReviewList = '/admin/reviews';
  static const String adminBannerList = '/admin/banners';
  static const String adminBannerAdd = '/admin/banners/add';
  static const String adminBannerEdit = '/admin/banners/:bannerId/edit';
  static const String adminBannerDetail = '/admin/banners/:bannerId';
  static const String adminSendNotification = '/admin/notifications/send';
  static const String adminSeeder = '/admin/seeder';
}

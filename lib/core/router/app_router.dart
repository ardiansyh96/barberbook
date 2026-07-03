import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/email_verification_screen.dart';
import '../../features/customer/shell/customer_shell.dart';
import '../../features/customer/dashboard/screens/customer_home_screen.dart';
import '../../features/customer/search/screens/search_screen.dart';
import '../../features/customer/booking/screens/booking_screen.dart';
import '../../features/customer/booking/screens/booking_create_screen.dart';
import '../../features/customer/booking/screens/booking_detail_screen.dart';
import '../../features/customer/profile/screens/customer_profile_screen.dart';
import '../../features/customer/profile/screens/edit_profile_screen.dart';
import '../../features/customer/profile/screens/change_password_screen.dart';
import '../../features/customer/barber/screens/barber_list_screen.dart';
import '../../features/customer/barber/screens/barber_detail_screen.dart';
import '../../features/customer/notification/screens/notification_screen.dart';
import '../../features/customer/rating/screens/rating_screen.dart';
import '../../features/admin/shell/admin_shell.dart';
import '../../features/admin/dashboard/screens/admin_home_screen.dart';
import '../../features/admin/barber_mgmt/screens/admin_barber_list_screen.dart';
import '../../features/admin/barber_mgmt/screens/admin_barber_form_screen.dart';
import '../../features/admin/service_mgmt/screens/admin_service_list_screen.dart';
import '../../features/admin/service_mgmt/screens/admin_service_form_screen.dart';
import '../../features/admin/booking_mgmt/screens/admin_booking_list_screen.dart';
import '../../features/admin/banner_mgmt/screens/admin_banner_list_screen.dart';
import '../../features/admin/banner_mgmt/screens/admin_banner_detail_screen.dart';
import '../../features/admin/banner_mgmt/screens/admin_banner_form_screen.dart';
import '../../features/admin/customer_mgmt/screens/admin_customer_list_screen.dart';
import '../../features/admin/review_mgmt/screens/admin_review_list_screen.dart';
import '../../features/admin/notification_mgmt/screens/admin_send_notification_screen.dart';
import '../../features/admin/dashboard/screens/seeder_screen.dart';
import 'route_names.dart';
import '../../features/admin/service_mgmt/screens/admin_service_detail_screen.dart';
import 'dart:async';


final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> customerShellKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> adminShellKey = GlobalKey<NavigatorState>();

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Stream stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = GoRouterRefreshNotifier(
  ref.read(authStateProvider.stream),
);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: refreshNotifier,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,

    redirect: (context, state) {
      final currentPath = state.matchedLocation;
      final authState = ref.read(authStateProvider);

      if (authState.isLoading) {
        debugPrint(
            '[GoRouter] ⏳ AuthState is loading... (path: $currentPath)');
        return null;
      }

      final user = authState.valueOrNull;

      // Skip redirect logic while on splash screen (let SplashScreen handle it)
      if (currentPath == RouteNames.splash) {
        return null;
      }

      // If no user and trying to access protected route -> redirect to login
      if (user == null) {
        final isAuthRoute = currentPath == '/login' || 
                           currentPath == '/register' || 
                           currentPath == '/forgot-password' ||
                           currentPath == '/email-verification';
        
        if (!isAuthRoute) {
          debugPrint('[GoRouter] 🚫 Unauthenticated user accessing protected route: $currentPath');
          debugPrint('[GoRouter] 🔄 Redirect to /login');
          return '/login';
        }
        return null; // Allow access to auth routes
      }

      debugPrint('[GoRouter] ✅ User authenticated: ${user.role}');

      // Admin trying to access customer routes
      if (user.isAdmin && currentPath.startsWith('/customer')) {
        debugPrint('[GoRouter] 🔄 Admin accessing customer route, redirecting to /admin/home');
        return '/admin/home';
      }

      // Customer trying to access admin routes
      if (user.isCustomer && currentPath.startsWith('/admin')) {
        debugPrint('[GoRouter] 🔄 Customer accessing admin route, redirecting to /customer/home');
        return '/customer/home';
      }

      // Access allowed
      return null;
    },

    routes: [
      // ─── Auth Routes (no bottom nav) ──────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.emailVerification,
        name: 'email-verification',
        builder: (context, state) => const EmailVerificationScreen(),
      ),

      // ─── Customer Shell Route (with bottom navigation) ────────────
      ShellRoute(
        navigatorKey: customerShellKey,
        builder: (context, state, child) => CustomerShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.customerHome,
            name: 'customer-home',
            builder: (context, state) => const CustomerHomeScreen(),
          ),
          GoRoute(
            path: RouteNames.customerSearch,
            name: 'customer-search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: RouteNames.customerBooking,
            name: 'customer-booking',
            builder: (context, state) => const BookingScreen(),
          ),
          GoRoute(
            path: RouteNames.bookingCreate,
            name: 'booking-create',
            builder: (context, state) {
              final barberId = state.uri.queryParameters['barberId'];
              return BookingCreateScreen(initialBarberId: barberId);
            },
          ),
          GoRoute(
            path: '/booking/:bookingId',
            name: 'booking-detail',
            builder: (context, state) {
              final bookingId = state.pathParameters['bookingId']!;
              return BookingDetailScreen(bookingId: bookingId);
            },
          ),
          GoRoute(
            path: RouteNames.customerProfile,
            name: 'customer-profile',
            builder: (context, state) => const CustomerProfileScreen(),
          ),
          GoRoute(
            path: RouteNames.editProfile,
            name: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: RouteNames.changePassword,
            name: 'change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: RouteNames.barberList,
            name: 'barber-list',
            builder: (context, state) => const BarberListScreen(),
          ),
          GoRoute(
            path: RouteNames.barberDetail,
            name: 'barber-detail',
            builder: (context, state) {
              final barberId = state.pathParameters['barberId'] ?? '';
              return BarberDetailScreen(barberId: barberId);
            },
          ),
          GoRoute(
            path: RouteNames.notifications,
            name: 'notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: RouteNames.rating,
            name: 'rating',
            builder: (context, state) {
              final bookingId = state.pathParameters['bookingId'] ?? '';
              return RatingScreen(bookingId: bookingId);
            },
          ),
        ],
      ),

      // ─── Admin Shell Route (with admin sidebar/bottom nav) ────────
      ShellRoute(
        navigatorKey: adminShellKey,
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          
          GoRoute(
            path: RouteNames.adminHome,
            name: 'admin-home',
            builder: (context, state) => const AdminHomeScreen(),
          ),
          GoRoute(
            path: RouteNames.adminBarberList,
            name: 'admin-barber-list',
            builder: (context, state) => const AdminBarberListScreen(),
          ),
          GoRoute(
            path: RouteNames.adminBarberAdd,
            name: 'admin-barber-add',
            builder: (context, state) => const AdminBarberFormScreen(),
          ),
          GoRoute(
            path: RouteNames.adminBarberEdit,
            name: 'admin-barber-edit',
            builder: (context, state) {
              final barberId = state.pathParameters['barberId'] ?? '';
              return AdminBarberFormScreen(barberId: barberId);
            },
          ),
          GoRoute(
            path: RouteNames.adminServiceList,
            name: 'admin-service-list',
            builder: (context, state) => const AdminServiceListScreen(),
          ),
          GoRoute(
            path: RouteNames.adminServiceAdd,
            name: 'admin-service-add',
            builder: (context, state) => const AdminServiceFormScreen(),
          ),
          GoRoute(
            path: RouteNames.adminServiceEdit,
            name: 'admin-service-edit',
            builder: (context, state) {
              final serviceId = state.pathParameters['serviceId'] ?? '';
              return AdminServiceFormScreen(serviceId: serviceId);
            },
          ),
          GoRoute(
            path: RouteNames.adminBookingList,
            name: 'admin-booking-list',
            builder: (context, state) => const AdminBookingListScreen(),
          ),
       
          GoRoute(
            path: RouteNames.adminBannerList,
            name: 'admin-banner-list',
            builder: (context, state) =>
                const AdminBannerListScreen(),
          ),

          GoRoute(
            path: RouteNames.adminBannerAdd,
            name: 'admin-banner-add',
            builder: (context, state) =>
                const AdminBannerFormScreen(),
          ),

          GoRoute(
            path: RouteNames.adminBannerEdit,
            name: 'admin-banner-edit',
            builder: (context, state) {

              final bannerId =
                  state.pathParameters['bannerId']!;

              return AdminBannerFormScreen(
                bannerId: bannerId,
              );

            },
          ),

          GoRoute(
            path: RouteNames.adminBannerDetail,
            name: 'admin-banner-detail',
            builder: (context, state) {

              final bannerId =
                  state.pathParameters['bannerId']!;

              return AdminBannerDetailScreen(
                bannerId: bannerId,
              );

            },
          ),
          GoRoute(
            path: RouteNames.adminCustomerList,
            name: 'admin-customer-list',
            builder: (context, state) => const AdminCustomerListScreen(),
          ),
          GoRoute(
            path: RouteNames.adminReviewList,
            name: 'admin-review-list',
            builder: (context, state) => const AdminReviewListScreen(),
          ),
          GoRoute(
            path: RouteNames.adminSendNotification,
            name: 'admin-send-notification',
            builder: (context, state) => const AdminSendNotificationScreen(),
          ),
          GoRoute(
            path: RouteNames.adminSeeder,
            name: 'admin-seeder',
            builder: (context, state) => const SeederScreen(),
          ),

          GoRoute(
          path: RouteNames.adminServiceDetail,

          builder: (context, state) {

            return AdminServiceDetailScreen(

              serviceId:
                  state.pathParameters["serviceId"]!,

            );

          },

        ),
        ],
      ),
    ],

    // ─── Error Page ─────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/auth/providers/auth_provider.dart';


class RouteGuards {
  RouteGuards._();

  /// Check if the current route is an admin-only route
  static bool isAdminRoute(String path) {
    return path.startsWith('/admin');
  }

  /// Check if the current route is a customer-only route
  static bool isCustomerRoute(String path) {
    return path.startsWith('/customer');
  }

  /// Check if the current route is a public route (no auth required)
  static bool isPublicRoute(String path) {
    const publicRoutes = {
      '/splash',
      '/login',
      '/register',
      '/forgot-password',
      '/email-verification',
    };
    return publicRoutes.contains(path);
  }

  /// Determine the redirect path based on auth state and role.
  ///
  /// Returns the path to redirect to, or null if access is allowed.
  static String? getRedirect({
    required String currentPath,
    UserModel? user,
  }) {
    // Not logged in -> redirect to login (NOT splash, to avoid infinite loop)
    if (user == null) {
      debugPrint('[RouteGuards] User is null (not authenticated)');
      
      // Allow splash and login routes for unauthenticated users
      if (currentPath == '/splash' || currentPath == '/login' || 
          currentPath == '/register' || currentPath == '/forgot-password' ||
          currentPath == '/email-verification') {
        debugPrint('[RouteGuards] ✅ Allowing access to public route: $currentPath');
        return null;
      }
      
      debugPrint('[RouteGuards] 🔄 Redirecting unauthenticated user to /login');
      return '/login';
    }

    debugPrint('[RouteGuards] ✅ User authenticated (role: ${user.role})');

    // Public routes are always accessible
    // User sudah login tapi masih membuka halaman login/splash
    if (isPublicRoute(currentPath)) {
      if (user.isAdmin) {
        return '/admin/home';
      }

      if (user.isCustomer) {
        return '/customer/home';
      }
    }

    // Admin trying to access customer routes
    if (user.isAdmin && isCustomerRoute(currentPath)) {
      debugPrint('[RouteGuards] 🔄 Admin accessing customer route, redirecting to /admin/home');
      return '/admin/home';
    }

    // Customer trying to access admin routes
    if (user.isCustomer && isAdminRoute(currentPath)) {
      debugPrint('[RouteGuards] 🔄 Customer accessing admin route, redirecting to /customer/home');
      return '/customer/home';
    }

    debugPrint('[RouteGuards] ✅ Access allowed to: $currentPath');
    // Access allowed
    return null;
  }
}

/// Provider that exposes the current user's role for route guards.
/// Used by GoRouter's redirect callback.
final routeGuardProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(
    data: (user) => user?.role,
  );
});

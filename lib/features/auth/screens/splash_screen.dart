import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/router/route_names.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isNavigating = false;
  ProviderSubscription<AsyncValue<UserModel?>>? _authSubscription;

  @override
  void initState() {
    super.initState();
    debugPrint('[SplashScreen] 🚀 SplashScreen initialized');
    _checkAndNavigate();
  }

  @override
  void dispose() {
    // Clean up the listener to prevent memory leaks
    _authSubscription?.close();
    debugPrint('[SplashScreen] 🧹 Disposed and cleaned up listeners');
    super.dispose();
  }

  Future<void> _checkAndNavigate() async {
    debugPrint('[SplashScreen] ⏳ Waiting for splash animation (2s)...');
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) {
      debugPrint('[SplashScreen] ⚠️ Widget unmounted before navigation');
      return;
    }

    debugPrint('[SplashScreen] ✅ Splash animation complete');

    // Check internet connectivity
    debugPrint('[SplashScreen] 🌐 Checking internet connectivity...');
    final connectivity = await Connectivity().checkConnectivity();
    if (!mounted) return;

    if (connectivity.contains(ConnectivityResult.none)) {
      debugPrint('[SplashScreen] ❌ No internet connection');
      _showNoInternetDialog();
      return;
    }

    debugPrint('[SplashScreen] ✅ Internet Connected');

    // Listen to auth state changes and navigate accordingly
    debugPrint('[SplashScreen] 👂 Listening to auth state changes...');
    _listenToAuthState();
  }

  void _listenToAuthState() {
    debugPrint('[SplashScreen] 📡 Setting up auth state listener with listenManual');
    
    // Use listenManual() which can be called outside build()
    // This returns a ProviderSubscription that we must clean up in dispose()
    _authSubscription = ref.listenManual<AsyncValue<UserModel?>>(
      authStateProvider,
      (previous, next) {
        _handleAuthState(next);
      },
      fireImmediately: true,
    );
  }

  void _handleAuthState(AsyncValue<UserModel?> authState) {
    if (_isNavigating) {
      debugPrint('[SplashScreen] ⚠️ Already navigating, ignoring auth update');
      return;
    }

    debugPrint('[SplashScreen] 📡 Auth state changed: ${authState.runtimeType}');

    authState.whenOrNull(
      data: (user) {
        debugPrint('[SplashScreen] 📦 Auth data received');
        if (user == null) {
          // Not logged in -> go to Login
          debugPrint('[SplashScreen] 🚫 User not logged in');
          debugPrint('[SplashScreen] 🔄 Redirect to Login Screen');
          _navigateTo(RouteNames.login);
        } else if (user.isAdmin) {
          // Logged in as Admin -> go to Admin Dashboard
          debugPrint('[SplashScreen] 👑 User is ADMIN');
          debugPrint('[SplashScreen] 🔄 Redirect to Admin Dashboard');
          _navigateTo(RouteNames.adminHome);
        } else if (user.isCustomer) {
          // Logged in as Customer -> go to Customer Dashboard
          debugPrint('[SplashScreen] 👤 User is CUSTOMER');
          debugPrint('[SplashScreen] 🔄 Redirect to Customer Dashboard');
          _navigateTo(RouteNames.customerHome);
        } else {
          debugPrint('[SplashScreen] ⚠️ Unknown role: ${user.role}');
          _navigateTo(RouteNames.login);
        }
      },
      error: (error, stackTrace) {
        // On error, redirect to login
        debugPrint('[SplashScreen] ❌ Auth state error: $error');
        debugPrint('[SplashScreen] 🔄 Redirect to Login (error case)');
        _navigateTo(RouteNames.login);
      },
    );
  }

  void _navigateTo(String route) {
    if (_isNavigating || !mounted) {
      debugPrint('[SplashScreen] ⚠️ Navigation blocked (_isNavigating=$_isNavigating, mounted=$mounted)');
      return;
    }
    _isNavigating = true;
    debugPrint('[SplashScreen] 🚀 Navigating to: $route');
    context.go(route);
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text(
          'Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkAndNavigate();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // App Logo / Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.content_cut,
                size: 60,
                color: AppColors.gold,
              ),
            ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: AppDimensions.spacingXL),
            // App Name
            Text(
              'BarberBook',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: AppDimensions.spacingSM),
            // Tagline
            Text(
              'Premium Barbershop Reservation',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gold.withValues(alpha: 0.8),
                  ),
            ).animate(delay: 600.ms).fadeIn(),
            const Spacer(flex: 2),
            // Loading indicator
            const CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 2,
            ).animate(delay: 800.ms).fadeIn(),
            const SizedBox(height: AppDimensions.spacingXXXL),
          ],
        ),
      ),
    );
  }
}

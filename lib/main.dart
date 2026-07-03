import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'shared/services/shared_prefs_service.dart';
import 'shared/services/fcm_service.dart';
import 'core/utils/logger.dart';


/// Global SharedPrefsService instance, initialized before runApp.
late final SharedPrefsService sharedPrefsService;

void main() async {
  // Ensure Flutter bindings are initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('[Startup] === APP STARTING ===');

  // Lock orientation to portrait for mobile-first design
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  debugPrint('[Startup] Orientation locked to portrait');

  // Set system UI overlay style (transparent status bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    debugPrint('[Startup] ✅ Firebase Initialized');
    logger.info('Firebase initialized successfully');
  } catch (e) {
    debugPrint('[Startup] ❌ Firebase initialization failed: $e');
    logger.error('Firebase initialization failed: $e');
    // App will still run but Firebase features won't work
    // This allows development without Firebase config
  }

  // Initialize SharedPreferences
  debugPrint('[Startup] Initializing SharedPreferences...');
  sharedPrefsService = SharedPrefsService();
  await sharedPrefsService.init();
  debugPrint('[Startup] ✅ SharedPreferences Initialized');

  try {

  await FcmService().initialize();

  debugPrint('[Startup] ✅ FCM Initialized');

} catch (e) {

  debugPrint('[Startup] ❌ FCM Failed : $e');

}

  debugPrint('[Startup] === CALLING runApp() ===');
  runApp(
    const ProviderScope(
      child: BarberBookApp(),
    ),
  );
}

/// Root widget of the BarberBook application.
///
/// Uses ProviderScope for Riverpod state management and
/// GoRouter for navigation with RBAC route guards.
class BarberBookApp extends ConsumerWidget {
  const BarberBookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider (rebuilds on auth state changes)
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Material Design 3 Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default to light; will add toggle later

      // GoRouter integration
      routerConfig: router,
    );
  }
}

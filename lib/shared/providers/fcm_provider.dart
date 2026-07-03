import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/fcm_service.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Provider for the FCM service singleton.
final fcmServiceProvider = Provider<FcmService>((ref) => FcmService());

/// Provider that initializes FCM when a user is authenticated.
///
/// Automatically:
/// - Gets and saves the FCM device token
/// - Subscribes to role-based topics
/// - Unsubscribes on logout
final fcmInitProvider = FutureProvider<void>((ref) async {
  final authState = ref.watch(authStateProvider);
  final fcmService = ref.watch(fcmServiceProvider);

  final user = authState.whenOrNull(data: (u) => u);
  if (user != null) {
    await fcmService.getToken(user.uid);
    await fcmService.subscribeToTopics(user);
  }
});

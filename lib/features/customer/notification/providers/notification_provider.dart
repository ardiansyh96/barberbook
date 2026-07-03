import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

/// Provider for notification service singleton
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

/// Provider that streams user's notifications
final userNotificationsProvider = StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  final service = ref.watch(notificationServiceProvider);
  return service.getUserNotifications(userId);
});

/// Provider that streams unread notification count
final unreadCountProvider = StreamProvider.family<int, String>((ref, userId) {
  final service = ref.watch(notificationServiceProvider);
  return service.getUnreadCount(userId);
});

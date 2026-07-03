import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

/// Notification screen showing all user notifications from Firestore.
///
/// Features:
/// - Real-time notification list from Firestore
/// - Mark individual notifications as read on tap
/// - "Mark all as read" action in app bar
/// - Swipe-to-delete individual notifications
/// - Pull-to-refresh
/// - Type-based icons and colors (booking_new, booking_confirmed, etc.)
/// - Empty state when no notifications
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).whenOrNull(data: (u) => u);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please login to view notifications')),
      );
    }

    final notificationsAsync = ref.watch(userNotificationsProvider(user.uid));
    final unreadCountAsync = ref.watch(unreadCountProvider(user.uid));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Mark all as read button (only show if there are unread)
          unreadCountAsync.whenOrNull(
                data: (count) => count > 0
                    ? IconButton(
                        icon: const Icon(Icons.done_all),
                        tooltip: 'Mark all as read',
                        onPressed: () => _markAllAsRead(ref, user.uid),
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading notifications...'),
        error: (error, _) => EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Error',
          description: 'Failed to load notifications.',
          actionText: 'Retry',
          onAction: () => ref.invalidate(userNotificationsProvider(user.uid)),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.notifications_none,
              title: 'No Notifications',
              description: 'You don\'t have any notifications yet.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userNotificationsProvider(user.uid));
            },
            color: AppColors.gold,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMD,
                vertical: AppDimensions.spacingMD,
              ),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(
                  context,
                  ref,
                  notification,
                  index,
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ─── Notification Item ─────────────────────────────────────────────
  Widget _buildNotificationItem(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
    int index,
  ) {
    final isUnread = !notification.isRead;
    final (icon, color) = _getNotificationIcon(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimensions.spacingXL),
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingSM),
        decoration: BoxDecoration(
          color: AppColors.errorRed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: const Icon(Icons.delete, color: AppColors.white),
      ),
      onDismissed: (_) {
        ref
            .read(notificationServiceProvider)
            .deleteNotification(notification.id);
      },
      child: GestureDetector(
        onTap: () => _handleNotificationTap(context, ref, notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingSM),
          padding: const EdgeInsets.all(AppDimensions.spacingMD),
          decoration: BoxDecoration(
            color: isUnread
                ? AppColors.gold.withValues(alpha: 0.05)
                : AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: isUnread
                ? Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
            boxShadow: AppDimensions.shadowSM,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppDimensions.spacingMD),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.timeAgo(notification.createdAt),
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 60).ms).fadeIn().slideX(begin: 0.05);
  }

  // ─── Notification Icon by Type ─────────────────────────────────────
  (IconData, Color) _getNotificationIcon(String type) {
    switch (type) {
      case 'booking_new':
        return (Icons.calendar_today, AppColors.infoBlue);
      case 'booking_confirmed':
        return (Icons.check_circle, AppColors.successGreen);
      case 'booking_rejected':
        return (Icons.cancel, AppColors.errorRed);
      case 'booking_cancelled':
        return (Icons.block, AppColors.errorRed);
      case 'booking_processing':
        return (Icons.sync, AppColors.gold);
      case 'booking_completed':
        return (Icons.done_all, AppColors.successGreen);
      case 'promotion':
        return (Icons.local_offer, AppColors.accentOrange);
      case 'system':
        return (Icons.info, AppColors.infoBlue);
      default:
        return (Icons.notifications, AppColors.darkGrey);
    }
  }

  // ─── Handle Notification Tap ───────────────────────────────────────
  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) {
    // Mark as read if unread
    if (!notification.isRead) {
      ref.read(notificationServiceProvider).markAsRead(notification.id);
    }

    // Handle deep linking based on notification type and data
    final data = notification.data;
    if (data == null || data.isEmpty) return;

    // Navigate based on booking-related notifications
    if (data.containsKey('bookingId')) {
      final bookingId = data['bookingId'] as String;
      context.pushNamed('booking-detail', pathParameters: {'bookingId': bookingId});
    }
    
    // Navigate based on notification type
    switch (notification.type) {
      case 'booking_new':
      case 'booking_confirmed':
      case 'booking_processing':
      case 'booking_completed':
      case 'booking_rejected':
      case 'booking_cancelled':
        if (data.containsKey('bookingId')) {
          final bookingId = data['bookingId'] as String;
          context.pushNamed('booking-detail', pathParameters: {'bookingId': bookingId});
        } else {
          context.push(RouteNames.customerBooking);
        }
        break;
      case 'promotion':
        // Navigate to promotions or home
        context.push(RouteNames.customerHome);
        break;
      case 'system':
        // Show system info or stay on notifications
        break;
    }
  }

  // ─── Mark All as Read ──────────────────────────────────────────────
  void _markAllAsRead(WidgetRef ref, String userId) {
    ref.read(notificationServiceProvider).markAllAsRead(userId);
  }
}

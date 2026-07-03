import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../router/route_names.dart';

/// Custom AppBar with BarberBook styling.
///
/// Provides:
/// - Optional notification bell with badge counter
/// - Optional back button
/// - Centered or left-aligned title
/// - Custom action buttons
/// - Gradient background variant
///
/// Usage:
/// ```dart
/// appBar: PreferredSize(
///   preferredSize: const Size.fromHeight(kToolbarHeight),
///   child: CustomAppBar(
///     title: 'My Bookings',
///     showNotification: true,
///     unreadCount: 3,
///   ),
/// )
/// ```
class CustomAppBar extends StatelessWidget {
  /// Title text displayed in the app bar
  final String? title;

  /// Custom title widget (overrides [title] if provided)
  final Widget? titleWidget;

  /// Whether to show the back/leading button
  final bool showBackButton;

  /// Whether to show the notification bell icon
  final bool showNotification;

  /// Number of unread notifications (shown as badge on bell)
  final int unreadCount;

  /// Additional action widgets on the right side
  final List<Widget>? actions;

  /// Background color (defaults to white)
  final Color? backgroundColor;

  /// Whether to use a gradient background
  final bool useGradient;

  /// Elevation of the app bar
  final double elevation;

  /// Called when the notification bell is tapped
  final VoidCallback? onNotificationTap;

  /// Custom leading widget (overrides default back button)
  final Widget? leading;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.showNotification = false,
    this.unreadCount = 0,
    this.actions,
    this.backgroundColor,
    this.useGradient = false,
    this.elevation = 0,
    this.onNotificationTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: Theme.of(context).textTheme.titleLarge,
                )
              : null),
      centerTitle: true,
      elevation: elevation,
      backgroundColor: useGradient ? AppColors.primaryBlack : (backgroundColor ?? AppColors.white),
      foregroundColor: useGradient ? AppColors.white : AppColors.primaryBlack,

      // ─── Leading ──────────────────────────────────────────────────
      leading: leading ??
          (showBackButton
              ? IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: useGradient ? AppColors.white : AppColors.primaryBlack,
                  ),
                )
              : null),
      automaticallyImplyLeading: showBackButton,

      // ─── Actions ──────────────────────────────────────────────────
      actions: [
        // Notification bell with badge
        if (showNotification)
          Stack(
            children: [
              IconButton(
                onPressed: onNotificationTap ??
                    () => context.push(RouteNames.notifications),
                icon: Icon(
                  Icons.notifications_outlined,
                  color: useGradient ? AppColors.white : AppColors.charcoal,
                ),
              ),
              // Badge counter
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    decoration: const BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

        // Additional custom actions
        ...?actions,
      ],
    );
  }
}

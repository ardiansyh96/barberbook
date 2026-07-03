import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Empty state widget displayed when a list or screen has no data.
///
/// Shows an icon, title, optional description, and an optional action button.
///
/// Usage:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.event_busy,
///   title: 'No Bookings Yet',
///   description: 'Book a barber to get started!',
///   actionText: 'New Booking',
///   onAction: () => context.push(RouteNames.bookingCreate),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// Icon displayed at the top
  final IconData icon;

  /// Main title text
  final String title;

  /// Optional description text below the title
  final String? description;

  /// Optional action button label
  final String? actionText;

  /// Called when the action button is pressed
  final VoidCallback? onAction;

  /// Icon size
  final double iconSize;

  /// Icon color (defaults to medium grey)
  final Color? iconColor;

  /// Custom image widget (overrides [icon] if provided)
  final Widget? image;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.iconSize = 80,
    this.iconColor,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Icon or Image ──────────────────────────────────────
            image ??
                Icon(
                  icon,
                  size: iconSize,
                  color: iconColor ?? AppColors.mediumGrey.withValues(alpha: 0.6),
                ),

            const SizedBox(height: AppDimensions.spacingLG),

            // ─── Title ──────────────────────────────────────────────
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),

            // ─── Description ────────────────────────────────────────
            if (description != null) ...[
              const SizedBox(height: AppDimensions.spacingSM),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            // ─── Action Button ──────────────────────────────────────
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.spacingXXL),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlack,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXXL,
                    vertical: AppDimensions.spacingMD,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

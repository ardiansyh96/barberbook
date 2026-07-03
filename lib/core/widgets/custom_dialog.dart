import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Styled dialog helper for BarberBook.
///
/// Provides consistent dialog styling with:
/// - Custom title and content
/// - Configurable action buttons (confirm/cancel)
/// - Danger variant for destructive actions
/// - Icon support
///
/// Usage:
/// ```dart
/// CustomDialog.show(
///   context: context,
///   title: 'Cancel Booking?',
///   content: 'This action cannot be undone.',
///   confirmText: 'Yes, Cancel',
///   cancelText: 'No, Keep',
///   isDanger: true,
///   onConfirm: () => _cancelBooking(),
/// );
/// ```
class CustomDialog extends StatelessWidget {
  /// Dialog title
  final String title;

  /// Dialog body content text
  final String? content;

  /// Custom content widget (overrides [content] text)
  final Widget? contentWidget;

  /// Confirm button text
  final String confirmText;

  /// Cancel button text (null to hide cancel button)
  final String? cancelText;

  /// Called when confirm button is pressed
  final VoidCallback? onConfirm;

  /// Called when cancel button is pressed (defaults to Navigator.pop)
  final VoidCallback? onCancel;

  /// Whether this is a destructive action (red confirm button)
  final bool isDanger;

  /// Optional icon at the top of the dialog
  final IconData? icon;

  /// Icon color
  final Color? iconColor;

  const CustomDialog({
    super.key,
    required this.title,
    this.content,
    this.contentWidget,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDanger = false,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? (isDanger ? AppColors.errorRed : AppColors.gold),
              size: 24,
            ),
            const SizedBox(width: AppDimensions.spacingSM),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
      content: contentWidget ??
          (content != null
              ? Text(
                  content!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkGrey,
                      ),
                )
              : null),
      actions: [
        // Cancel button
        if (cancelText != null)
          TextButton(
            onPressed: onCancel ?? () => Navigator.pop(context),
            child: Text(
              cancelText!,
              style: TextStyle(color: AppColors.darkGrey),
            ),
          ),

        // Confirm button
        ElevatedButton(
          onPressed: () {
            if (onConfirm != null) {
              onConfirm!();
            } else {
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDanger ? AppColors.errorRed : AppColors.primaryBlack,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// Show a styled dialog using the BarberBook design.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? content,
    Widget? contentWidget,
    String confirmText = 'Confirm',
    String? cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDanger = false,
    IconData? icon,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        title: title,
        content: content,
        contentWidget: contentWidget,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDanger: isDanger,
        icon: icon,
      ),
    );
  }

  /// Show a simple confirmation dialog (Yes/No).
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
    bool isDanger = false,
    IconData? icon,
  }) async {
    final result = await show<bool>(
      context: context,
      title: title,
      content: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDanger: isDanger,
      icon: icon,
      onConfirm: () => Navigator.pop(context, true),
      onCancel: () => Navigator.pop(context, false),
    );
    return result ?? false;
  }
}

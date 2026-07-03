import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Helper class to display consistent SnackBars across the app.
///
/// Provides factory methods for success, error, warning, and info messages
/// with appropriate colors and icons.
class SnackbarHelper {
  SnackbarHelper._();

  /// Show a success snackbar with green accent
  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.successGreen, Icons.check_circle_outline);
  }

  /// Show an error snackbar with red accent
  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.errorRed, Icons.error_outline);
  }

  /// Show a warning snackbar with amber accent
  static void warning(BuildContext context, String message) {
    _show(context, message, AppColors.warningAmber, Icons.warning_amber_rounded);
  }

  /// Show an info snackbar with blue accent
  static void info(BuildContext context, String message) {
    _show(context, message, AppColors.infoBlue, Icons.info_outline);
  }

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }
}

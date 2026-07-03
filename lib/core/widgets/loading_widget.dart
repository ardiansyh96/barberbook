import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Centered loading indicator with optional message.
///
/// Use for full-screen loading or inline loading states.
///
/// Usage:
/// ```dart
/// // Full screen loading
/// if (isLoading) return const LoadingWidget();
///
/// // With message
/// LoadingWidget(message: 'Loading barbers...');
/// ```
class LoadingWidget extends StatelessWidget {
  /// Optional message displayed below the spinner
  final String? message;

  /// Size of the circular progress indicator
  final double size;

  /// Color of the spinner (defaults to gold)
  final Color? color;

  /// Whether to display as a full-screen centered widget
  final bool isFullScreen;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40,
    this.color,
    this.isFullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.gold,
        ),
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        indicator,
        if (message != null) ...[
          const SizedBox(height: AppDimensions.spacingLG),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.darkGrey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (!isFullScreen) return content;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: content,
      ),
    );
  }
}

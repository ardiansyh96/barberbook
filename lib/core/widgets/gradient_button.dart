import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// A button with a gradient background, used for premium/CTA actions.
///
/// Uses the BarberBook gold gradient by default, but can be customized
/// with any [LinearGradient].
///
/// Usage:
/// ```dart
/// GradientButton(
///   text: 'Book Now',
///   onPressed: () => _createBooking(),
///   icon: Icons.calendar_today,
/// )
/// ```
class GradientButton extends StatelessWidget {
  /// Button label text
  final String text;

  /// Called when the button is pressed
  final VoidCallback? onPressed;

  /// Optional icon displayed before the text
  final IconData? icon;

  /// Custom gradient (defaults to gold gradient)
  final LinearGradient? gradient;

  /// Whether to show a loading spinner
  final bool isLoading;

  /// Whether the button takes full width
  final bool isFullWidth;

  /// Button height
  final double height;

  /// Text color override
  final Color? textColor;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.gradient,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = AppDimensions.buttonHeightLG,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppColors.promoGradient;
    final fgColor = textColor ?? AppColors.white;

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null && !isLoading
              ? LinearGradient(
                  colors: effectiveGradient.colors
                      .map((c) => c.withValues(alpha: 0.5))
                      .toList(),
                  begin: effectiveGradient.begin,
                  end: effectiveGradient.end,
                )
              : effectiveGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: onPressed != null ? AppDimensions.shadowMD : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: fgColor, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: fgColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

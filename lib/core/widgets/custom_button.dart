import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Button variant types for [CustomButton].
enum ButtonVariant {
  /// Solid filled button (primary actions: Login, Register, Confirm)
  primary,

  /// Outlined button with border (secondary actions: Cancel, Edit Profile)
  outlined,

  /// Transparent text-only button (tertiary actions: Skip, See All)
  text,

  /// Danger/destructive button (Delete, Logout)
  danger,
}

/// Button size presets for [CustomButton].
enum ButtonSize {
  /// Small button for inline actions (height: 36)
  small,

  /// Medium button for most actions (height: 44)
  medium,

  /// Large button for primary CTAs (height: 52)
  large,

  /// Extra large button for full-width CTAs (height: 60)
  extraLarge,
}

/// Reusable button widget with multiple variants and sizes.
///
/// Supports:
/// - 4 variants: primary, outlined, text, danger
/// - 4 sizes: small, medium, large, extraLarge
/// - Leading/trailing icons
/// - Loading state with spinner
/// - Full-width option
///
/// Usage:
/// ```dart
/// CustomButton(
///   text: 'Login',
///   onPressed: () => _login(),
///   variant: ButtonVariant.primary,
///   size: ButtonSize.large,
///   isFullWidth: true,
/// )
/// ```
class CustomButton extends StatelessWidget {
  /// Button label text
  final String text;

  /// Called when the button is pressed
  final VoidCallback? onPressed;

  /// Button style variant
  final ButtonVariant variant;

  /// Button size preset
  final ButtonSize size;

  /// Icon displayed before the text
  final IconData? leadingIcon;

  /// Icon displayed after the text
  final IconData? trailingIcon;

  /// Whether to show a loading spinner instead of the content
  final bool isLoading;

  /// Whether the button should take the full available width
  final bool isFullWidth;

  /// Optional custom color override
  final Color? color;

  /// Optional child widget (overrides [text] if provided)
  final Widget? child;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.large,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.color,
    this.child,
  });

  /// Height based on size preset
  double get _height {
    switch (size) {
      case ButtonSize.small:
        return AppDimensions.buttonHeightSM;
      case ButtonSize.medium:
        return AppDimensions.buttonHeightMD;
      case ButtonSize.large:
        return AppDimensions.buttonHeightLG;
      case ButtonSize.extraLarge:
        return AppDimensions.buttonHeightXL;
    }
  }

  /// Font size based on size preset
  double get _fontSize {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 15;
      case ButtonSize.extraLarge:
        return 16;
    }
  }

  /// Icon size based on size preset
  double get _iconSize {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
      case ButtonSize.extraLarge:
        return 22;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on variant
    final bgColor = _getBackgroundColor();
    final fgColor = _getForegroundColor();
    final borderColor = _getBorderColor();

    final content = child ?? _buildContent(fgColor);

    final button = SizedBox(
      height: _height,
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          child: Container(
            decoration: borderColor != null
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: borderColor, width: 1.5),
                  )
                : null,
            padding: EdgeInsets.symmetric(
              horizontal: isFullWidth ? AppDimensions.spacingXL : AppDimensions.spacingLG,
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );

    // Disabled appearance
    if (onPressed == null && !isLoading) {
      return Opacity(opacity: 0.5, child: button);
    }

    return button;
  }

  /// Builds the button content (icon + text + icon or loading spinner)
  Widget _buildContent(Color fgColor) {
    if (isLoading) {
      return SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    }

    final textStyle = TextStyle(
      color: fgColor,
      fontSize: _fontSize,
      fontWeight: FontWeight.w600,
    );

    final children = <Widget>[];

    if (leadingIcon != null) {
      children.add(Icon(leadingIcon, color: fgColor, size: _iconSize));
      children.add(const SizedBox(width: 8));
    }

    children.add(Text(text, style: textStyle));

    if (trailingIcon != null) {
      children.add(const SizedBox(width: 8));
      children.add(Icon(trailingIcon, color: fgColor, size: _iconSize));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Color? _getBackgroundColor() {
    if (color != null) return color;
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primaryBlack;
      case ButtonVariant.outlined:
        return Colors.transparent;
      case ButtonVariant.text:
        return Colors.transparent;
      case ButtonVariant.danger:
        return AppColors.errorRed;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.white;
      case ButtonVariant.outlined:
        return color ?? AppColors.primaryBlack;
      case ButtonVariant.text:
        return color ?? AppColors.gold;
      case ButtonVariant.danger:
        return AppColors.white;
    }
  }

  Color? _getBorderColor() {
    switch (variant) {
      case ButtonVariant.outlined:
        return color ?? AppColors.gold;
      default:
        return null;
    }
  }
}

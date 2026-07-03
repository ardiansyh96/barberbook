import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Styled bottom sheet wrapper for BarberBook.
///
/// Provides a consistent bottom sheet with:
/// - Drag handle indicator
/// - Optional title header
/// - Proper padding and rounded corners
///
/// Usage:
/// ```dart
/// CustomBottomSheet.show(
///   context: context,
///   title: 'Select Filter',
///   child: FilterContent(),
/// );
/// ```
class CustomBottomSheet extends StatelessWidget {
  /// Title displayed in the header
  final String? title;

  /// Content of the bottom sheet
  final Widget child;

  /// Whether the sheet is scrollable
  final bool isScrollControlled;

  /// Padding around the content
  final EdgeInsets? padding;

  const CustomBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.isScrollControlled = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          EdgeInsets.only(
            left: AppDimensions.spacingXL,
            right: AppDimensions.spacingXL,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.spacingXL,
            top: AppDimensions.spacingSM,
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Drag Handle ───────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.mediumGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingLG),

          // ─── Title ────────────────────────────────────────────────
          if (title != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLG),
          ],

          // ─── Content ──────────────────────────────────────────────
          child,

          const SizedBox(height: AppDimensions.spacingLG),
        ],
      ),
    );
  }

  /// Show a styled bottom sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = true,
    bool isDismissible = true,
    EdgeInsets? padding,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXXL),
        ),
      ),
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight)
          : null,
      builder: (context) => CustomBottomSheet(
        title: title,
        padding: padding,
        child: child,
      ),
    );
  }
}

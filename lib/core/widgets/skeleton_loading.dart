import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Shimmer loading placeholders for various UI elements.
///
/// Provides pre-built skeleton shapes that mimic the final UI layout
/// while data is being loaded from Firestore.
///
/// Usage:
/// ```dart
/// // Card skeleton
/// SkeletonLoading.card()
///
/// // List of skeletons
/// SkeletonLoading.list(itemCount: 5)
///
/// // Custom skeleton
/// SkeletonLoading(
///   child: Container(height: 100, width: double.infinity),
/// )
/// ```
class SkeletonLoading extends StatelessWidget {
  /// The widget to apply shimmer effect to
  final Widget child;

  const SkeletonLoading({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.offWhite,
      child: child,
    );
  }

  /// Shimmer card placeholder (mimics a barber card or booking card)
  static Widget card({double height = 120}) {
    return SkeletonLoading(
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
      ),
    );
  }

  /// Shimmer circle placeholder (mimics an avatar)
  static Widget circle({double size = 48}) {
    return SkeletonLoading(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.lightGrey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// Shimmer text line placeholder
  static Widget textLine({double width = double.infinity, double height = 14}) {
    return SkeletonLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Shimmer list placeholder with multiple card items
  static Widget list({int itemCount = 3, double itemHeight = 120}) {
    return Column(
      children: List.generate(
        itemCount,
        (_) => card(height: itemHeight),
      ),
    );
  }

  /// Shimmer horizontal list placeholder (mimics top barbers section)
  static Widget horizontalList({
    int itemCount = 4,
    double itemWidth = 140,
    double itemHeight = 180,
  }) {
    return SkeletonLoading(
      child: SizedBox(
        height: itemHeight,
        child: Row(
          children: List.generate(
            itemCount,
            (index) => Container(
              width: itemWidth,
              height: itemHeight,
              margin: EdgeInsets.only(
                right: index < itemCount - 1 ? AppDimensions.spacingMD : 0,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shimmer grid placeholder (mimics services grid)
  static Widget grid({
    int crossAxisCount = 2,
    int itemCount = 4,
    double childAspectRatio = 1.4,
  }) {
    return SkeletonLoading(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppDimensions.spacingMD,
          mainAxisSpacing: AppDimensions.spacingMD,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
      ),
    );
  }

  /// Shimmer banner placeholder (mimics promo banner)
  static Widget banner() {
    return SkeletonLoading(
      child: Container(
        height: AppDimensions.bannerHeight,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppDimensions.bannerBorderRadius),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Wrapper around [CachedNetworkImage] with consistent placeholder and
/// error handling for BarberBook.
///
/// Features:
/// - Shimmer-style placeholder while loading
/// - Graceful error fallback with icon
/// - Configurable border radius and fit
/// - Cache management support
///
/// Usage:
/// ```dart
/// CachedImage(
///   imageUrl: barber.photoUrl,
///   width: 80,
///   height: 80,
///   borderRadius: 40, // circle
/// )
/// ```
class CachedImage extends StatelessWidget {
  /// URL of the image to load
  final String? imageUrl;

  /// Width of the image container
  final double? width;

  /// Height of the image container
  final double? height;

  /// Border radius (use large value for circle)
  final double borderRadius;

  /// How the image should be inscribed into the box
  final BoxFit fit;

  /// Fallback icon when URL is null or loading fails
  final IconData fallbackIcon;

  /// Whether to show a border around the image
  final bool showBorder;

  /// Border color
  final Color? borderColor;

  /// Background color for placeholder
  final Color? placeholderColor;

  const CachedImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.person,
    this.showBorder = false,
    this.borderColor,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    // If no URL, show fallback
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,

        // ─── Loading Placeholder ────────────────────────────────────
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: placeholderColor ?? AppColors.lightGrey,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.gold.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),

        // ─── Error Placeholder ──────────────────────────────────────
        errorWidget: (context, url, error) => _buildFallback(),

        // ─── Image Decoration ───────────────────────────────────────
        imageBuilder: (context, imageProvider) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
            border: showBorder
                ? Border.all(
                    color: borderColor ?? AppColors.lightGrey,
                    width: 1,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  /// Fallback widget when image fails to load or URL is null
  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: placeholderColor ?? AppColors.lightGrey,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.lightGrey,
                width: 1,
              )
            : null,
      ),
      child: Icon(
        fallbackIcon,
        color: AppColors.mediumGrey,
        size: (width != null && height != null)
            ? (width! < height! ? width! : height!) * 0.4
            : AppDimensions.iconXXL,
      ),
    );
  }
}

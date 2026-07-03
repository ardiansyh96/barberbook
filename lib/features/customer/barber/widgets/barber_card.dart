import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../models/barber_model.dart';

/// Reusable card widget for displaying a barber in list views.
///
/// Shows:
/// - Barber photo (from Firebase Storage) or placeholder avatar
/// - Name and specialty
/// - Rating with star icon and review count
/// - Experience years badge
/// - Online/availability status
///
/// Tap to navigate to barber detail screen.
class BarberCard extends StatelessWidget {
  final BarberModel barber;
  final VoidCallback? onTap;

  /// Whether to show in compact horizontal layout (for search results)
  /// or full vertical card layout (for list)
  final bool isCompact;

  const BarberCard({
    super.key,
    required this.barber,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) return _buildCompactCard(context);
    return _buildFullCard(context);
  }

  /// Full vertical card for list view
  Widget _buildFullCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: AppDimensions.shadowSM,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMD),
          child: Row(
            children: [
              // Barber photo or placeholder
              _buildAvatar(),
              const SizedBox(width: AppDimensions.spacingMD),

              // Name, specialty, rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barber.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      barber.spesialis,
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Rating
                        const Icon(
                          Icons.star,
                          color: AppColors.starFilled,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          Formatters.rating(barber.rating),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          ' (${barber.totalReviews})',
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingMD),
                        // Experience badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${barber.pengalaman} thn',
                            style: const TextStyle(
                              color: AppColors.goldDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              const Icon(
                Icons.chevron_right,
                color: AppColors.mediumGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact horizontal card for search results
  Widget _buildCompactCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: AppDimensions.spacingMD),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: AppDimensions.shadowSM,
        ),
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.spacingMD),
            // Barber photo or placeholder
            _buildAvatar(radius: 36),
            const SizedBox(height: AppDimensions.spacingSM),
            Text(
              barber.nama,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              barber.spesialis,
              style: TextStyle(
                color: AppColors.darkGrey,
                fontSize: 11,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: AppColors.starFilled, size: 14),
                const SizedBox(width: 2),
                Text(
                  Formatters.rating(barber.rating),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMD),
          ],
        ),
      ),
    );
  }

  /// Barber avatar - shows photo from Firestore or placeholder icon
  Widget _buildAvatar({double radius = 30}) {
    if (barber.foto != null && barber.foto!.isNotEmpty) {
      return CachedImage(
        imageUrl: barber.foto!,
        width: radius * 2,
        height: radius * 2,
        borderRadius: radius,
        fit: BoxFit.cover,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.lightGrey,
      child: const Icon(
        Icons.person,
        size: 32,
        color: AppColors.mediumGrey,
      ),
    );
  }
}

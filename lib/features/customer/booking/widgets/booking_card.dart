import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../models/booking_model.dart';

/// Reusable booking card widget for displaying booking information.
///
/// Shows:
/// - Barber photo and name
/// - Service name
/// - Date and time
/// - Status badge (color-coded by status)
/// - Total price
/// - Optional action button (e.g., Cancel, Rate)
///
/// Status colors:
/// - Pending: Amber/Warning
/// - Confirmed: Blue/Info
/// - Processing: Gold/Primary
/// - Completed: Green/Success
/// - Rejected/Cancelled: Red/Error
class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final String? actionLabel;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
        padding: const EdgeInsets.all(AppDimensions.spacingLG),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: AppDimensions.shadowSM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: Barber Info + Status ──────────────────────────
            Row(
              children: [
                // Barber photo or placeholder
                _buildBarberAvatar(),
                const SizedBox(width: AppDimensions.spacingMD),

                // Barber name and service
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.barberNama ?? 'Barber',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.serviceNama ?? 'Service',
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                _buildStatusBadge(),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingMD),
            const Divider(height: 1),
            const SizedBox(height: AppDimensions.spacingMD),

            // ─── Details Row: Date/Time + Price ───────────────────────
            Row(
              children: [
                // Date
                _buildInfoChip(
                  icon: Icons.calendar_today,
                  text: Formatters.dateShort(booking.tanggal),
                ),
                const SizedBox(width: AppDimensions.spacingSM),

                // Time
                _buildInfoChip(
                  icon: Icons.schedule,
                  text: Formatters.time12h(booking.jam),
                ),

                const Spacer(),

                // Price
                Text(
                  Formatters.currency(booking.totalHarga),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ],
            ),

            // ─── Action Button (if applicable) ────────────────────────
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppDimensions.spacingMD),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _getActionColor(),
                    side: BorderSide(color: _getActionColor()),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Barber Avatar ─────────────────────────────────────────────────
  Widget _buildBarberAvatar() {
    if (booking.barberFoto != null && booking.barberFoto!.isNotEmpty) {
      return CachedImage(
        imageUrl: booking.barberFoto!,
        width: 48,
        height: 48,
        borderRadius: 24,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        color: AppColors.gold,
        size: 24,
      ),
    );
  }

  // ─── Status Badge ──────────────────────────────────────────────────
  Widget _buildStatusBadge() {
    final (color, icon, label) = _getStatusInfo(booking.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Info Chip (Date/Time) ─────────────────────────────────────────
  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.darkGrey),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Status Color/Icon/Label Mapping ───────────────────────────────
  (Color, IconData, String) _getStatusInfo(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return (AppColors.warningAmber, Icons.hourglass_empty, 'Pending');
      case AppConstants.statusConfirmed:
        return (AppColors.infoBlue, Icons.check_circle_outline, 'Confirmed');
      case AppConstants.statusProcessing:
        return (AppColors.gold, Icons.sync, 'Processing');
      case AppConstants.statusCompleted:
        return (AppColors.successGreen, Icons.done_all, 'Completed');
      case AppConstants.statusRejected:
        return (AppColors.errorRed, Icons.cancel_outlined, 'Rejected');
      case AppConstants.statusCancelled:
        return (AppColors.errorRed, Icons.block, 'Cancelled');
      default:
        return (AppColors.darkGrey, Icons.help_outline, status);
    }
  }

  // ─── Action Button Color ───────────────────────────────────────────
  Color _getActionColor() {
    if (actionLabel == 'Cancel') return AppColors.errorRed;
    if (actionLabel == 'Rate') return AppColors.starFilled;
    return AppColors.primaryBlack;
  }
}

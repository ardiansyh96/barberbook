import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../booking/models/booking_model.dart';
import '../../booking/providers/booking_provider.dart';

/// Booking Detail screen showing complete booking information.
///
/// Features:
/// - Full booking details (barber, service, date, time, price)
/// - Booking status with color-coded badge
/// - Cancel booking action (for pending/confirmed status)
/// - Leave review action (for completed status)
/// - Barber photo and contact info
/// - Service details with duration
/// - Timeline of booking status
class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingByIdProvider(bookingId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Booking Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(bookingByIdProvider(bookingId)),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.errorRed),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(bookingByIdProvider(bookingId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (booking) {
          if (booking == null) {
            return const Center(child: Text('Booking not found'));
          }
          return _buildContent(context, ref, booking);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, BookingModel booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Center(
            child: _buildStatusBadge(booking.status),
          ).animate().scale(),
          const SizedBox(height: AppDimensions.spacingXL),

          // Booking ID & Date
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingLG),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: AppDimensions.shadowSM,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_number, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Text(
                      'Booking ID',
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  booking.id.length > 8
                      ? '${booking.id.substring(0, 8)}...'
                      : booking.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.dateShort(booking.tanggal),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.jam,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Created',
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.timeAgo(booking.createdAt),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1),

          const SizedBox(height: AppDimensions.spacingLG),

          // Barber Info
          _buildInfoCard(
            title: 'Barber',
            icon: Icons.person,
            child: Row(
              children: [
                if (booking.barberFoto != null) ...[
                  CachedImage(
                    imageUrl: booking.barberFoto!,
                    width: 56,
                    height: 56,
                    borderRadius: 28,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: AppDimensions.spacingMD),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.barberNama ?? 'Unknown Barber',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Professional Barber',
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),

          const SizedBox(height: AppDimensions.spacingLG),

          // Service Info
          _buildInfoCard(
            title: 'Service',
            icon: Icons.content_cut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.serviceNama ?? 'Unknown Service',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.darkGrey),
                    const SizedBox(width: 4),
                    Text(
                      'Duration: ${booking.totalHarga ~/ 1000} minutes',
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),

          const SizedBox(height: AppDimensions.spacingLG),

          // Price
          _buildInfoCard(
            title: 'Payment',
            icon: Icons.payments,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Price',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.darkGrey,
                  ),
                ),
                Text(
                  Formatters.currency(booking.totalHarga),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ],
            ),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),

          if (booking.catatan != null && booking.catatan!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingLG),
            _buildInfoCard(
              title: 'Notes',
              icon: Icons.note,
              child: Text(
                booking.catatan!,
                style: const TextStyle(fontSize: 14),
              ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1),
          ],

          const SizedBox(height: AppDimensions.spacingXXL),

          // Action Buttons
          _buildActionButtons(context, ref, booking),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLG),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppDimensions.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    BookingModel booking,
  ) {
    final user = ref.watch(authStateProvider).whenOrNull(data: (u) => u);
    if (user == null) return const SizedBox.shrink();

    final canCancel = booking.status == AppConstants.statusPending ||
        booking.status == AppConstants.statusConfirmed;

    final canReview = booking.status == AppConstants.statusCompleted;

    if (!canCancel && !canReview) return const SizedBox.shrink();

    return Column(
      children: [
        if (canCancel)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _cancelBooking(context, ref, booking),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Booking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        if (canReview) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.pushNamed(
                'rating',
                pathParameters: {'bookingId': booking.id},
              ),
              icon: const Icon(Icons.star),
              label: const Text('Leave a Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _cancelBooking(
    BuildContext context,
    WidgetRef ref,
    BookingModel booking,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: Text(
          'Are you sure you want to cancel your booking with ${booking.barberNama}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Keep'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(bookingServiceProvider).cancelBooking(booking.id);
        if (context.mounted) {
          SnackbarHelper.success(context, 'Booking cancelled successfully');
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          SnackbarHelper.error(context, e.toString());
        }
      }
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case AppConstants.statusPending:
        color = AppColors.warningAmber;
        icon = Icons.schedule;
        label = 'Pending';
        break;
      case AppConstants.statusConfirmed:
        color = AppColors.infoBlue;
        icon = Icons.check_circle;
        label = 'Confirmed';
        break;
      case AppConstants.statusProcessing:
        color = AppColors.gold;
        icon = Icons.sync;
        label = 'Processing';
        break;
      case AppConstants.statusCompleted:
        color = AppColors.successGreen;
        icon = Icons.done_all;
        label = 'Completed';
        break;
      case AppConstants.statusCancelled:
        color = AppColors.errorRed;
        icon = Icons.cancel;
        label = 'Cancelled';
        break;
      case AppConstants.statusRejected:
        color = AppColors.errorRed;
        icon = Icons.block;
        label = 'Rejected';
        break;
      default:
        color = AppColors.darkGrey;
        icon = Icons.help;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

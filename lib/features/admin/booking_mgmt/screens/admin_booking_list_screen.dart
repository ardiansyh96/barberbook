import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../customer/booking/models/booking_model.dart';
import '../providers/admin_booking_provider.dart';
import 'admin_booking_detail_screen.dart';

/// Admin booking management screen showing all bookings with status actions.
///
/// Features:
/// - Tab-based filtering by status (All, Pending, Confirmed, Processing, Completed, Rejected, Cancelled)
/// - Status update actions (confirm, process, complete, reject)
/// - Real-time booking list from Firestore
/// - Booking detail dialog
class AdminBookingListScreen extends ConsumerStatefulWidget {
  const AdminBookingListScreen({super.key});

  @override
  ConsumerState<AdminBookingListScreen> createState() => _AdminBookingListScreenState();
}

class _AdminBookingListScreenState extends ConsumerState<AdminBookingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _statuses = ['All', 'Pending', 'Confirmed', 'Processing', 'Completed', 'Rejected', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(adminBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(adminBookingsProvider)),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.darkGrey,
          tabAlignment: TabAlignment.start,
          tabs: _statuses.map((s) => Tab(text: s)).toList(),
        ),
      ),
      body: bookingsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading bookings...'),
        error: (_, _) => const EmptyStateWidget(icon: Icons.error_outline, title: 'Error loading bookings'),
        data: (bookings) => TabBarView(
          controller: _tabController,
          children: _statuses.map((status) {
            final filtered = status == 'All'
                ? bookings
                : bookings.where((b) => b.status.toLowerCase() == status.toLowerCase()).toList();

            if (filtered.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.book_online,
                title: status == 'All' ? 'No Bookings Yet' : 'No $status Bookings',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.spacingXL),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _buildBookingCard(filtered[index], index),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking, int index) {
    final statusColor = _getStatusColor(booking.status);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminBookingDetailScreen(
              bookingId: booking.id,
            ),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(
          bottom: AppDimensions.spacingMD,
        ),
        padding: const EdgeInsets.all(
          AppDimensions.spacingLG,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLG,
          ),
          boxShadow: AppDimensions.shadowSM,
        ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: status + date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${Formatters.dateShort(booking.tanggal)} - ${booking.jam}',
                style: const TextStyle(color: AppColors.darkGrey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSM),

          // Customer & Barber
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: AppColors.darkGrey),
              const SizedBox(width: 4),
              Text(booking.customerNama ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.content_cut, size: 16, color: AppColors.darkGrey),
              const SizedBox(width: 4),
              Text(booking.barberNama ?? 'Barber'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.miscellaneous_services, size: 16, color: AppColors.darkGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(booking.serviceNama ?? 'Service'),
              ),
              Text(Formatters.currency(booking.totalHarga),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold)),
            ],
          ),

          if (booking.catatan != null && booking.catatan!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Note: ${booking.catatan}', style: const TextStyle(color: AppColors.darkGrey, fontSize: 12, fontStyle: FontStyle.italic)),
          ],

          // Actions
          if (_canUpdateStatus(booking.status)) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildStatusActions(booking),
            ),
          ],
        ],
      ),
      )
    ).animate(delay: (index * 60).ms).fadeIn();
  }

  bool _canUpdateStatus(String status) {
    return [AppConstants.statusPending, AppConstants.statusConfirmed, AppConstants.statusProcessing].contains(status);
  }

  List<Widget> _buildStatusActions(BookingModel booking) {
    final actions = <Widget>[];

    if (booking.status == AppConstants.statusPending) {
      actions.add(_actionButton('Reject', AppColors.errorRed, () => _updateStatus(booking.id, AppConstants.statusRejected)));
      actions.add(const SizedBox(width: 8));
      actions.add(_actionButton('Confirm', AppColors.successGreen, () => _updateStatus(booking.id, AppConstants.statusConfirmed)));
    }

    if (booking.status == AppConstants.statusConfirmed) {
      actions.add(_actionButton('Start', AppColors.infoBlue, () => _updateStatus(booking.id, AppConstants.statusProcessing)));
    }

    if (booking.status == AppConstants.statusProcessing) {
      actions.add(_actionButton('Complete', AppColors.successGreen, () => _updateStatus(booking.id, AppConstants.statusCompleted)));
    }

    return actions;
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  Future<void> _updateStatus(String bookingId, String newStatus) async {
    try {
      await ref.read(adminBookingServiceProvider).updateBookingStatus(bookingId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking $newStatus'), backgroundColor: AppColors.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warningAmber;
      case 'confirmed':
        return AppColors.infoBlue;
      case 'processing':
        return AppColors.accentOrange;
      case 'completed':
        return AppColors.successGreen;
      case 'rejected':
      case 'cancelled':
        return AppColors.errorRed;
      default:
        return AppColors.darkGrey;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';

/// Booking History screen showing all customer bookings with status filtering.
///
/// Features:
/// - Tab-based filtering: All, Pending, Confirmed, Processing, Completed, Cancelled
/// - Real-time data from Firestore via Riverpod providers
/// - Pull-to-refresh to reload data
/// - Cancel booking action for pending/confirmed bookings
/// - Empty state for each tab when no bookings exist
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab definitions with corresponding status filters
  final _tabs = const [
    {'label': 'All', 'status': ''},
    {'label': 'Pending', 'status': AppConstants.statusPending},
    {'label': 'Confirmed', 'status': AppConstants.statusConfirmed},
    {'label': 'Processing', 'status': AppConstants.statusProcessing},
    {'label': 'Completed', 'status': AppConstants.statusCompleted},
    {'label': 'Cancelled', 'status': AppConstants.statusCancelled},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Trigger rebuild when tab changes
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).whenOrNull(data: (u) => u);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view bookings')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.darkGrey,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t['label'])).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          final status = tab['status']!;
          return status.isEmpty
              ? _buildAllBookings(user.uid)
              : _buildFilteredBookings(user.uid, status);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.bookingCreate),
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.gold,
        icon: const Icon(Icons.add),
        label: const Text('New Booking', style: TextStyle(fontWeight: FontWeight.w600)),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5),
    );
  }

  /// Build list showing ALL bookings for the user
  Widget _buildAllBookings(String userId) {
    final bookingsAsync = ref.watch(customerBookingsProvider(userId));

    return bookingsAsync.when(
      loading: () => const LoadingWidget(message: 'Loading bookings...'),
      error: (error, _) => _buildErrorState(error.toString()),
      data: (bookings) => _buildBookingList(bookings, 'All'),
    );
  }

  /// Build list showing bookings filtered by specific status
  Widget _buildFilteredBookings(String userId, String status) {
    final bookingsAsync = ref.watch(
      customerBookingsByStatusProvider((customerId: userId, status: status)),
    );

    return bookingsAsync.when(
      loading: () => const LoadingWidget(message: 'Loading bookings...'),
      error: (error, _) => _buildErrorState(error.toString()),
      data: (bookings) => _buildBookingList(bookings, status),
    );
  }

  /// Build the actual booking list with pull-to-refresh
  Widget _buildBookingList(List<BookingModel> bookings, String status) {
    if (bookings.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(customerBookingsProvider);
      },
      color: AppColors.gold,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingCard(
            booking: booking,
            onTap: () => _navigateToDetail(booking),
            onAction: _getActionForBooking(booking),
            actionLabel: _getActionLabel(booking),
          ).animate(delay: (index * 80).ms).fadeIn().slideX(begin: 0.1);
        },
      ),
    );
  }

  /// Empty state widget for when there are no bookings
  Widget _buildEmptyState(String status) {
    final isAllTab = status.isEmpty || status == 'All';

    return EmptyStateWidget(
      icon: _getEmptyStateIcon(status),
      title: isAllTab ? 'No Bookings Yet' : 'No $status Bookings',
      description: isAllTab
          ? 'Book your first appointment with our barbers!'
          : 'You don\'t have any $status bookings.',
      actionText: isAllTab ? 'Book Now' : null,
      onAction: isAllTab
          ? () => context.push(RouteNames.bookingCreate)
          : null,
    );
  }

  /// Error state widget
  Widget _buildErrorState(String error) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: 'Oops!',
      description: 'Something went wrong: $error',
      actionText: 'Retry',
      onAction: () => setState(() {}),
    );
  }

  /// Get appropriate icon for empty state based on status
  IconData _getEmptyStateIcon(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return Icons.hourglass_empty;
      case AppConstants.statusConfirmed:
        return Icons.event_available;
      case AppConstants.statusProcessing:
        return Icons.sync;
      case AppConstants.statusCompleted:
        return Icons.check_circle_outline;
      case AppConstants.statusCancelled:
      case AppConstants.statusRejected:
        return Icons.cancel_outlined;
      default:
        return Icons.calendar_month_outlined;
    }
  }

  /// Navigate to booking detail
  void _navigateToDetail(BookingModel booking) {
    context.pushNamed('booking-detail', pathParameters: {'bookingId': booking.id});
  }

  /// Get action callback based on booking status
  VoidCallback? _getActionForBooking(BookingModel booking) {
    if (booking.status == AppConstants.statusPending ||
        booking.status == AppConstants.statusConfirmed) {
      return () => _cancelBooking(booking);
    }
    return null;
  }

  /// Get action button label based on booking status
  String? _getActionLabel(BookingModel booking) {
    if (booking.status == AppConstants.statusPending ||
        booking.status == AppConstants.statusConfirmed) {
      return 'Cancel';
    }
    return null;
  }

  /// Cancel a booking with confirmation dialog
  Future<void> _cancelBooking(BookingModel booking) async {
    final confirmed = await _showCancelConfirmation();
    if (!confirmed || !mounted) return;

    try {
      await ref.read(bookingServiceProvider).cancelBooking(booking.id);
      ref.invalidate(customerBookingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking cancelled successfully'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
          ),
        );
      }
    }
  }

  /// Show confirmation dialog before cancelling
  Future<bool> _showCancelConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            ),
            title: const Text('Cancel Booking?'),
            content: const Text(
              'Are you sure you want to cancel this booking? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep Booking'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Cancel Booking'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

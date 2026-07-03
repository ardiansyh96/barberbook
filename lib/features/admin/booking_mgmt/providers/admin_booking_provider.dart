import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/admin_booking_service.dart';
import '../../../customer/booking/models/booking_model.dart';

/// =======================================================
/// SERVICE
/// =======================================================

final adminBookingServiceProvider =
    Provider<AdminBookingService>((ref) {
  return AdminBookingService();
});

/// =======================================================
/// ALL BOOKINGS
/// =======================================================

final adminBookingsProvider =
    StreamProvider<List<BookingModel>>((ref) {
  return ref
      .watch(adminBookingServiceProvider)
      .getAllBookings();
});

/// =======================================================
/// BOOKING DETAIL
/// =======================================================

final adminBookingDetailProvider =
    FutureProvider.family<BookingModel?, String>((ref, bookingId) {
  return ref
      .watch(adminBookingServiceProvider)
      .getBookingById(bookingId);
});

/// =======================================================
/// PENDING BOOKINGS
/// =======================================================

final pendingBookingsProvider =
    StreamProvider<List<BookingModel>>((ref) {
  return ref
      .watch(adminBookingServiceProvider)
      .getAllBookings()
      .map(
        (list) => list
            .where((e) => e.status.toLowerCase() == "pending")
            .toList(),
      );
});

/// =======================================================
/// CONFIRMED BOOKINGS
/// =======================================================

final confirmedBookingsProvider =
    StreamProvider<List<BookingModel>>((ref) {
  return ref
      .watch(adminBookingServiceProvider)
      .getAllBookings()
      .map(
        (list) => list
            .where((e) => e.status.toLowerCase() == "confirmed")
            .toList(),
      );
});

/// =======================================================
/// PROCESSING BOOKINGS
/// =======================================================

final processingBookingsProvider =
    StreamProvider<List<BookingModel>>((ref) {
  return ref
      .watch(adminBookingServiceProvider)
      .getAllBookings()
      .map(
        (list) => list
            .where((e) => e.status.toLowerCase() == "processing")
            .toList(),
      );
});

/// =======================================================
/// COMPLETED BOOKINGS
/// =======================================================

final completedBookingsProvider =
    StreamProvider<List<BookingModel>>((ref) {
  return ref
      .watch(adminBookingServiceProvider)
      .getAllBookings()
      .map(
        (list) => list
            .where((e) => e.status.toLowerCase() == "completed")
            .toList(),
      );
});
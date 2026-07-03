import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';

/// Provider for booking service singleton
final bookingServiceProvider = Provider<BookingService>((ref) => BookingService());

/// Provider that streams customer's bookings
final customerBookingsProvider = StreamProvider.family<List<BookingModel>, String>((ref, customerId) {
  final service = ref.watch(bookingServiceProvider);
  return service.getCustomerBookings(customerId);
});

/// Provider that streams customer's bookings filtered by status
final customerBookingsByStatusProvider = StreamProvider.family<List<BookingModel>, ({String customerId, String status})>((ref, params) {
  final service = ref.watch(bookingServiceProvider);
  return service.getCustomerBookingsByStatus(params.customerId, params.status);
});

/// Provider that streams all bookings (admin)
final allBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final service = ref.watch(bookingServiceProvider);
  return service.getAllBookings();
});

/// Provider for a single booking by ID
final bookingByIdProvider = FutureProvider.family<BookingModel?, String>((ref, bookingId) {
  final service = ref.watch(bookingServiceProvider);
  return service.getBookingById(bookingId);
});

/// Provider for available time slots
final availableTimeSlotsProvider = FutureProvider.family<List<String>, ({String barberId, DateTime tanggal, String jamMasuk, String jamPulang})>((ref, params) {
  final service = ref.watch(bookingServiceProvider);
  return service.getAvailableTimeSlots(
    barberId: params.barberId,
    tanggal: params.tanggal,
    jamMasuk: params.jamMasuk,
    jamPulang: params.jamPulang,
  );
});

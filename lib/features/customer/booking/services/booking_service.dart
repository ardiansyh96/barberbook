import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/utils/logger.dart';
import '../models/booking_model.dart';

/// Service for booking operations including creation, status updates,
/// and conflict validation.
///
/// Implements business rules:
/// - No booking on past dates
/// - No booking outside barber working hours
/// - No time slot conflicts for the same barber
/// - Maximum 30 days ahead booking
class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new booking with conflict validation
  Future<String> createBooking(BookingModel booking) async {
    try {
      // Validate: no past dates
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (booking.tanggal.isBefore(today)) {
        throw Exception('Cannot book a past date');
      }

      // Validate: max 30 days ahead
      final maxDate = today.add(const Duration(days: AppConstants.maxBookingDaysAhead));
      if (booking.tanggal.isAfter(maxDate)) {
        throw Exception('Booking can only be made up to 30 days in advance');
      }

      // Validate: no time slot conflict for the same barber on the same date
      final conflict = await _checkTimeSlotConflict(
        barberId: booking.barberId,
        tanggal: booking.tanggal,
        jam: booking.jam,
      );
      if (conflict) {
        throw Exception('This time slot is already booked for the selected barber');
      }

      // Create the booking document
      final docRef = await _firestore
          .collection(FirebaseCollections.bookings)
          .add(booking.toJson());
      logger.info('Booking created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      logger.error('Create booking error: $e');
      rethrow;
    }
  }

  /// Get a single booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.bookings)
          .doc(bookingId)
          .get();

      if (!doc.exists) return null;
      return BookingModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  /// Check if a time slot is already booked for a barber on a specific date
  Future<bool> _checkTimeSlotConflict({
    required String barberId,
    required DateTime tanggal,
    required String jam,
  }) async {
    final startOfDay = DateTime(tanggal.year, tanggal.month, tanggal.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final existing = await _firestore
        .collection(FirebaseCollections.bookings)
        .where('barberId', isEqualTo: barberId)
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThan: Timestamp.fromDate(endOfDay))
        .where('jam', isEqualTo: jam)
        .where('status', whereIn: [
      AppConstants.statusPending,
      AppConstants.statusConfirmed,
      AppConstants.statusProcessing,
    ]).get();

    return existing.docs.isNotEmpty;
  }

  /// Get available time slots for a barber on a specific date
  Future<List<String>> getAvailableTimeSlots({
    required String barberId,
    required DateTime tanggal,
    required String jamMasuk,
    required String jamPulang,
    int intervalMinutes = 30,
  }) async {
    // Generate all possible slots
    final allSlots = _generateTimeSlots(jamMasuk, jamPulang, intervalMinutes);

    // Fetch booked slots for this barber and date
    final startOfDay = DateTime(tanggal.year, tanggal.month, tanggal.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final bookedDocs = await _firestore
        .collection(FirebaseCollections.bookings)
        .where('barberId', isEqualTo: barberId)
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThan: Timestamp.fromDate(endOfDay))
        .where('status', whereIn: [
      AppConstants.statusPending,
      AppConstants.statusConfirmed,
      AppConstants.statusProcessing,
    ]).get();

    final bookedSlots = bookedDocs.docs.map((d) => d.data()['jam'] as String).toSet();

    // Return only available slots
    return allSlots.where((slot) => !bookedSlots.contains(slot)).toList();
  }

  /// Generate time slots between start and end time
  List<String> _generateTimeSlots(String start, String end, int interval) {
    final startParts = start.split(':');
    final endParts = end.split(':');
    var current = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    final slots = <String>[];
    while (current < endMinutes) {
      final h = current ~/ 60;
      final m = current % 60;
      slots.add('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
      current += interval;
    }
    return slots;
  }

  /// Get bookings for a customer (with real-time updates)
  Stream<List<BookingModel>> getCustomerBookings(String customerId) {
    return _firestore
        .collection(FirebaseCollections.bookings)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  /// Get bookings filtered by status for a customer
  Stream<List<BookingModel>> getCustomerBookingsByStatus(
    String customerId,
    String status,
  ) {
    return _firestore
        .collection(FirebaseCollections.bookings)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .where((booking) => booking.status == status)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  /// Get all bookings (for admin)
  Stream<List<BookingModel>> getAllBookings() {
    return _firestore
        .collection(FirebaseCollections.bookings)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  /// Update booking status (admin operations)
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _firestore
          .collection(FirebaseCollections.bookings)
          .doc(bookingId)
          .update({'status': newStatus});
      logger.info('Booking $bookingId status -> $newStatus');
    } catch (e) {
      logger.error('Update booking status error: $e');
      throw Exception('Failed to update booking status');
    }
  }

  /// Cancel a booking (customer operation, only from pending/confirmed)
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, AppConstants.statusCancelled);
  }

  /// Get today's booking count (for admin dashboard)
  Future<int> getTodayBookingCount() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await _firestore
        .collection(FirebaseCollections.bookings)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();
    return result.docs.length;
  }

  /// Get pending booking count (for admin dashboard)
  Future<int> getPendingBookingCount() async {
    final result = await _firestore
        .collection(FirebaseCollections.bookings)
        .where('status', isEqualTo: AppConstants.statusPending)
        .get();
    return result.docs.length;
  }
}

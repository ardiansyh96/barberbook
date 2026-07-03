import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/utils/logger.dart';
import '../../../customer/booking/models/booking_model.dart';
import '../../../customer/notification/services/notification_service.dart';

class AdminBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final NotificationService _notificationService =
    NotificationService();

  /// ============================================================
  /// GET ALL BOOKINGS
  /// ============================================================

  Stream<List<BookingModel>> getAllBookings() {
    return _firestore
        .collection(FirebaseCollections.bookings)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((e) => BookingModel.fromFirestore(e))
              .toList(),
        );
  }

  /// ============================================================
  /// GET BOOKING DETAIL
  /// ============================================================

  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.bookings)
          .doc(bookingId)
          .get();

      if (!doc.exists) return null;

      return BookingModel.fromFirestore(doc);
    } catch (e) {
      logger.error("Get Booking Detail Error : $e");
      return null;
    }
  }

  /// ============================================================
  /// UPDATE STATUS
  /// ============================================================

  Future<void> updateBookingStatus(
  String bookingId,
  String newStatus,
  ) async {
    final bookingRef =
        FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId);

    final booking =
        await bookingRef.get();

    if (!booking.exists) {
      throw Exception("Booking tidak ditemukan");
    }

    final data =
        booking.data()!;

    await bookingRef.update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    await _notificationService.sendBookingStatus(
      userId: data['customerId'],
      bookingId: bookingId,
      status: newStatus,
    );

      logger.info("Booking berhasil diupdate menjadi $newStatus");
  }

  /// ============================================================
  /// CONFIRM
  /// ============================================================

  Future<void> confirmBooking(String bookingId) async {
    await updateBookingStatus(
      bookingId,
      AppConstants.statusConfirmed,
    );
  }

  /// ============================================================
  /// START
  /// ============================================================

  Future<void> startBooking(String bookingId) async {
    await updateBookingStatus(
      bookingId,
      AppConstants.statusProcessing,
    );
  }

  /// ============================================================
  /// COMPLETE
  /// ============================================================

  Future<void> completeBooking(String bookingId) async {
    await updateBookingStatus(
      bookingId,
      AppConstants.statusCompleted,
    );
  }

  /// ============================================================
  /// CANCEL
  /// ============================================================

  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(
      bookingId,
      AppConstants.statusCancelled,
    );
  }

  /// ============================================================
  /// REJECT
  /// ============================================================

  Future<void> rejectBooking(
    String bookingId,
    String reason,
  ) async {
    try {
      await _firestore
          .collection(FirebaseCollections.bookings)
          .doc(bookingId)
          .update({
        'status': AppConstants.statusRejected,
        'rejectReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      logger.info("Booking Rejected");
    } catch (e) {
      logger.error(e.toString());
      rethrow;
    }
  }

  /// ============================================================
  /// DELETE
  /// ============================================================

  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.bookings)
          .doc(bookingId)
          .delete();

      logger.info("Booking Deleted");
    } catch (e) {
      logger.error(e.toString());
      rethrow;
    }
  }
}
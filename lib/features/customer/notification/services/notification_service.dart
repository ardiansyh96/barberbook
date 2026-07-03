import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/utils/logger.dart';
import '../models/notification_model.dart';

/// Service for managing notifications in Firestore.
///
/// Provides CRUD operations for the notifications collection,
/// including read/unread tracking and batch operations.
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getCustomerIds() async {
  final snapshot = await _firestore
      .collection(FirebaseCollections.users)
      .where('role', isEqualTo: 'customer')
      .get();

  return snapshot.docs.map((e) => e.id).toList();
}

Future<List<String>> getCustomerTokens() async {

    final snapshot = await _firestore
        .collection(FirebaseCollections.users)
        .where('role', isEqualTo: 'customer')
        .get();

    return snapshot.docs

        .map((e) => e.data()['fcmToken'] as String?)

        .where((e) => e != null)

        .cast<String>()

        .toList();

  }

  Future<void> notifyCustomer({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: type,
      data: data,
    );
  }

  Future<void> sendBookingStatus({
    required String userId,
    required String bookingId,
    required String status,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Status Booking',
      body: 'Status booking kamu berubah menjadi $status',
      type: 'booking',
      data: {
        'bookingId': bookingId,
        'status': status,
      },
    );
  }

  Future<void> clearAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final notificationsSnapshot = await _firestore
          .collection(FirebaseCollections.notifications)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in notificationsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      logger.info('Cleared all notifications for user: $userId');
    } catch (e) {
      logger.error('Clear all notifications error: $e');
    }
  }

  /// Create a new notification for a user
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection(FirebaseCollections.notifications).add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'data': data ?? {},
      });
      logger.info('Notification created for user: $userId - $type');
    } catch (e) {
      logger.error('Create notification error: $e');
      throw Exception('Failed to create notification');
    }
  }

  /// Get notifications for a user (paginated, newest first)
  Stream<List<NotificationModel>> getUserNotifications(
    String userId, {
    int limit = 20,
  }) {
    return _firestore
        .collection(FirebaseCollections.notifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  /// Get count of unread notifications for badge display
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection(FirebaseCollections.notifications)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.notifications)
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      logger.error('Mark notification as read error: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final unread = await _firestore
          .collection(FirebaseCollections.notifications)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unread.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      logger.info('Marked ${unread.docs.length} notifications as read');
    } catch (e) {
      logger.error('Mark all as read error: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.notifications)
          .doc(notificationId)
          .delete();
    } catch (e) {
      logger.error('Delete notification error: $e');
    }
  }

  /// Send notification to all admins (for booking events)
  Future<void> notifyAdmins({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Fetch all admin user IDs
      final admins = await _firestore
      .collection(FirebaseCollections.users)
      .where('role', isEqualTo: 'admin')
      .get();

      final batch = _firestore.batch();
      for (final adminDoc in admins.docs) {
        final ref =
            _firestore.collection(FirebaseCollections.notifications).doc();
        batch.set(ref, {
          'userId': adminDoc.id,
          'title': title,
          'body': body,
          'type': type,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'data': data,
        });
      }
      await batch.commit();
      logger.info('Notified ${admins.docs.length} admins: $type');
    } catch (e) {
      logger.error('Notify admins error: $e');
    }
  }

  /// Send notification to all customers (for promotions, announcements)
  Future<int> notifyAllCustomers({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final customers = await _firestore
      .collection(FirebaseCollections.users)
      .where('role', isEqualTo: 'customer')
      .get();

      final batch = _firestore.batch();
      for (final customerDoc in customers.docs) {
        final ref =
            _firestore.collection(FirebaseCollections.notifications).doc();
        batch.set(ref, {
          'userId': customerDoc.id,
          'title': title,
          'body': body,
          'type': type,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'data': data ?? {},
        });
      }
      await batch.commit();
      logger.info('Notified ${customers.docs.length} customers: $type');
      return customers.docs.length;
    } catch (e) {
      logger.error('Notify all customers error: $e');
      return 0;
    }
  }
}

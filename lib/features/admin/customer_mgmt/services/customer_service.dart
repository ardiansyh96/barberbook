import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/models/user_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> getAllCustomers() {
    return _firestore
        .collection(FirebaseCollections.users)
        .where('role', isEqualTo: 'customer')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<UserModel?> getCustomerById(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      logger.error("Get customer error : $e");
      return null;
    }
  }

  Future<void> deleteCustomer(String uid) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .delete();
    } catch (e) {
      logger.error("Delete customer : $e");
      rethrow;
    }
  }

  Future<int> totalBooking(String uid) async {
    final snap = await _firestore
        .collection(FirebaseCollections.bookings)
        .where('customerId', isEqualTo: uid)
        .get();

    return snap.docs.length;
  }

  Future<int> totalFinishedBooking(String uid) async {
    final snap = await _firestore
        .collection(FirebaseCollections.bookings)
        .where('customerId', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .get();

    return snap.docs.length;
  }

  Future<double> totalSpent(String uid) async {
    final snap = await _firestore
        .collection(FirebaseCollections.bookings)
        .where('customerId', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .get();

    double total = 0;

    for (final doc in snap.docs) {
      final data = doc.data();

      if (data['totalHarga'] != null) {
        total += (data['totalHarga'] as num).toDouble();
      }
    }

    return total;
  }
}
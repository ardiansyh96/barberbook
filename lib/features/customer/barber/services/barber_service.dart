import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/utils/logger.dart';
import '../models/barber_model.dart';

/// Service for CRUD operations on the barbers collection.
///
/// Used by both Customer (read-only) and Admin (full CRUD) features.
class BarberService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream all active barbers, ordered by rating (descending)
  Stream<List<BarberModel>> getActiveBarbers() {
  return _firestore
      .collection(FirebaseCollections.barbers)
      .snapshots()
      .map((snapshot) {
        print("===== BARBERS =====");
        print("Jumlah : ${snapshot.docs.length}");

        return snapshot.docs
            .map((doc) => BarberModel.fromFirestore(doc))
            .toList();
      });
}

  /// Stream all barbers (including inactive) for admin
  Stream<List<BarberModel>> getAllBarbers() {
    return _firestore
        .collection(FirebaseCollections.barbers)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BarberModel.fromFirestore(doc))
            .toList());
  }

  /// Get a single barber by ID
  Future<BarberModel?> getBarberById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.barbers)
          .doc(id)
          .get();
      if (!doc.exists) return null;
      return BarberModel.fromFirestore(doc);
    } catch (e) {
      logger.error('Get barber error: $e');
      return null;
    }
  }

  /// Create a new barber (admin only)
  Future<String> createBarber(BarberModel barber) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseCollections.barbers)
          .add(barber.toJson());
      logger.info('Barber created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      logger.error('Create barber error: $e');
      throw Exception('Failed to create barber');
    }
  }

  /// Update an existing barber (admin only)
  Future<void> updateBarber(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(FirebaseCollections.barbers)
          .doc(id)
          .update(updates);
      logger.info('Barber updated: $id');
    } catch (e) {
      logger.error('Update barber error: $e');
      throw Exception('Failed to update barber');
    }
  }

  /// Delete a barber (admin only)
  Future<void> deleteBarber(String id) async {
    try {
      await _firestore
          .collection(FirebaseCollections.barbers)
          .doc(id)
          .delete();
      logger.info('Barber deleted: $id');
    } catch (e) {
      logger.error('Delete barber error: $e');
      throw Exception('Failed to delete barber');
    }
  }

  /// Update barber's average rating after a new review
  Future<void> updateBarberRating(String barberId, int newRating) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.barbers)
          .doc(barberId)
          .get();

      if (!doc.exists) return;
      final barber = BarberModel.fromFirestore(doc);

      // Calculate new average
      final totalReviews = barber.totalReviews + 1;
      final newAvg =
          ((barber.rating * barber.totalReviews) + newRating) / totalReviews;

      await _firestore.collection(FirebaseCollections.barbers).doc(barberId).update({
        'rating': double.parse(newAvg.toStringAsFixed(1)),
        'totalReviews': totalReviews,
      });
      logger.info('Barber rating updated: $barberId -> $newAvg');
    } catch (e) {
      logger.error('Update barber rating error: $e');
    }
  }

  /// Search barbers by name or specialty
  Stream<List<BarberModel>> searchBarbers(String query) {
    if (query.isEmpty) return getActiveBarbers();

    final lowerQuery = query.toLowerCase();
    return _firestore
        .collection(FirebaseCollections.barbers)
        .where('statusAktif', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BarberModel.fromFirestore(doc))
            .where((b) =>
                b.nama.toLowerCase().contains(lowerQuery) ||
                b.spesialis.toLowerCase().contains(lowerQuery))
            .toList());
  }
}

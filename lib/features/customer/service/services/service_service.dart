import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/utils/logger.dart';
import '../models/service_model.dart';

/// Service for CRUD operations on the services collection.
///
/// Used by both Customer (read-only) and Admin (full CRUD) features.
class ServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream all active services
  Stream<List<ServiceModel>> getActiveServices() {
    return _firestore
        .collection(FirebaseCollections.services)
        .where('aktif', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromFirestore(doc))
            .toList());
  }

  /// Stream all services (including inactive) for admin
  Stream<List<ServiceModel>> getAllServices() {
    return _firestore
        .collection(FirebaseCollections.services)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<ServiceModel>> searchServices(
    String keyword,
  ) {

    return _firestore
        .collection(FirebaseCollections.services)
        .orderBy("nama")
        .startAt([keyword])
        .endAt(["$keyword\uf8ff"])
        .snapshots()
        .map(

          (snapshot) => snapshot.docs
              .map(ServiceModel.fromFirestore)
              .toList(),

        );

  }

  Future<List<ServiceModel>> fetchAllServices() async {

    final snapshot = await _firestore
        .collection(FirebaseCollections.services)
        .get();

    return snapshot.docs
        .map(ServiceModel.fromFirestore)
        .toList();

  }

  Future<int> totalServices() async {

    final data = await _firestore
        .collection(FirebaseCollections.services)
        .count()
        .get();

    return data.count ?? 0;

  }

  Future<int> totalActiveServices() async {

    final data = await _firestore
        .collection(FirebaseCollections.services)
        .where(
          "aktif",
          isEqualTo: true,
        )
        .count()
        .get();

    return data.count ?? 0;

  }

  /// Get a single service by ID
  Future<ServiceModel?> getServiceById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.services)
          .doc(id)
          .get();
      if (!doc.exists) return null;
      return ServiceModel.fromFirestore(doc);
    } catch (e) {
      logger.error('Get service error: $e');
      return null;
    }
  }

  /// Create a new service (admin only)
  Future<String> createService(ServiceModel service) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseCollections.services)
          .add({
          ...service.toJson(),
          "createdAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
        });
      logger.info('Service created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      logger.error('Create service error: $e');
      throw Exception('Failed to create service');
    }
  }

  /// Update an existing service (admin only)
  Future<void> updateService(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(FirebaseCollections.services)
          .doc(id)
          .update({
          ...updates,
          "updatedAt": FieldValue.serverTimestamp(),
        });
      logger.info('Service updated: $id');
    } catch (e) {
      logger.error('Update service error: $e');
      throw Exception('Failed to update service');
    }
  }

  Future<void> toggleActive(
    String id,
    bool active,
  ) async {

    await _firestore
        .collection(FirebaseCollections.services)
        .doc(id)
        .update({

      "aktif": active,
      "updatedAt": FieldValue.serverTimestamp(),

    });

  }

  /// Delete a service (admin only)
  Future<void> deleteService(String id) async {
    try {
      await _firestore
          .collection(FirebaseCollections.services)
          .doc(id)
          .delete();
      logger.info('Service deleted: $id');
    } catch (e) {
      logger.error('Delete service error: $e');
      throw Exception('Failed to delete service');
    }
  }

  /// Get services filtered by category
  Stream<List<ServiceModel>> getServicesByCategory(String category) {
    return _firestore
        .collection(FirebaseCollections.services)
        .where('aktif', isEqualTo: true)
        .where('kategori', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromFirestore(doc))
            .toList());
  }
}

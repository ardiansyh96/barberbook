import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/utils/logger.dart';
import '../models/banner_model.dart';

/// Service for banner CRUD operations (admin only).
///
/// Banners are promotional content displayed on the customer dashboard
/// in a carousel/slider format.
class BannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream active banners for customer display
  Stream<List<BannerModel>> getActiveBanners() {
    return _firestore
        .collection(FirebaseCollections.banners)
        .where('aktif', isEqualTo: true)
        .orderBy('urutan')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BannerModel.fromFirestore(doc))
            .toList());
  }

  /// Stream all banners for admin management
  Stream<List<BannerModel>> getAllBanners() {
    return _firestore
        .collection(FirebaseCollections.banners)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BannerModel.fromFirestore(doc))
            .toList());
  }

  /// Get banner by ID
Future<BannerModel?> getBannerById(String id) async {
  try {
    final doc = await _firestore
        .collection(FirebaseCollections.banners)
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return BannerModel.fromFirestore(doc);
  } catch (e) {
    logger.error("Get banner error: $e");
    return null;
  }
}

  /// Create a new banner
  Future<String> createBanner(BannerModel banner) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseCollections.banners)
          .add(banner.toJson());
      logger.info('Banner created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      logger.error('Create banner error: $e');
      throw Exception('Failed to create banner');
    }
  }

  /// Update a banner
  Future<void> updateBanner(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(FirebaseCollections.banners)
          .doc(id)
          .update(updates);
      logger.info('Banner updated: $id');
    } catch (e) {
      logger.error('Update banner error: $e');
      throw Exception('Failed to update banner');
    }
  }

  /// Toggle banner active/inactive status
  Future<void> toggleBanner(String id, bool isActive) async {
    await updateBanner(id, {'aktif': isActive});
  }

  /// Delete a banner
  Future<void> deleteBanner(String id) async {
    try {
      await _firestore
          .collection(FirebaseCollections.banners)
          .doc(id)
          .delete();
      logger.info('Banner deleted: $id');
    } catch (e) {
      logger.error('Delete banner error: $e');
      throw Exception('Failed to delete banner');
    }
  }
}

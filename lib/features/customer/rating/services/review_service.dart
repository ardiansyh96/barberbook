import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/utils/logger.dart';
import '../models/review_model.dart';

/// Service for review/rating operations.
///
/// Handles creating reviews, fetching reviews for a barber,
/// and updating the barber's average rating.
class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a review after a completed booking
  Future<String> createReview(ReviewModel review) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseCollections.reviews)
          .add(review.toJson());

      // Mark booking as rated
      await _firestore
          .collection(FirebaseCollections.bookings)
          .doc(review.bookingId)
          .update({'hasRated': true});

      // Update barber's average rating
      await _updateBarberRating(review.barberId, review.rating);

      logger.info('Review created: ${docRef.id} for barber: ${review.barberId}');
      return docRef.id;
    } catch (e) {
      logger.error('Create review error: $e');
      throw Exception('Failed to create review');
    }
  }

  /// Update barber's average rating after a new review
  Future<void> _updateBarberRating(String barberId, int newRating) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.barbers)
          .doc(barberId)
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final currentRating = (data['rating'] ?? 0).toDouble();
      final totalReviews = (data['totalReviews'] ?? 0) as int;

      final newTotal = totalReviews + 1;
      final newAvg =
          ((currentRating * totalReviews) + newRating) / newTotal;

      await _firestore.collection(FirebaseCollections.barbers).doc(barberId).update({
        'rating': double.parse(newAvg.toStringAsFixed(1)),
        'totalReviews': newTotal,
      });
    } catch (e) {
      logger.error('Update barber rating error: $e');
    }
  }

  /// Get all reviews for a specific barber
  Stream<List<ReviewModel>> getBarberReviews(String barberId) {
    return _firestore
        .collection(FirebaseCollections.reviews)
        .where('barberId', isEqualTo: barberId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList());
  }

  /// Get all reviews (for admin management)
  Stream<List<ReviewModel>> getAllReviews() {
    return _firestore
        .collection(FirebaseCollections.reviews)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList());
  }

  /// Delete a review (admin only, for inappropriate content)
  Future<void> deleteReview(String reviewId, String barberId, int rating) async {
    try {
      await _firestore.collection(FirebaseCollections.reviews).doc(reviewId).delete();

      // Recalculate barber rating after deletion
      await _recalculateBarberRating(barberId);
      logger.info('Review deleted: $reviewId');
    } catch (e) {
      logger.error('Delete review error: $e');
      throw Exception('Failed to delete review');
    }
  }

  /// Recalculate barber rating from all remaining reviews
  Future<void> _recalculateBarberRating(String barberId) async {
    try {
      final reviews = await _firestore
          .collection(FirebaseCollections.reviews)
          .where('barberId', isEqualTo: barberId)
          .get();

      if (reviews.docs.isEmpty) {
        await _firestore.collection(FirebaseCollections.barbers).doc(barberId).update({
          'rating': 0.0,
          'totalReviews': 0,
        });
        return;
      }

      final totalRating = reviews.docs.fold<int>(
        0,
        (total, doc) => total + (doc.data()['rating'] as int? ?? 0),
      );
      final avg = totalRating / reviews.docs.length;

      await _firestore.collection(FirebaseCollections.barbers).doc(barberId).update({
        'rating': double.parse(avg.toStringAsFixed(1)),
        'totalReviews': reviews.docs.length,
      });
    } catch (e) {
      logger.error('Recalculate barber rating error: $e');
    }
  }
}

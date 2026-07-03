import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/review_service.dart';
import '../models/review_model.dart';

/// Provider for review service singleton
final reviewServiceProvider = Provider<ReviewService>((ref) => ReviewService());

/// Provider that streams reviews for a specific barber
final barberReviewsProvider = StreamProvider.family<List<ReviewModel>, String>((ref, barberId) {
  final service = ref.watch(reviewServiceProvider);
  return service.getBarberReviews(barberId);
});

/// Provider that streams all reviews (admin)
final allReviewsProvider = StreamProvider<List<ReviewModel>>((ref) {
  final service = ref.watch(reviewServiceProvider);
  return service.getAllReviews();
});

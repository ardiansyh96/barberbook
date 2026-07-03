import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../customer/rating/models/review_model.dart';
import '../../../customer/rating/providers/review_provider.dart';

/// Admin review management screen showing all customer reviews.
///
/// Features:
/// - Real-time review list from Firestore
/// - Filter by rating (1-5 stars)
/// - Delete inappropriate reviews (with barber rating recalculation)
/// - Review details: customer, barber, rating, comment, date
class AdminReviewListScreen extends ConsumerStatefulWidget {
  const AdminReviewListScreen({super.key});

  @override
  ConsumerState<AdminReviewListScreen> createState() => _AdminReviewListScreenState();
}

class _AdminReviewListScreenState extends ConsumerState<AdminReviewListScreen> {
  int? _filterRating;

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(allReviewsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Manage Reviews'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(allReviewsProvider)),
        ],
      ),
      body: Column(
        children: [
          // Rating filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXL, vertical: AppDimensions.spacingMD),
            child: Row(
              children: [
                _filterChip('All', _filterRating == null, () => setState(() => _filterRating = null)),
                const SizedBox(width: 8),
                ...List.generate(5, (i) {
                  final stars = i + 1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _filterChip(
                      '$stars★',
                      _filterRating == stars,
                      () => setState(() => _filterRating = _filterRating == stars ? null : stars),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Review list
          Expanded(
            child: reviewsAsync.when(
              loading: () => const LoadingWidget(message: 'Loading reviews...'),
              error: (_, _) => const EmptyStateWidget(icon: Icons.error_outline, title: 'Error loading reviews'),
              data: (reviews) {
                final filtered = _filterRating == null
                    ? reviews
                    : reviews.where((r) => r.rating == _filterRating).toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.star_border,
                    title: _filterRating == null ? 'No Reviews Yet' : 'No $_filterRating★ Reviews',
                    description: _filterRating == null ? 'Reviews will appear after customers rate their bookings' : null,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.spacingXL),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildReviewCard(filtered[index], index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.gold : AppColors.mediumGrey),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.white : AppColors.charcoal,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      padding: const EdgeInsets.all(AppDimensions.spacingLG),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppDimensions.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: customer name + date + delete
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.gold.withValues(alpha: 0.12),
                child: Text(
                  review.customerNama?.isNotEmpty == true ? review.customerNama![0].toUpperCase() : '?',
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.customerNama ?? 'Anonymous',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(Formatters.timeAgo(review.createdAt),
                        style: const TextStyle(color: AppColors.darkGrey, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.errorRed, size: 20),
                onPressed: () => _confirmDelete(review),
                tooltip: 'Delete',
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSM),

          // Stars
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < review.rating ? Icons.star : Icons.star_border,
                color: i < review.rating ? AppColors.starFilled : AppColors.starEmpty,
                size: 18,
              );
            }),
          ),
          const SizedBox(height: AppDimensions.spacingSM),

          // Comment
          if (review.komentar.isNotEmpty)
            Text(review.komentar, style: const TextStyle(color: AppColors.charcoal, fontSize: 14)),

          // Barber reference
          const SizedBox(height: AppDimensions.spacingSM),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'For: Barber ${review.barberId.substring(0, 6)}...',
              style: const TextStyle(color: AppColors.darkGrey, fontSize: 11),
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 60).ms).fadeIn();
  }

  Future<void> _confirmDelete(ReviewModel review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Review'),
        content: const Text('Delete this review? The barber rating will be recalculated.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(reviewServiceProvider).deleteReview(review.id, review.barberId, review.rating);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review deleted'), backgroundColor: AppColors.successGreen),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.errorRed),
          );
        }
      }
    }
  }
}

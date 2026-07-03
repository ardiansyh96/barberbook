import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../barber/models/barber_model.dart';
import '../../barber/providers/barber_provider.dart';
import '../../rating/models/review_model.dart';
import '../../rating/providers/review_provider.dart';

/// Barber Detail screen showing full barber profile.
///
/// Displays:
/// - Large photo (from Firebase Storage) or placeholder avatar
/// - Name, specialty, years of experience
/// - Overall rating with star breakdown bar chart
/// - Working hours (jamMasuk - jamPulang)
/// - Recent customer reviews (from Firestore reviews collection)
/// - Sticky "Book Now" button at the bottom
///
/// Data is fetched in real-time from Firestore via:
/// - [barberByIdProvider] for barber info
/// - [barberReviewsProvider] for customer reviews
class BarberDetailScreen extends ConsumerWidget {
  final String barberId;

  const BarberDetailScreen({super.key, required this.barberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barberAsync = ref.watch(barberByIdProvider(barberId));
    final reviewsAsync = ref.watch(barberReviewsProvider(barberId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: barberAsync.when(
        loading: () => const LoadingWidget(message: 'Loading barber...'),
        error: (error, _) => EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Error',
          description: 'Failed to load barber details.',
        ),
        data: (barber) {
          if (barber == null) {
            return EmptyStateWidget(
              icon: Icons.person_off_outlined,
              title: 'Barber Not Found',
              description: 'This barber does not exist or has been removed.',
            );
          }

          return CustomScrollView(
            slivers: [
              // ─── Hero Photo Section ───────────────────────────────
              _buildPhotoSection(context, barber),

              // ─── Info Section ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingXL),
                  child: _buildInfoSection(context, barber),
                ),
              ),

              // ─── Stats Row ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXL,
                  ),
                  child: _buildStatsRow(context, barber),
                ),
              ),

              // ─── Working Hours ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingXL),
                  child: _buildWorkingHours(context, barber),
                ),
              ),

              // ─── Rating Breakdown ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXL,
                  ),
                  child: _buildRatingSection(context, barber, reviewsAsync),
                ),
              ),

              // ─── Reviews List ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.spacingXL,
                    AppDimensions.spacingLG,
                    AppDimensions.spacingXL,
                    0,
                  ),
                  child: Text(
                    'Recent Reviews',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              _buildReviewsList(reviewsAsync),

              // Bottom padding for the sticky button
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
      // ─── Sticky Book Now Button ─────────────────────────────────
      bottomNavigationBar: _buildBookNowButton(context),
    );
  }

  // ─── Photo Section with back button ───────────────────────────────
  Widget _buildPhotoSection(BuildContext context, BarberModel barber) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: barber.foto != null && barber.foto!.isNotEmpty
            ? CachedImage(
                imageUrl: barber.foto!,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
              )
            : Container(
                width: double.infinity,
                height: 280,
                decoration: const BoxDecoration(
                  gradient: AppColors.darkGradient,
                ),
                child: const Icon(
                  Icons.person,
                  size: 100,
                  color: AppColors.mediumGrey,
                ),
              ),
      ),
    );
  }

  // ─── Name, Specialty, Experience Info ─────────────────────────────
  Widget _buildInfoSection(BuildContext context, BarberModel barber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          barber.nama,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ).animate().fadeIn().slideX(begin: 0.1),
        const SizedBox(height: 4),
        Text(
          barber.spesialis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
        ).animate(delay: 100.ms).fadeIn(),
        const SizedBox(height: AppDimensions.spacingSM),
        // Experience badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.work, size: 14, color: AppColors.goldDark),
              const SizedBox(width: 4),
              Text(
                '${barber.pengalaman} years experience',
                style: const TextStyle(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ).animate(delay: 200.ms).fadeIn(),
      ],
    );
  }

  // ─── Quick Stats Row (Rating, Reviews, Experience) ────────────────
  Widget _buildStatsRow(BuildContext context, BarberModel barber) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLG),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppDimensions.shadowSM,
      ),
      child: Row(
        children: [
          // Rating
          _buildStatItem(
            icon: Icons.star,
            iconColor: AppColors.starFilled,
            value: Formatters.rating(barber.rating),
            label: 'Rating',
          ),
          Container(width: 1, height: 40, color: AppColors.lightGrey),
          // Reviews
          _buildStatItem(
            icon: Icons.rate_review_outlined,
            iconColor: AppColors.infoBlue,
            value: '${barber.totalReviews}',
            label: 'Reviews',
          ),
          Container(width: 1, height: 40, color: AppColors.lightGrey),
          // Experience
          _buildStatItem(
            icon: Icons.emoji_events_outlined,
            iconColor: AppColors.accentOrange,
            value: '${barber.pengalaman}yr',
            label: 'Experience',
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Working Hours Card ───────────────────────────────────────────
  Widget _buildWorkingHours(BuildContext context, BarberModel barber) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLG),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppDimensions.shadowSM,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.schedule,
              color: AppColors.successGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMD),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Working Hours',
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${Formatters.time12h(barber.jamMasuk)} - ${Formatters.time12h(barber.jamPulang)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn();
  }

  // ─── Rating Breakdown with Star Bars ──────────────────────────────
  Widget _buildRatingSection(
    BuildContext context,
    BarberModel barber,
    AsyncValue<List<ReviewModel>> reviewsAsync,
  ) {
    final reviews = reviewsAsync.whenOrNull(data: (r) => r) ?? [];

    // Calculate star distribution
    final starCounts = List.filled(6, 0); // index 0-5
    for (final review in reviews) {
      if (review.rating >= 1 && review.rating <= 5) {
        starCounts[review.rating]++;
      }
    }
    final totalReviews = reviews.isNotEmpty ? reviews.length : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating Breakdown',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spacingMD),
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacingLG),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            boxShadow: AppDimensions.shadowSM,
          ),
          child: Column(
            children: [
              // Overall rating
              Row(
                children: [
                  Text(
                    Formatters.rating(barber.rating),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMD),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stars
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < barber.rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.starFilled,
                            size: 20,
                          );
                        }),
                      ),
                      Text(
                        '${barber.totalReviews} reviews',
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingLG),

              // Star breakdown bars
              for (int star = 5; star >= 1; star--)
                _buildStarBar(star, starCounts[star], totalReviews),
            ],
          ),
        ),
      ],
    ).animate(delay: 500.ms).fadeIn();
  }

  /// Individual star bar showing count and percentage
  Widget _buildStarBar(int star, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            child: Text(
              '$star',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.star, color: AppColors.starFilled, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.lightGrey,
                valueColor: const AlwaysStoppedAnimation(AppColors.starFilled),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkGrey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reviews List ─────────────────────────────────────────────────
  Widget _buildReviewsList(AsyncValue<List<ReviewModel>> reviewsAsync) {
    return reviewsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spacingXL),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      data: (reviews) {
        if (reviews.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXL,
                vertical: AppDimensions.spacingMD,
              ),
              child: EmptyStateWidget(
                icon: Icons.rate_review_outlined,
                title: 'No Reviews Yet',
                description: 'Be the first to review this barber!',
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final review = reviews[index];
              return _buildReviewCard(review, index);
            },
            childCount: reviews.length > 5 ? 5 : reviews.length,
          ),
        );
      },
    );
  }

  /// Individual review card
  Widget _buildReviewCard(ReviewModel review, int index) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.spacingXL,
        0,
        AppDimensions.spacingXL,
        AppDimensions.spacingMD,
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingLG),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: AppDimensions.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: customer name + date
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                child: Text(
                  (review.customerNama ?? 'A')[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              Expanded(
                child: Text(
                  review.customerNama ?? 'Customer',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                Formatters.timeAgo(review.createdAt),
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSM),

          // Stars
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < review.rating ? Icons.star : Icons.star_border,
                color: AppColors.starFilled,
                size: 16,
              );
            }),
          ),

          // Comment
          if (review.komentar.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSM),
            Text(
              review.komentar,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ],
      ),
    ).animate(delay: (index * 80).ms).fadeIn();
  }

  // ─── Sticky Book Now Button ───────────────────────────────────────
  Widget _buildBookNowButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingXL,
        AppDimensions.spacingMD,
        AppDimensions.spacingXL,
        AppDimensions.spacingXL,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        height: AppDimensions.buttonHeightLG,
        child: ElevatedButton(
          onPressed: () => context.push(
            '${RouteNames.bookingCreate}?barberId=$barberId',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlack,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 18),
              SizedBox(width: 8),
              Text(
                'Book Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }
}

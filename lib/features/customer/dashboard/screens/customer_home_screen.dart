import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../admin/banner_mgmt/providers/admin_banner_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../barber/models/barber_model.dart';
import '../../barber/providers/barber_provider.dart';
import '../../notification/providers/notification_provider.dart';
import '../../service/models/service_model.dart';
import '../../service/providers/service_provider.dart';


class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  String _selectedCategory = 'All';

  /// Available service categories for filtering
  final List<String> _categories = ['All', 'Haircuts', 'Facial', 'Hairdo', 'Massage', 'Shave'];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.whenOrNull(data: (u) => u);
    final firstName = user != null ? user.nama.split(' ').first : 'Guest';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.gold,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ─── Header Section ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingXL,
                  AppDimensions.spacingLG,
                  AppDimensions.spacingXL,
                  0,
                ),
                child: _buildHeader(context, firstName, user?.uid),
              ).animate().fadeIn(duration: 600.ms),
            ),

            // ─── Search Bar ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXL,
                  vertical: AppDimensions.spacingLG,
                ),
                child: _buildSearchBar(context),
              ),
            ),

            // ─── Banner / Promo Section ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXL,
                ),
                child: _buildBannerSection(context),
              ),
            ),

            // ─── Category Filters ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXL,
                  vertical: AppDimensions.spacingMD,
                ),
                child: _buildCategoryFilters(context),
              ),
            ),

            // ─── Top Barbers Section ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXL,
                  vertical: AppDimensions.spacingSM,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Barbers',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.barberList),
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),

            // Barber horizontal list from Firestore
            SliverToBoxAdapter(
              child: _buildBarberList(context),
            ),

            // ─── Services Section ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingXL,
                  AppDimensions.spacingLG,
                  AppDimensions.spacingXL,
                  AppDimensions.spacingSM,
                ),
                child: Text(
                  'Our Services',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),

            // Services grid from Firestore
            _buildServicesGrid(context),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.spacingXXXL),
            ),
          ],
        ),
      ),
    );
  }

  /// Pull-to-refresh: invalidate all providers to reload fresh data
  Future<void> _onRefresh() async {
    ref.invalidate(activeBannersProvider);
    ref.invalidate(activeBarbersProvider);
    ref.invalidate(activeServicesProvider);
    // Wait a bit for visual feedback
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ─── Header with Greeting and Notification Bell ─────────────────────
  Widget _buildHeader(BuildContext context, String firstName, String? userId) {
    return Row(
      children: [
        // Avatar with first letter of user's name
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.gold.withValues(alpha: 0.15),
          child: Text(
            firstName.isNotEmpty ? firstName[0].toUpperCase() : 'G',
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        // Greeting text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello $firstName',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.darkGrey),
            ),
            Text(
              Formatters.greeting(),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const Spacer(),
        // Notification bell with unread badge
        _buildNotificationBell(userId),
      ],
    );
  }

  /// Notification bell icon with unread count badge from Firestore
  Widget _buildNotificationBell(String? userId) {
    if (userId == null) {
      return IconButton(
        onPressed: () => context.push(RouteNames.notifications),
        icon: const Icon(Icons.notifications_outlined, color: AppColors.charcoal),
      );
    }

    // Watch unread count in real-time
    final unreadCountAsync = ref.watch(unreadCountProvider(userId));
    final unreadCount = unreadCountAsync.whenOrNull(data: (count) => count) ?? 0;

    return Stack(
      children: [
        IconButton(
          onPressed: () => context.push(RouteNames.notifications),
          icon: const Icon(Icons.notifications_outlined, color: AppColors.charcoal),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.errorRed,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  // ─── Search Bar ─────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(RouteNames.customerSearch),
      child: Container(
        height: AppDimensions.inputHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: AppDimensions.shadowSM,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLG),
        child: const Row(
          children: [
            Icon(Icons.search, color: AppColors.mediumGrey),
            SizedBox(width: AppDimensions.spacingSM),
            Text(
              'Search barbers, services...',
              style: TextStyle(color: AppColors.mediumGrey),
            ),
          ],
        ),
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1);
  }

  // ─── Banner Carousel from Firestore ─────────────────────────────────
  Widget _buildBannerSection(BuildContext context) {
    final bannersAsync = ref.watch(activeBannersProvider);

    return bannersAsync.when(
      loading: () => SkeletonLoading.banner().animate(delay: 300.ms).fadeIn(),
      error: (error, _) => _buildBannerPlaceholder(context),
      data: (banners) {
        if (banners.isEmpty) {
          return _buildBannerPlaceholder(context);
        }
        return SizedBox(
          height: AppDimensions.bannerHeight,
          child: PageView.builder(
            itemCount: banners.length,
            controller: PageController(viewportFraction: 0.95),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return _buildBannerCard(context, banner.judul, banner.deskripsi ?? '', banner.gambar);
            },
          ),
        ).animate(delay: 300.ms).fadeIn().slideX(begin: 0.1);
      },
    );
  }

  /// Single banner card with gradient background and optional image
  Widget _buildBannerCard(BuildContext context, String title, String desc, String? imageUrl) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: AppColors.promoGradient,
        borderRadius: BorderRadius.circular(AppDimensions.bannerBorderRadius),
        boxShadow: AppDimensions.shadowMD,
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingXL),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PROMO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Get Offer',
                        style: TextStyle(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, color: AppColors.accentOrange, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.content_cut, size: 80, color: Colors.white24),
        ],
      ),
    );
  }

  /// Placeholder banner when no banners in Firestore
  Widget _buildBannerPlaceholder(BuildContext context) {
    return Container(
      height: AppDimensions.bannerHeight,
      decoration: BoxDecoration(
        gradient: AppColors.promoGradient,
        borderRadius: BorderRadius.circular(AppDimensions.bannerBorderRadius),
        boxShadow: AppDimensions.shadowMD,
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingXL),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PROMO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome to BarberBook',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Book your barber today!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.content_cut, size: 80, color: Colors.white24),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().slideX(begin: 0.1);
  }

  // ─── Category Filters ───────────────────────────────────────────────
  Widget _buildCategoryFilters(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isActive = _categories[index] == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accentOrange : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.accentOrange : AppColors.lightGrey,
                ),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.charcoal,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate(delay: 400.ms).fadeIn();
  }

  // ─── Barber List from Firestore ─────────────────────────────────────
  Widget _buildBarberList(BuildContext context) {
    final barbersAsync = ref.watch(activeBarbersProvider);

    return barbersAsync.when(
      loading: () => SizedBox(
        height: 180,
        child: SkeletonLoading.horizontalList(itemCount: 4),
      ),
      error: (error, _) => SizedBox(
        height: 180,
        child: Center(child: Text('Failed to load barbers')),
      ),
      data: (barbers) {
        if (barbers.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.person_off_outlined,
            title: 'No Barbers Available',
            description: 'Check back later for available barbers.',
          );
        }
        // Show top 5 barbers sorted by rating
        final sortedBarbers = List<BarberModel>.from(barbers)
          ..sort((a, b) => b.rating.compareTo(a.rating));
        final topBarbers = sortedBarbers.take(5).toList();

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXL),
            itemCount: topBarbers.length,
            itemBuilder: (context, index) =>
                _buildBarberCard(context, topBarbers[index], index),
          ),
        );
      },
    );
  }

  /// Barber card with photo, name, specialty, and rating
  Widget _buildBarberCard(BuildContext context, BarberModel barber, int index) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.barberDetail}/${barber.id}'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: AppDimensions.shadowSM,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Barber photo or placeholder
            barber.foto != null
                ? CachedImage(
                    imageUrl: barber.foto!,
                    width: 64,
                    height: 64,
                    borderRadius: 32,
                    fit: BoxFit.cover,
                  )
                : CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.lightGrey,
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: AppColors.mediumGrey,
                    ),
                  ),
            const SizedBox(height: 8),
            Text(
              barber.nama,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              barber.spesialis,
              style: TextStyle(color: AppColors.darkGrey, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: AppColors.starFilled, size: 14),
                const SizedBox(width: 2),
                Text(
                  Formatters.rating(barber.rating),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).animate(delay: (400 + index * 100).ms).fadeIn().slideX(begin: 0.1);
  }

  // ─── Services Grid from Firestore ───────────────────────────────────
  Widget _buildServicesGrid(BuildContext context) {
    final servicesAsync = ref.watch(activeServicesProvider);

    return servicesAsync.when(
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXL),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => SkeletonLoading.card(),
            childCount: 4,
          ),
        ),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: Center(child: Text('Failed to load services')),
      ),
      data: (services) {
        // Filter by category if not 'All'
        final filtered = _selectedCategory == 'All'
            ? services
            : services.where((s) => s.kategori == _selectedCategory).toList();

        if (filtered.isEmpty) {
          return const SliverToBoxAdapter(
            child: EmptyStateWidget(
              icon: Icons.content_cut_outlined,
              title: 'No Services',
              description: 'No services available in this category.',
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXL),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildServiceCard(context, filtered[index], index),
              childCount: filtered.length,
            ),
          ),
        );
      },
    );
  }

  /// Service card with icon, name, price, and category
  Widget _buildServiceCard(BuildContext context, ServiceModel service, int index) {
    final colors = [
      AppColors.accentOrange,
      AppColors.primaryBlack,
      const Color(0xFFE65100),
      AppColors.gold,
    ];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () => context.push(RouteNames.bookingCreate),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: AppDimensions.shadowSM,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Service icon or image
            service.gambar != null
                ? CachedImage(
                    imageUrl: service.gambar!,
                    width: 40,
                    height: 40,
                    borderRadius: 10,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.content_cut, color: color, size: 20),
                  ),
            const SizedBox(height: 8),
            Text(
              service.nama,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              Formatters.currency(service.harga),
              style: TextStyle(color: AppColors.darkGrey, fontSize: 12),
            ),
          ],
        ),
      ),
    ).animate(delay: (600 + index * 100).ms).fadeIn().scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
        );
  }
}

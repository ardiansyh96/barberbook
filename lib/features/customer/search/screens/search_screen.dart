import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../barber/providers/barber_provider.dart';
import '../../barber/models/barber_model.dart';
import '../../service/providers/service_provider.dart';
import '../../service/models/service_model.dart';

/// Search screen for finding barbers and services from Firestore.
///
/// Features:
/// - Debounced search input (500ms delay)
/// - Tab-based results: Barbers and Services
/// - Real-time filtering from Firestore data
/// - Empty state and clear search functionality
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Handle search input with debounce
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounce, () {
      setState(() => _searchQuery = query.trim().toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Search Bar ──────────────────────────────────────────
            _buildSearchBar(),

            // ─── Tab Bar ─────────────────────────────────────────────
            _buildTabBar(),

            // ─── Results ─────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBarberResults(),
                  _buildServiceResults(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search Bar ────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingXL,
        AppDimensions.spacingLG,
        AppDimensions.spacingXL,
        AppDimensions.spacingSM,
      ),
      child: Container(
        height: AppDimensions.inputHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: AppDimensions.shadowSM,
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search barbers or services...',
            prefixIcon: const Icon(Icons.search, color: AppColors.mediumGrey),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.mediumGrey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  // ─── Tab Bar ───────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.darkGrey,
        indicator: BoxDecoration(
          color: AppColors.primaryBlack,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 18),
                SizedBox(width: 6),
                Text('Barbers', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.content_cut, size: 18),
                SizedBox(width: 6),
                Text('Services', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Barber Results ────────────────────────────────────────────────
  Widget _buildBarberResults() {
    final barbersAsync = ref.watch(activeBarbersProvider);

    return barbersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'Error',
        description: 'Failed to load barbers',
      ),
      data: (barbers) {
        // Filter by search query
        final filtered = _searchQuery.isEmpty
            ? barbers
            : barbers.where((b) {
                final name = b.nama.toLowerCase();
                final specialty = b.spesialis.toLowerCase();
                return name.contains(_searchQuery) ||
                    specialty.contains(_searchQuery);
              }).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState('barbers');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.spacingXL),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _buildBarberCard(filtered[index], index);
          },
        );
      },
    );
  }

  // ─── Service Results ───────────────────────────────────────────────
  Widget _buildServiceResults() {
    final servicesAsync = ref.watch(activeServicesProvider);

    return servicesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'Error',
        description: 'Failed to load services',
      ),
      data: (services) {
        // Filter by search query
        final filtered = _searchQuery.isEmpty
            ? services
            : services.where((s) {
                final name = s.nama.toLowerCase();
                final category = s.kategori.toLowerCase();
                return name.contains(_searchQuery) ||
                    category.contains(_searchQuery);
              }).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState('services');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.spacingXL),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _buildServiceCard(filtered[index], index);
          },
        );
      },
    );
  }

  // ─── Barber Card ───────────────────────────────────────────────────
  Widget _buildBarberCard(BarberModel barber, int index) {
    return GestureDetector(
      onTap: () => context.pushNamed('barber-detail', pathParameters: {'barberId': barber.id}),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
        padding: const EdgeInsets.all(AppDimensions.spacingMD),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: AppDimensions.shadowSM,
        ),
        child: Row(
          children: [
            // Photo
            barber.foto != null
                ? CachedImage(
                    imageUrl: barber.foto!,
                    width: 56,
                    height: 56,
                    borderRadius: 28,
                    fit: BoxFit.cover,
                  )
                : CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                    child: const Icon(Icons.person, color: AppColors.gold),
                  ),
            const SizedBox(width: AppDimensions.spacingMD),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barber.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    barber.spesialis,
                    style: TextStyle(color: AppColors.darkGrey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.starFilled, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        Formatters.rating(barber.rating),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      const SizedBox(width: AppDimensions.spacingSM),
                      Text(
                        '${barber.pengalaman} years',
                        style: TextStyle(color: AppColors.darkGrey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: AppColors.mediumGrey),
          ],
        ),
      ),
    ).animate(delay: (index * 60).ms).fadeIn().slideX(begin: 0.05);
  }

  // ─── Service Card ──────────────────────────────────────────────────
  Widget _buildServiceCard(ServiceModel service, int index) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.bookingCreate),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
        padding: const EdgeInsets.all(AppDimensions.spacingLG),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: AppDimensions.shadowSM,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.content_cut, color: AppColors.gold, size: 24),
            ),
            const SizedBox(width: AppDimensions.spacingMD),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${service.kategori} • ${service.durasi} min',
                    style: TextStyle(color: AppColors.darkGrey, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Price
            Text(
              Formatters.currency(service.harga),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.primaryBlack,
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 60).ms).fadeIn().slideX(begin: 0.05);
  }

  // ─── Empty State ───────────────────────────────────────────────────
  Widget _buildEmptyState(String type) {
    if (_searchQuery.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search,
        title: 'Search $type',
        description: 'Type to find $type',
      );
    }

    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results',
      description: 'No $type found for "$_searchQuery"',
      actionText: 'Clear Search',
      onAction: () {
        _searchController.clear();
        setState(() => _searchQuery = '');
      },
    );
  }
}

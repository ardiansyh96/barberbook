import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../models/barber_model.dart';
import '../providers/barber_provider.dart';
import '../widgets/barber_card.dart';

/// Barber List screen displaying all active barbers from Firestore.
///
/// Features:
/// - Search bar with debounced query (filters by name/specialty)
/// - Filter chips: minimum rating, sort by rating/experience
/// - Real-time data from Firestore via [activeBarbersProvider]
/// - Skeleton loading while fetching
/// - Empty state when no barbers match filters
/// - Pull-to-refresh
/// - Tap barber card to navigate to detail page
class BarberListScreen extends ConsumerStatefulWidget {
  const BarberListScreen({super.key});

  @override
  ConsumerState<BarberListScreen> createState() => _BarberListScreenState();
}

class _BarberListScreenState extends ConsumerState<BarberListScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _searchQuery = '';
  Timer? _debounce;

  /// Minimum rating filter (0 = no filter)
  double _minRating = 0;

  /// Sort mode: 'rating' or 'experience'
  String _sortBy = 'rating';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Debounced search: waits for user to stop typing before filtering
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(
      AppConstants.searchDebounce,
      () => setState(() => _searchQuery = query.trim()),
    );
  }

  /// Apply filters and sorting to the barber list
  List<BarberModel> _applyFilters(List<BarberModel> barbers) {
    var filtered = List<BarberModel>.from(barbers);

    // Search filter (name or specialty)
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((b) {
        return b.nama.toLowerCase().contains(lowerQuery) ||
            b.spesialis.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Rating filter
    if (_minRating > 0) {
      filtered = filtered.where((b) => b.rating >= _minRating).toList();
    }

    // Sort
    if (_sortBy == 'rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'experience') {
      filtered.sort((a, b) => b.pengalaman.compareTo(a.pengalaman));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final barbersAsync = ref.watch(activeBarbersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Our Barbers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeBarbersProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: AppColors.gold,
        child: Column(
          children: [
            // Search bar
            _buildSearchBar(),

            // Filter chips row
            _buildFilterChips(),

            // Barber list
            Expanded(
              child: barbersAsync.when(
                loading: () => _buildLoadingState(),
                error: (error, _) => _buildErrorState(),
                data: (barbers) {
                  final filtered = _applyFilters(barbers);

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.spacingXL,
                      AppDimensions.spacingSM,
                      AppDimensions.spacingXL,
                      AppDimensions.spacingXL,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return BarberCard(
                        barber: filtered[index],
                        onTap: () => context.push(
                          '${RouteNames.barberDetail}/${filtered[index].id}',
                        ),
                      ).animate(delay: (index * 80).ms).fadeIn().slideX(begin: 0.05);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Search input field
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingXL,
        vertical: AppDimensions.spacingSM,
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search barbers...',
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
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLG,
            vertical: AppDimensions.spacingMD,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  /// Filter and sort chips row
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingXL,
        vertical: AppDimensions.spacingSM,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Rating filter chips
            _buildFilterChip(
              label: 'All',
              isActive: _minRating == 0,
              onTap: () => setState(() => _minRating = 0),
            ),
            const SizedBox(width: AppDimensions.spacingSM),
            _buildFilterChip(
              label: '4.0+',
              isActive: _minRating == 4.0,
              onTap: () => setState(() => _minRating = 4.0),
              icon: Icons.star,
              iconColor: AppColors.starFilled,
            ),
            const SizedBox(width: AppDimensions.spacingSM),
            _buildFilterChip(
              label: '3.0+',
              isActive: _minRating == 3.0,
              onTap: () => setState(() => _minRating = 3.0),
              icon: Icons.star,
              iconColor: AppColors.starFilled,
            ),
            const SizedBox(width: AppDimensions.spacingLG),

            // Sort divider
            Container(
              width: 1,
              height: 24,
              color: AppColors.lightGrey,
            ),
            const SizedBox(width: AppDimensions.spacingLG),

            // Sort chips
            _buildFilterChip(
              label: 'Top Rated',
              isActive: _sortBy == 'rating',
              onTap: () => setState(() => _sortBy = 'rating'),
              icon: Icons.emoji_events_outlined,
            ),
            const SizedBox(width: AppDimensions.spacingSM),
            _buildFilterChip(
              label: 'Experienced',
              isActive: _sortBy == 'experience',
              onTap: () => setState(() => _sortBy = 'experience'),
              icon: Icons.work_outline,
            ),
          ],
        ),
      ),
    ).animate(delay: 200.ms).fadeIn();
  }

  /// Individual filter chip
  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    IconData? icon,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlack : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primaryBlack : AppColors.lightGrey,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isActive
                    ? AppColors.gold
                    : (iconColor ?? AppColors.charcoal),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.white : AppColors.charcoal,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Loading state with skeleton placeholders
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacingXL),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          height: 90,
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          ),
        );
      },
    );
  }

  /// Error state with retry button
  Widget _buildErrorState() {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: 'Connection Error',
      description: 'Failed to load barbers. Pull down to retry.',
    );
  }

  /// Empty state when no barbers match filters
  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.person_off_outlined,
      title: 'No Barbers Found',
      description: _searchQuery.isNotEmpty
          ? 'No barbers match "$_searchQuery". Try a different search.'
          : 'No barbers match your filters. Try adjusting them.',
    );
  }
}

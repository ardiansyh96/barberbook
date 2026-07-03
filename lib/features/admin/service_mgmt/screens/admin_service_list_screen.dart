import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../customer/service/models/service_model.dart';
import '../../../customer/service/providers/service_provider.dart';

/// Admin service list screen showing all services with CRUD actions.
///
/// Features:
/// - Real-time list from Firestore (all services including inactive)
/// - Search by name or category
/// - Add new service button
/// - Edit and delete actions per service
/// - Active/inactive status indicator
class AdminServiceListScreen extends ConsumerStatefulWidget {
  const AdminServiceListScreen({super.key});

  @override
  ConsumerState<AdminServiceListScreen> createState() => _AdminServiceListScreenState();
}

class _AdminServiceListScreenState extends ConsumerState<AdminServiceListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final servicesAsync =
    _searchQuery.isEmpty

        ? ref.watch(
            allServicesProvider,
          )

        : ref.watch(
            searchServicesProvider(
              _searchQuery,
            ),
          );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Manage Services'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allServicesProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.adminServiceAdd),
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.gold,
        icon: const Icon(Icons.add),
        label: const Text('Add Service', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingXL),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          // Service list
          Expanded(
            child: servicesAsync.when(
              loading: () => const LoadingWidget(message: 'Loading services...'),
              error: (_, _) => const EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Error loading services',
              ),
              data: (services) {
                final filtered = _searchQuery.isEmpty
                    ? services
                    : services
                        .where((s) =>
                            s.nama.toLowerCase().contains(_searchQuery) ||
                            s.kategori.toLowerCase().contains(_searchQuery))
                        .toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.miscellaneous_services,
                    title: _searchQuery.isEmpty ? 'No Services Yet' : 'No Results',
                    description: _searchQuery.isEmpty
                        ? 'Add your first service to get started'
                        : 'No services match "$_searchQuery"',
                    actionText: _searchQuery.isEmpty ? 'Add Service' : null,
                    onAction: _searchQuery.isEmpty
                        ? () => context.push(RouteNames.adminServiceAdd)
                        : null,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXL),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildServiceCard(filtered[index], index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service, int index) {
  return InkWell(
    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),

    onTap: () {
      context.push(
        RouteNames.adminServiceDetail.replaceFirst(
          ":serviceId",
          service.id,
        ),
      );
    },

    child: Container(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMD,
      ),

      padding: const EdgeInsets.all(
        AppDimensions.spacingMD,
      ),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLG,
        ),
        boxShadow: AppDimensions.shadowSM,
      ),

      child: Row(
        children: [

          /// ICON
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.miscellaneous_services,
              color: AppColors.gold,
            ),
          ),

          const SizedBox(
            width: AppDimensions.spacingMD,
          ),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// nama + status
                Row(
                  children: [

                    Expanded(
                      child: Text(
                        service.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: service.aktif
                            ? AppColors.successGreen.withValues(alpha: .12)
                            : AppColors.errorRed.withValues(alpha: .12),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        service.aktif
                            ? "Active"
                            : "Inactive",
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  service.kategori,
                ),

                const SizedBox(height: 5),

                Text(
                  service.deskripsi,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  children: [

                    Chip(
                      label: Text(
                        Formatters.currency(
                          service.harga,
                        ),
                      ),
                    ),

                    Chip(
                      label: Text(
                        "${service.durasi} menit",
                      ),
                    ),

                  ],
                ),

              ],
            ),
          ),

          /// MENU
          PopupMenuButton<String>(

            onSelected: (value) async {

              switch (value) {

                case "edit":

                  context.push(
                    RouteNames.adminServiceEdit
                        .replaceFirst(
                      ":serviceId",
                      service.id,
                    ),
                  );

                  break;

                case "active":

                  await ref
                      .read(serviceServiceProvider)
                      .toggleActive(
                        service.id,
                        !service.aktif,
                      );

                  break;

                case "delete":

                  _confirmDelete(service);

                  break;

              }

            },

            itemBuilder: (_) => [

              const PopupMenuItem(
                value: "edit",
                child: Text("Edit"),
              ),

              PopupMenuItem(
                value: "active",
                child: Text(
                  service.aktif
                      ? "Nonaktifkan"
                      : "Aktifkan",
                ),
              ),

              const PopupMenuItem(
                value: "delete",
                child: Text("Delete"),
              ),

            ],

          ),

        ],
      ),
    ),
  ).animate(
    delay: (index * 60).ms,
  ).fadeIn();
}

  Future<void> _confirmDelete(ServiceModel service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete ${service.nama}?'),
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
        await ref.read(serviceServiceProvider).deleteService(service.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${service.nama} deleted'), backgroundColor: AppColors.successGreen),
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

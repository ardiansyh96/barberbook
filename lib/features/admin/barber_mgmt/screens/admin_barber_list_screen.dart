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
import '../../../../shared/widgets/cached_image.dart';
import '../../../customer/barber/models/barber_model.dart';
import '../../../customer/barber/providers/barber_provider.dart';

/// Admin barber list screen showing all barbers with CRUD actions.
///
/// Features:
/// - Real-time list from Firestore (all barbers including inactive)
/// - Search by name
/// - Add new barber button
/// - Edit and delete actions per barber
/// - Status indicator (active/inactive)
class AdminBarberListScreen extends ConsumerStatefulWidget {
  const AdminBarberListScreen({super.key});

  @override
  ConsumerState<AdminBarberListScreen> createState() => _AdminBarberListScreenState();
}

class _AdminBarberListScreenState extends ConsumerState<AdminBarberListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final barbersAsync = ref.watch(allBarbersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Manage Barbers'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allBarbersProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.adminBarberAdd),
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.gold,
        icon: const Icon(Icons.add),
        label: const Text('Add Barber', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingXL),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search barbers...',
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

          // Barber list
          Expanded(
            child: barbersAsync.when(
              loading: () => const LoadingWidget(message: 'Loading barbers...'),
              error: (_, _) => const EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Error loading barbers',
              ),
              data: (barbers) {
                final filtered = _searchQuery.isEmpty
                    ? barbers
                    : barbers
                        .where((b) =>
                            b.nama.toLowerCase().contains(_searchQuery) ||
                            b.spesialis.toLowerCase().contains(_searchQuery))
                        .toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.content_cut,
                    title: _searchQuery.isEmpty ? 'No Barbers Yet' : 'No Results',
                    description: _searchQuery.isEmpty
                        ? 'Add your first barber to get started'
                        : 'No barbers match "$_searchQuery"',
                    actionText: _searchQuery.isEmpty ? 'Add Barber' : null,
                    onAction: _searchQuery.isEmpty
                        ? () => context.push(RouteNames.adminBarberAdd)
                        : null,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXL,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildBarberCard(filtered[index], index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarberCard(BarberModel barber, int index) {
    return InkWell(

    borderRadius:
        BorderRadius.circular(
            AppDimensions.radiusLG),

    onTap: () {

      context.push(

        RouteNames.adminBarberDetail
            .replaceFirst(
              ":barberId",
              barber.id,
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
      borderRadius:
          BorderRadius.circular(
              AppDimensions.radiusLG),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        barber.nama,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: barber.statusAktif
                            ? AppColors.successGreen.withValues(alpha: 0.1)
                            : AppColors.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        barber.statusAktif ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: barber.statusAktif ? AppColors.successGreen : AppColors.errorRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  barber.spesialis,
                  style: TextStyle(color: AppColors.darkGrey, fontSize: 12),
                ),

                const SizedBox(height:6),
                  Wrap(

                  spacing:8,

                  children:[

                  Chip(

                  label: Text(
                  "${barber.totalReviews} Reviews"
                  ),

                  ),

                  Chip(

                  backgroundColor:
                  Colors.amber.shade100,

                  label: Text(
                  "${barber.rating}",
                  ),

                  ),

                  ],

                  ),

                const SizedBox(height: 4),

                Row(
                  children: [

                    const Icon(
                      Icons.star,
                      color: AppColors.starFilled,
                      size: 14,
                    ),

                    const SizedBox(width: 2),

                    Text(
                      Formatters.rating(barber.rating),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      "${barber.pengalaman} Tahun",
                      style: const TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 12,
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  "${barber.jamMasuk} - ${barber.jamPulang}",
                  style: const TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(

          onSelected:(value){

          switch(value){

          case "edit":

          context.push(
          RouteNames.adminBarberEdit
          .replaceFirst(
          ":barberId",
          barber.id,
          ),
          );

          break;

          case "active":

          ref.read(barberServiceProvider)
          .updateBarber(
          barber.id,
          {
          "statusAktif":
          !barber.statusAktif,
          },
          );

          break;

          case "delete":

          _confirmDelete(barber);

          break;

          }

          },

          itemBuilder:(context)=>[

          const PopupMenuItem(

            value:"edit",

            child: Row(

            children:[

            Icon(Icons.edit,size:18),

            SizedBox(width:8),

            Text("Edit"),

            ],

            ),

          ),
          PopupMenuItem(
          value:"active",
          child: Text(
          barber.statusAktif
          ? "Nonaktifkan"
          : "Aktifkan",
          ),
          ),

          const PopupMenuItem(
          value:"delete",
          child: Text("Delete"),
          ),

          ],

          )
        ],
      ), 
      )
    ).animate(
        delay:(index*60).ms,
        )

        .fadeIn()

        .slideY(
        begin:0.2,
        end:0,
        );
  }

  Future<void> _confirmDelete(BarberModel barber) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Barber'),
        content: Text('Are you sure you want to delete ${barber.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(barberServiceProvider).deleteBarber(barber.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${barber.nama} deleted'),
              backgroundColor: AppColors.successGreen,
            ),
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

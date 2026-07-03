import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/admin_dashboard_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
  elevation: 0,
  centerTitle: true,
  backgroundColor: Colors.white,
  surfaceTintColor: Colors.white,

  title: const Text(
    "Admin Dashboard",
    style: TextStyle(
      fontWeight: FontWeight.w700,
    ),
  ),

  leading: Builder(
    builder: (context) => IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () => Scaffold.of(context).openDrawer(),
    ),
  ),

  actions: [

    IconButton(
      tooltip: "Notification",
      onPressed: () {
        context.push(RouteNames.adminSendNotification);
      },
      icon: Stack(
        children: [

          const Icon(Icons.notifications_outlined),

          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          )

        ],
      ),
    ),

    PopupMenuButton<String>(
      icon: const CircleAvatar(
        radius: 16,
        child: Icon(Icons.person),
      ),

      onSelected: (value) async {

        switch(value){

          case "logout":

            final logout = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Logout"),
                content: const Text(
                    "Yakin ingin keluar dari akun Admin?"
                ),
                actions: [

                  TextButton(
                    onPressed: (){
                      Navigator.pop(context,false);
                    },
                    child: const Text("Batal"),
                  ),

                  ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context,true);
                    },
                    child: const Text("Logout"),
                  )

                ],
              ),
            );

            if(logout==true){
              await ref.read(authNotifierProvider.notifier).logout();
             

            }

            break;

        }

      },

      itemBuilder: (_)=>[

        const PopupMenuItem(
          value: "logout",
          child: Row(
            children: [

              Icon(Icons.logout),

              SizedBox(width:10),

              Text("Logout")

            ],
          ),
        )

      ],
    )

  ],
),

      floatingActionButton: FloatingActionButton(
      backgroundColor: AppColors.gold,
      child: const Icon(Icons.add),
      onPressed: (){

        showModalBottomSheet(

          context: context,

          builder: (_){

            return SafeArea(

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  ListTile(

                    leading: const Icon(Icons.person_add),

                    title: const Text("Tambah Barber"),

                    onTap: (){
                      Navigator.pop(context);
                      context.push(RouteNames.adminBarberAdd);
                    },

                  ),

                  ListTile(

                    leading: const Icon(Icons.design_services),

                    title: const Text("Tambah Service"),

                    onTap: (){
                      Navigator.pop(context);
                      context.push(RouteNames.adminServiceAdd);
                    },

                  ),

                  ListTile(

                    leading: const Icon(Icons.image),

                    title: const Text("Tambah Banner"),

                    onTap: (){
                      Navigator.pop(context);
                      context.push(RouteNames.adminBannerAdd);
                    },

                  ),

                ],

              ),

            );

          },

        );

      },

    ),

      body: statsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading dashboard...'),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(adminStatsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminStatsProvider),
          color: AppColors.gold,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                    "Welcome back,",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  Text(
                    user?.nama ?? "Administrator",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    Formatters.greeting(),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      context,
                      icon: Icons.people,
                      title: 'Total Customers',
                      value: '${stats.totalCustomers}',
                      color: AppColors.infoBlue,
                    ).animate(delay: 200.ms).fadeIn().scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                        ),
                    _buildStatCard(
                      context,
                      icon: Icons.book_online,
                      title: "Today's Bookings",
                      value: '${stats.todayBookings}',
                      color: AppColors.accentOrange,
                    ).animate(delay: 300.ms).fadeIn().scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                        ),
                    _buildStatCard(
                      context,
                      icon: Icons.pending_actions,
                      title: 'Pending',
                      value: '${stats.pendingBookings}',
                      color: AppColors.warningAmber,
                    ).animate(delay: 400.ms).fadeIn().scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                        ),
                    _buildStatCard(
                      context,
                      icon: Icons.check_circle,
                      title: 'Completed',
                      value: '${stats.completedBookings}',
                      color: AppColors.successGreen,
                    ).animate(delay: 500.ms).fadeIn().scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                        ),
                    _buildStatCard(
                      context,
                      icon: Icons.content_cut,
                      title: 'Active Barbers',
                      value: '${stats.activeBarbers}',
                      color: AppColors.gold,
                    ).animate(delay: 600.ms).fadeIn().scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                        ),
                    _buildStatCard(
                      context,
                      icon: Icons.attach_money,
                      title: 'Revenue',
                      value: Formatters.currency(stats.totalRevenue),
                      color: AppColors.primaryBlack,
                    ).animate(delay: 700.ms).fadeIn().scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                        ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingXXL),

                GridView.count(
                    shrinkWrap: true,

                    physics: NeverScrollableScrollPhysics(),

                    crossAxisCount: 2,

                    mainAxisSpacing: 12,

                    crossAxisSpacing: 12,

                    childAspectRatio: 1.2,

                    children: [

                      _buildQuickAction(
                        context,
                        icon: Icons.people,
                        label: "Customers",
                        color: Colors.blue,
                        onTap: (){
                          context.push(RouteNames.adminCustomerList);
                        },
                      ),

                      _buildQuickAction(
                        context,
                        icon: Icons.content_cut,
                        label: "Barbers",
                        color: AppColors.gold,
                        onTap: (){
                          context.push(RouteNames.adminBarberList);
                        },
                      ),

                      _buildQuickAction(
                        context,
                        icon: Icons.design_services,
                        label: "Services",
                        color: Colors.green,
                        onTap: (){
                          context.push(RouteNames.adminServiceList);
                        },
                      ),

                      _buildQuickAction(
                        context,
                        icon: Icons.book_online,
                        label: "Bookings",
                        color: Colors.orange,
                        onTap: (){
                          context.push(RouteNames.adminBookingList);
                        },
                      ),

                      _buildQuickAction(
                        context,
                        icon: Icons.star,
                        label: "Reviews",
                        color: Colors.amber,
                        onTap: (){
                          context.push(RouteNames.adminReviewList);
                        },
                      ),

                      _buildQuickAction(
                        context,
                        icon: Icons.image,
                        label: "Banner",
                        color: Colors.purple,
                        onTap: (){
                          context.push(RouteNames.adminBannerList);
                        },
                      ),

                      _buildQuickAction(
                        context,
                        icon: Icons.notifications,
                        label: "Notification",
                        color: Colors.red,
                        onTap: (){
                          context.push(RouteNames.adminSendNotification);
                        },
                      ),

                      _buildQuickAction(
                        context,
                        icon: Icons.cloud_upload,
                        label: "Seeder",
                        color: Colors.teal,
                        onTap: (){
                          context.push(RouteNames.adminSeeder);
                        },
                      ),

                    ],
                ).animate(delay: 800.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppDimensions.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.darkGrey,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingLG),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: AppDimensions.shadowSM,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

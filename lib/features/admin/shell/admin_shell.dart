import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      drawer: _AdminDrawer(ref: ref),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final WidgetRef ref;
  
  const _AdminDrawer({required this.ref});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.darkGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.gold,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'BarberBook Management',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Drawer Items
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            route: RouteNames.adminHome,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.content_cut,
            title: 'Barbers',
            route: RouteNames.adminBarberList,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.miscellaneous_services,
            title: 'Services',
            route: RouteNames.adminServiceList,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.book_online,
            title: 'Bookings',
            route: RouteNames.adminBookingList,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people,
            title: 'Customers',
            route: RouteNames.adminCustomerList,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.star,
            title: 'Reviews',
            route: RouteNames.adminReviewList,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.photo_library,
            title: 'Banners',
            route: RouteNames.adminBannerList,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.notifications_active,
            title: 'Send Notification',
            route: RouteNames.adminSendNotification,
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.errorRed),
            title: const Text('Logout', style: TextStyle(color: AppColors.errorRed)),
            onTap: () async {

  // JANGAN TUTUP DRAWER DULU

  await ref.read(authNotifierProvider.notifier).logout();

}
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isActive =
        GoRouterState.of(context).matchedLocation.startsWith(route);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
        child: ListTile(
          leading: Icon(
            icon,
            color: isActive ? AppColors.gold : AppColors.darkGrey,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.primaryBlack : AppColors.charcoal,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          tileColor: isActive ? AppColors.gold.withValues(alpha: 0.08) : AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        ),
      ),
    );
  }
}

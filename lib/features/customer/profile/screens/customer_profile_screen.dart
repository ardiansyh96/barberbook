import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../auth/providers/auth_provider.dart';

/// Customer Profile screen showing user information and settings.
///
/// Features:
/// - User photo (from Firebase Storage) or initial avatar
/// - Name, email, phone number display
/// - Edit Profile navigation
/// - Change Password navigation
/// - Logout with confirmation dialog
class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.whenOrNull(data: (u) => u);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingXL),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.spacingXL),

              // ─── Profile Header ─────────────────────────────────────
              _buildProfileHeader(context, user),

              const SizedBox(height: AppDimensions.spacingXXXL),

              // ─── Account Section ────────────────────────────────────
              _buildSectionTitle(context, 'Account'),
              const SizedBox(height: AppDimensions.spacingSM),

              _buildSettingsTile(
                context,
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your name, phone, and photo',
                onTap: () => context.push(RouteNames.editProfile),
              ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.05),

              _buildSettingsTile(
                context,
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () => context.push(RouteNames.changePassword),
              ).animate(delay: 250.ms).fadeIn().slideX(begin: 0.05),

              const SizedBox(height: AppDimensions.spacingLG),

              // ─── Booking Section ────────────────────────────────────
              _buildSectionTitle(context, 'Bookings'),
              const SizedBox(height: AppDimensions.spacingSM),

              _buildSettingsTile(
                context,
                icon: Icons.calendar_month_outlined,
                title: 'Booking History',
                subtitle: 'View your past and upcoming bookings',
                onTap: () => context.go(RouteNames.customerBooking),
              ).animate(delay: 300.ms).fadeIn().slideX(begin: 0.05),

              const SizedBox(height: AppDimensions.spacingLG),

              // ─── Others Section ─────────────────────────────────────
              _buildSectionTitle(context, 'Others'),
              const SizedBox(height: AppDimensions.spacingSM),

              _buildSettingsTile(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () => context.push(RouteNames.notifications),
              ).animate(delay: 350.ms).fadeIn().slideX(begin: 0.05),

              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () => _showAboutDialog(context),
              ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.05),

              const SizedBox(height: AppDimensions.spacingLG),

              // ─── Logout Button ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, ref),
                  icon: const Icon(Icons.logout, color: AppColors.errorRed),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: AppColors.errorRed),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.errorRed),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ).animate(delay: 450.ms).fadeIn(),

              const SizedBox(height: AppDimensions.spacingXXXL),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Profile Header with Photo ─────────────────────────────────────
  Widget _buildProfileHeader(BuildContext context, user) {
    return Column(
      children: [
        // Photo/Avatar with edit button
        Stack(
          children: [
            // Photo
            GestureDetector(
              onTap: () => context.push(RouteNames.editProfile),
              child: _buildProfilePhoto(user),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            // Edit button overlay
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingLG),

        // Name
        Text(
          user?.nama ?? 'Guest User',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ).animate(delay: 200.ms).fadeIn(),

        // Email
        Text(
          user?.email ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkGrey,
              ),
        ).animate(delay: 300.ms).fadeIn(),

        // Phone number
        if (user?.nomorHP != null && user.nomorHP.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, size: 14, color: AppColors.mediumGrey),
              const SizedBox(width: 4),
              Text(
                user.nomorHP,
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ).animate(delay: 350.ms).fadeIn(),
        ],

        const SizedBox(height: AppDimensions.spacingMD),

        // Edit Profile Button
        OutlinedButton.icon(
          onPressed: () => context.push(RouteNames.editProfile),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Edit Profile'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            side: const BorderSide(color: AppColors.gold),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 10,
            ),
          ),
        ).animate(delay: 400.ms).fadeIn(),
      ],
    );
  }

  // ─── Profile Photo Widget ──────────────────────────────────────────
  Widget _buildProfilePhoto(dynamic user) {
    final photo = user?.photo as String?;

    if (photo != null && photo.isNotEmpty) {
      return CachedImage(
        imageUrl: photo,
        width: 100,
        height: 100,
        borderRadius: 50,
        fit: BoxFit.cover,
      );
    }

    // Fallback to initial avatar
    return CircleAvatar(
      radius: 50,
      backgroundColor: AppColors.gold.withValues(alpha: 0.15),
      child: Text(
        user != null && user.nama.isNotEmpty
            ? user.nama[0].toUpperCase()
            : '?',
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: AppColors.gold,
        ),
      ),
    );
  }

  // ─── Section Title ─────────────────────────────────────────────────
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  // ─── Settings List Tile ────────────────────────────────────────────
  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: AppDimensions.shadowSM,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          onTap: onTap,
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryBlack, size: 20),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: subtitle != null
                ? Text(
                    subtitle,
                    style: TextStyle(color: AppColors.darkGrey, fontSize: 12),
                  )
                : null,
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.mediumGrey,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
          ),
        ),
      ),
    );
  }

  // ─── About Dialog ──────────────────────────────────────────────────
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        title: const Text('BarberBook'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            SizedBox(height: 8),
            Text(
              'A barbershop reservation app for customers to book appointments with their favorite barbers.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ─── Logout Confirmation Dialog ────────────────────────────────────
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go(RouteNames.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

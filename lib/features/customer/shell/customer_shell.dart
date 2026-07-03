import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/fcm_provider.dart';

/// Customer shell widget that wraps the bottom navigation bar.
///
/// Provides a persistent bottom navigation with 4 tabs:
/// 1. Home (dashboard)
/// 2. Search (find barbers/services)
/// 3. Calendar (bookings/history)
/// 4. Profile (user settings)
class CustomerShell extends ConsumerWidget {
  final Widget child;

  const CustomerShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RouteNames.customerHome)) return 0;
    if (location.startsWith(RouteNames.customerSearch)) return 1;
    if (location.startsWith(RouteNames.customerBooking)) return 2;
    if (location.startsWith(RouteNames.customerProfile)) return 3;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.customerHome);
        break;
      case 1:
        context.go(RouteNames.customerSearch);
        break;
      case 2:
        context.go(RouteNames.customerBooking);
        break;
      case 3:
        context.go(RouteNames.customerProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize FCM when customer shell is built
    ref.watch(fcmInitProvider);
    
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onTabTapped(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.accentOrange,
        unselectedItemColor: AppColors.mediumGrey,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

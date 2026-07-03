import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/models/user_model.dart';

/// Provider that streams all customer users from Firestore
final allCustomersProvider = StreamProvider<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseCollections.users)
      .where('role', isEqualTo: 'customer')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList());
});

/// Admin customer management screen showing all registered customers.
///
/// Features:
/// - Real-time customer list from Firestore
/// - Search by name or email
/// - View customer details (name, email, phone, join date)
class AdminCustomerListScreen extends ConsumerStatefulWidget {
  const AdminCustomerListScreen({super.key});

  @override
  ConsumerState<AdminCustomerListScreen> createState() => _AdminCustomerListScreenState();
}

class _AdminCustomerListScreenState extends ConsumerState<AdminCustomerListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(allCustomersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Manage Customers'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(allCustomersProvider)),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingXL),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search customers...',
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

          // Customer list
          Expanded(
            child: customersAsync.when(
              loading: () => const LoadingWidget(message: 'Loading customers...'),
              error: (_, _) => const EmptyStateWidget(icon: Icons.error_outline, title: 'Error loading customers'),
              data: (customers) {
                final filtered = _searchQuery.isEmpty
                    ? customers
                    : customers
                        .where((c) =>
                            c.nama.toLowerCase().contains(_searchQuery) ||
                            c.email.toLowerCase().contains(_searchQuery))
                        .toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.people,
                    title: _searchQuery.isEmpty ? 'No Customers Yet' : 'No Results',
                    description: _searchQuery.isEmpty ? 'Customers will appear here after registration' : null,
                  );
                }

                // Count header
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXL),
                      child: Text(
                        '${filtered.length} customer${filtered.length == 1 ? '' : 's'}',
                        style: const TextStyle(color: AppColors.darkGrey, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSM),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXL),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _buildCustomerCard(filtered[index], index),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(UserModel customer, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      padding: const EdgeInsets.all(AppDimensions.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppDimensions.shadowSM,
      ),
      child: Row(
        children: [
          // Avatar
          customer.photo != null && customer.photo!.isNotEmpty
              ? CircleAvatar(radius: 24, backgroundImage: NetworkImage(customer.photo!))
              : CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.infoBlue.withValues(alpha: 0.12),
                  child: Text(customer.nama.isNotEmpty ? customer.nama[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppColors.infoBlue, fontWeight: FontWeight.w700)),
                ),
          const SizedBox(width: AppDimensions.spacingMD),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text(customer.email, style: const TextStyle(color: AppColors.darkGrey, fontSize: 12)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (customer.nomorHP != null && customer.nomorHP!.isNotEmpty) ...[
                      const Icon(Icons.phone, size: 12, color: AppColors.mediumGrey),
                      const SizedBox(width: 2),
                      Text(customer.nomorHP!, style: const TextStyle(color: AppColors.mediumGrey, fontSize: 11)),
                      const SizedBox(width: AppDimensions.spacingSM),
                    ],
                    const Icon(Icons.calendar_today, size: 12, color: AppColors.mediumGrey),
                    const SizedBox(width: 2),
                    Text(Formatters.dateShort(customer.createdAt),
                        style: const TextStyle(color: AppColors.mediumGrey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 60).ms).fadeIn();
  }
}

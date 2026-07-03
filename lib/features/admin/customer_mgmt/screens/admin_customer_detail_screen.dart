import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/models/user_model.dart';
import '../providers/admin_customer_provider.dart';

      class AdminCustomerDetailScreen extends ConsumerWidget {
        final String customerId;

        const AdminCustomerDetailScreen({
          super.key,
          required this.customerId,
        });

        @override
        Widget build(BuildContext context, WidgetRef ref) {
          final customerAsync =
              ref.watch(customerByIdProvider(customerId));

          final bookingAsync =
              ref.watch(customerBookingProvider(customerId));

          final finishedAsync =
              ref.watch(customerFinishedBookingProvider(customerId));

          final spentAsync =
              ref.watch(customerSpentProvider(customerId));

          return Scaffold(
            backgroundColor: AppColors.backgroundLight,

            appBar: AppBar(
              title: const Text("Customer Detail"),
            ),

            body: customerAsync.when(

              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),

              error: (e, _) => Center(
                child: Text(e.toString()),
              ),

              data: (customer) {

                if (customer == null) {
                  return const Center(
                    child: Text("Customer tidak ditemukan"),
                  );
                }

                return SingleChildScrollView(

                  padding: const EdgeInsets.all(
                    AppDimensions.spacingXL,
                  ),

                  child: Column(

                    children: [

                      _header(customer),

                      const SizedBox(height: 24),

                      _infoCard(customer),

                      const SizedBox(height: 20),

                      Row(

                        children: [

                          Expanded(

                            child: bookingAsync.when(

                              loading: () => _statCard(
                                "Booking",
                                "...",
                                Icons.calendar_month,
                                AppColors.gold,
                              ),

                              error: (_, __) => _statCard(
                                "Booking",
                                "-",
                                Icons.calendar_month,
                                AppColors.gold,
                              ),

                              data: (v) => _statCard(
                                "Booking",
                                "$v",
                                Icons.calendar_month,
                                AppColors.gold,
                              ),

                            ),

                          ),

                          const SizedBox(width: 15),

                          Expanded(

                            child: finishedAsync.when(

                              loading: () => _statCard(
                                "Completed",
                                "...",
                                Icons.check_circle,
                                AppColors.successGreen,
                              ),

                              error: (_, __) => _statCard(
                                "Completed",
                                "-",
                                Icons.check_circle,
                                AppColors.successGreen,
                              ),

                              data: (v) => _statCard(
                                "Completed",
                                "$v",
                                Icons.check_circle,
                                AppColors.successGreen,
                              ),

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height: 15),

                      spentAsync.when(

                        loading: () => _moneyCard("..."),

                        error: (_, __) => _moneyCard("-"),

                        data: (value) => _moneyCard(
                          Formatters.currency(value),
                        ),

                      ),

                      const SizedBox(height: 30),

                      SizedBox(

                        width: double.infinity,

                        child: OutlinedButton.icon(

                          icon: const Icon(Icons.delete),

                          label: const Text(
                            "Delete Customer",
                          ),

                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.errorRed,
                          ),

                          onPressed: () async {

                            final result =
                                await showDialog<bool>(

                              context: context,

                              builder: (_) => AlertDialog(

                                title: const Text(
                                  "Delete Customer",
                                ),

                                content: Text(
                                  "Yakin ingin menghapus ${customer.nama} ?",
                                ),

                                actions: [

                                  TextButton(

                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                        false,
                                      );
                                    },

                                    child: const Text(
                                      "Batal",
                                    ),

                                  ),

                                  ElevatedButton(

                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                        true,
                                      );
                                    },

                                    child: const Text(
                                      "Hapus",
                                    ),

                                  ),

                                ],

                              ),

                            );

                            if (result != true) return;

                            try {

                              await ref
                                  .read(customerServiceProvider)
                                  .deleteCustomer(customer.uid);

                              if (context.mounted) {

                                SnackbarHelper.success(
                                  context,
                                  "Customer berhasil dihapus",
                                );

                                context.pop();

                              }

                            } catch (e) {

                              SnackbarHelper.error(
                                context,
                                e.toString(),
                              );

                            }

                          },

                        ),

                      ),

                    ],

                  ).animate().fadeIn(),

                );

              },

            ),

          );

        }

        Widget _header(UserModel customer) {

        return Column(

          children: [

            customer.photo != null &&
                    customer.photo!.isNotEmpty

                ? CircleAvatar(

                    radius: 55,

                    backgroundImage:
                        CachedNetworkImageProvider(
                      customer.photo!,
                    ),

                  )

                : const CircleAvatar(

                    radius: 55,

                    backgroundColor:
                        AppColors.lightGrey,

                    child: Icon(

                      Icons.person,

                      size: 55,

                      color: AppColors.mediumGrey,

                    ),

                  ),

            const SizedBox(height: 15),

            Text(

              customer.nama,

              style: const TextStyle(

                fontSize: 24,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 5),

            Container(

              padding: const EdgeInsets.symmetric(

                horizontal: 14,

                vertical: 5,

              ),

              decoration: BoxDecoration(

                color: AppColors.successGreen
                    .withValues(alpha: .12),

                borderRadius:
                    BorderRadius.circular(20),

              ),

              child: const Text(

                "CUSTOMER",

                style: TextStyle(

                  color: AppColors.successGreen,

                  fontWeight: FontWeight.bold,

                ),

              ),

            ),

          ],

        );

      }

      Widget _infoCard(UserModel customer) {

        return Card(

          elevation: 1,

          shape: RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(18),

          ),

          child: Padding(

            padding: const EdgeInsets.all(20),

            child: Column(

              children: [

                _infoRow(

                  Icons.email,

                  "Email",

                  customer.email,

                ),

                const Divider(),

                _infoRow(

                  Icons.phone,

                  "Nomor HP",

                  customer.nomorHP ?? "-",

                ),

                const Divider(),

                _infoRow(

                  Icons.calendar_today,

                  "Bergabung",

                  Formatters.date(customer.createdAt),

                ),

              ],

            ),

          ),

        );

      }

      Widget _infoRow(

        IconData icon,

        String title,

        String value,

      ) {

        return Padding(

          padding: const EdgeInsets.symmetric(

            vertical: 10,

          ),

          child: Row(

            children: [

              Icon(

                icon,

                color: AppColors.gold,

              ),

              const SizedBox(width: 15),

              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(

                      title,

                      style: const TextStyle(

                        color:
                            AppColors.mediumGrey,

                        fontSize: 12,

                      ),

                    ),

                    const SizedBox(height: 2),

                    Text(

                      value,

                      style: const TextStyle(

                        fontWeight:
                            FontWeight.w600,

                        fontSize: 15,

                      ),

                    ),

                  ],

                ),

              ),

            ],

          ),

        );

      }

      Widget _statCard(

        String title,

        String value,

        IconData icon,

        Color color,

      ) {

        return Container(

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(18),

            boxShadow:
                AppDimensions.shadowSM,

          ),

          child: Column(

            children: [

              Container(

                width: 50,

                height: 50,

                decoration: BoxDecoration(

                  color: color.withValues(alpha: .12),

                  borderRadius:
                      BorderRadius.circular(14),

                ),

                child: Icon(

                  icon,

                  color: color,

                ),

              ),

              const SizedBox(height: 12),

              Text(

                value,

                style: const TextStyle(

                  fontWeight: FontWeight.bold,

                  fontSize: 22,

                ),

              ),

              const SizedBox(height: 5),

              Text(

                title,

                style: const TextStyle(

                  color:
                      AppColors.mediumGrey,

                ),

              ),

            ],

          ),

        );

      }

      Widget _moneyCard(

        String total,

      ) {

        return Container(

          width: double.infinity,

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(18),

            boxShadow:
                AppDimensions.shadowSM,

          ),

          child: Row(

            children: [

              Container(

                width: 60,

                height: 60,

                decoration: BoxDecoration(

                  color: AppColors.gold
                      .withValues(alpha: .12),

                  borderRadius:
                      BorderRadius.circular(16),

                ),

                child: const Icon(

                  Icons.payments,

                  color: AppColors.gold,

                  size: 30,

                ),

              ),

              const SizedBox(width: 20),

              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(

                      "Total Pengeluaran",

                      style: TextStyle(

                        color:
                            AppColors.mediumGrey,

                      ),

                    ),

                    const SizedBox(height: 4),

                    Text(

                      total,

                      style: const TextStyle(

                        fontWeight:
                            FontWeight.bold,

                        fontSize: 24,

                      ),

                    ),

                  ],

                ),

              ),

            ],

          ),

        );

      }

      }
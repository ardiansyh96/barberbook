import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../customer/booking/models/booking_model.dart';
import '../providers/admin_booking_provider.dart';

class AdminBookingDetailScreen extends ConsumerWidget {
  final String bookingId;

  const AdminBookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync =
        ref.watch(adminBookingDetailProvider(bookingId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Booking Detail"),
      ),

      body: bookingAsync.when(

        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (booking) {

          if (booking == null) {
            return const Center(
              child: Text("Booking tidak ditemukan"),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [

              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Customer"),
                  subtitle: Text(
                    booking.customerNama ?? "-",
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.content_cut),
                  title: const Text("Barber"),
                  subtitle: Text(
                    booking.barberNama ?? "-",
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.design_services),
                  title: const Text("Service"),
                  subtitle: Text(
                    booking.serviceNama ?? "-",
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text("Tanggal"),
                  subtitle: Text(
                    Formatters.dateLong(
                      booking.tanggal,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text("Jam"),
                  subtitle: Text(
                    booking.jam,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.payments),
                  title: const Text("Total"),
                  subtitle: Text(
                    Formatters.currency(
                      booking.totalHarga,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("Status"),
                  subtitle: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(booking.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.notes),
                  title: const Text("Catatan"),
                  subtitle: Text(

                    booking.catatan == null ||
                    booking.catatan!.trim().isEmpty

                    ? "-"

                    : booking.catatan!,

                    ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),

              const SizedBox(height: 20),

              const Text(
                "Booking Timeline",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _timelineTile(
                Icons.book_online,
                "Booking Dibuat",
                booking.createdAt,
              ),

              if (booking.confirmedAt != null)
                _timelineTile(
                  Icons.check_circle,
                  "Booking Dikonfirmasi",
                  booking.confirmedAt!,
                ),

              if (booking.processingAt != null)
                _timelineTile(
                  Icons.content_cut,
                  "Sedang Diproses",
                  booking.processingAt!,
                ),

              if (booking.completedAt != null)
                _timelineTile(
                  Icons.done_all,
                  "Booking Selesai",
                  booking.completedAt!,
                ),

              if (booking.cancelledAt != null)
                _timelineTile(
                  Icons.cancel,
                  "Booking Dibatalkan",
                  booking.cancelledAt!,
                ),

              const SizedBox(height: 20),

              ..._buildActionButtons(
              context,
              ref,
              booking,
            ),
            ]
          );
        },

      ),
    );
  }
    Widget _timelineTile(
    IconData icon,
    String title,
    DateTime date,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.gold,
        ),
        title: Text(title),
        subtitle: Text(
          Formatters.dateFull(date),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;

      case "confirmed":
        return Colors.blue; 

      case "processing":
        return Colors.purple;

      case "completed":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      case "rejected":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  List<Widget> _buildActionButtons(
  BuildContext context,
  WidgetRef ref,
  BookingModel booking,
) {

  switch (booking.status) {

    case "pending":

      return [

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(

            icon: const Icon(Icons.check),

            label: const Text("Confirm Booking"),

            onPressed: () async {

              await ref
                  .read(adminBookingServiceProvider)
                  .confirmBooking(booking.id);

              if(context.mounted){

                  ScaffoldMessenger.of(context).showSnackBar(

                    const SnackBar(
                      content: Text("Booking berhasil dikonfirmasi"),
                    ),

                  );

                  Navigator.pop(context);

              }

            },

          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(

            icon: const Icon(Icons.close),

            label: const Text("Reject"),

            onPressed: () async {

              await _showRejectDialog(
              context,
              ref,
              booking.id,
            );

            },

          ),
        ),

      ];

    case "confirmed":

      return [

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(

            icon: const Icon(Icons.play_arrow),

            label: const Text("Start Haircut"),

            onPressed: () async {

              await ref
                  .read(adminBookingServiceProvider)
                  .startBooking(booking.id);

              if(context.mounted){
                Navigator.pop(context);
              }

            },

          ),
        ),

      ];

    case "processing":

      return [

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(

            icon: const Icon(Icons.done),

            label: const Text("Complete Booking"),

            onPressed: () async {

              await ref
                  .read(adminBookingServiceProvider)
                  .completeBooking(booking.id);

              if(context.mounted){
                Navigator.pop(context);
              }

            },

          ),
        ),

      ];

    default:

      return [];

  }

}

Future<void> _showRejectDialog(
  BuildContext context,
  WidgetRef ref,
  String bookingId,
) async {

  final controller = TextEditingController();

  await showDialog(

    context: context,

    builder: (_) {

      return AlertDialog(

        title: const Text("Reject Booking"),

        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Masukkan alasan penolakan",
          ),
        ),

        actions: [

          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),

          ElevatedButton(

            onPressed: () async {

              if(controller.text.trim().isEmpty){
                return;
              }

              await ref
                  .read(adminBookingServiceProvider)
                  .rejectBooking(
                    bookingId,
                    controller.text.trim(),
                  );

              if(context.mounted){

                Navigator.pop(context); // tutup dialog
                Navigator.pop(context); // kembali ke list

              }

            },

            child: const Text("Reject"),

          ),

        ],

      );

    },

  );

}
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../customer/service/providers/service_provider.dart';
import '../../../../core/router/route_names.dart';

class AdminServiceDetailScreen extends ConsumerWidget {
  final String serviceId;

  const AdminServiceDetailScreen({
    super.key,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final serviceAsync =
        ref.watch(serviceByIdProvider(serviceId));

    return Scaffold(

      appBar: AppBar(
        title: const Text("Service Detail"),
      ),

      body: serviceAsync.when(

        loading: () =>
            const Center(
              child: CircularProgressIndicator(),
            ),

        error: (e, _) =>
            Center(
              child: Text(e.toString()),
            ),

        data: (service) {

          if (service == null) {
            return const Center(
              child: Text("Service tidak ditemukan"),
            );
          }

          return ListView(

            padding: const EdgeInsets.all(20),

            children: [

              _item(
                "Nama",
                service.nama,
              ),

              _item(
                "Kategori",
                service.kategori,
              ),

              _item(
                "Harga",
                Formatters.currency(service.harga),
              ),

              _item(
                "Durasi",
                "${service.durasi} menit",
              ),

              Card(
                child: ListTile(
                  title: const Text("Status"),
                  subtitle: Text(
                    service.aktif
                        ? "Aktif"
                        : "Nonaktif",
                    style: TextStyle(
                      color: service.aktif
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              _item(
                "Deskripsi",
                service.deskripsi.isEmpty
                    ? "-"
                    : service.deskripsi,
              ),

              _item(
                "Created",
                Formatters.dateFull(service.createdAt),
              ),

              const SizedBox(height: 30),

             SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Service"),
                  onPressed: () {
                    context.push(
                      RouteNames.adminServiceEdit.replaceFirst(
                        ":serviceId",
                        serviceId,
                      ),
                    );
                  },
                ),
              ),

            ],

          );

        },

      ),

    );

  }

  Widget _item(
    String title,
    String value,
  ) {

    return Card(

      margin:
          const EdgeInsets.only(bottom: 12),

      child: ListTile(

        title: Text(title),

        subtitle: Text(value),

      ),

    );

  }

}
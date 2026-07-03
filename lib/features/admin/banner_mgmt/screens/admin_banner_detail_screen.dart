import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/router/route_names.dart';
import '../providers/admin_banner_provider.dart';

class AdminBannerDetailScreen extends ConsumerWidget {
  final String bannerId;

  const AdminBannerDetailScreen({
    super.key,
    required this.bannerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAsync = ref.watch(
      bannerByIdProvider(bannerId),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      appBar: AppBar(
        title: const Text("Banner Detail"),
      ),

      body: bannerAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (banner) {
          if (banner == null) {
            return const Center(
              child: Text(
                "Banner tidak ditemukan",
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),

            children: [

              //--------------------------------------------------
              // IMAGE
              //--------------------------------------------------

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(16),

                child: AspectRatio(
                  aspectRatio: 16 / 9,

                  child: Image.network(
                    banner.gambar,

                    fit: BoxFit.cover,

                    errorBuilder:
                        (_, __, ___) {

                      return Container(
                        color: Colors.grey.shade300,

                        child: const Icon(
                          Icons.image,
                          size: 70,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // JUDUL
              //--------------------------------------------------

              _item(
                "Judul",
                banner.judul,
              ),

              //--------------------------------------------------
              // DESKRIPSI
              //--------------------------------------------------

              _item(
                "Deskripsi",
                banner.deskripsi ?? "-",
              ),

              //--------------------------------------------------
              // STATUS
              //--------------------------------------------------

              _item(
                "Status",
                banner.aktif
                    ? "Aktif"
                    : "Nonaktif",
              ),

              //--------------------------------------------------
              // LINK
              //--------------------------------------------------

              _item(
                "Link Target",
                banner.linkTarget ?? "-",
              ),

              //--------------------------------------------------
              // URUTAN
              //--------------------------------------------------

              _item(
                "Urutan",
                banner.urutan.toString(),
              ),

              //--------------------------------------------------
              // CREATED
              //--------------------------------------------------

              _item(
                "Created",
                Formatters.dateFull(
                  banner.createdAt,
                ),
              ),

              const SizedBox(height: 30),

              //--------------------------------------------------
              // EDIT
              //--------------------------------------------------

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.edit,
                  ),

                  label: const Text(
                    "Edit Banner",
                  ),

                  onPressed: () {

                    context.push(
                      RouteNames.adminBannerEdit
                          .replaceFirst(
                        ":bannerId",
                        banner.id,
                      ),
                    );

                  },
                ),
              ),

              const SizedBox(height: 15),

              //--------------------------------------------------
              // DELETE
              //--------------------------------------------------

              SizedBox(
                width: double.infinity,

                child: OutlinedButton.icon(

                  icon: const Icon(
                    Icons.delete,
                  ),

                  label: const Text(
                    "Delete Banner",
                  ),

                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.red,
                  ),

                  onPressed: () async {

                    final confirm =
                        await showDialog<bool>(

                      context: context,

                      builder: (_) =>
                          AlertDialog(

                        title: const Text(
                          "Delete Banner",
                        ),

                        content:
                            const Text(
                          "Yakin ingin menghapus banner ini?",
                        ),

                        actions: [

                          TextButton(

                            onPressed: () {

                              Navigator.pop(
                                context,
                                false,
                              );

                            },

                            child:
                                const Text(
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

                            child:
                                const Text(
                              "Hapus",
                            ),

                          ),

                        ],

                      ),

                    );

                    if (confirm != true) {
                      return;
                    }

                    await ref
                        .read(
                          bannerServiceProvider,
                        )
                        .deleteBanner(
                          banner.id,
                        );

                    if (context.mounted) {

                      context.pop();

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(

                        const SnackBar(
                          content: Text(
                            "Banner berhasil dihapus",
                          ),
                        ),

                      );

                    }

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
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
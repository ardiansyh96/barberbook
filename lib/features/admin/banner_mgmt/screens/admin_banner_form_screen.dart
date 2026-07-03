import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_text_field.dart';

import '../models/banner_model.dart';
import '../providers/admin_banner_provider.dart';

class AdminBannerFormScreen extends ConsumerStatefulWidget {
  final String? bannerId;

  const AdminBannerFormScreen({
    super.key,
    this.bannerId,
  });

  @override
  ConsumerState<AdminBannerFormScreen> createState() =>
      _AdminBannerFormScreenState();
}

class _AdminBannerFormScreenState
    extends ConsumerState<AdminBannerFormScreen> {

  final _formKey = GlobalKey<FormState>();

  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _linkController = TextEditingController();
  final _urutanController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();

  File? _selectedImage;

  String? _imageUrl;

  bool _aktif = true;

  bool _loading = false;

  bool get isEdit =>
      widget.bannerId != null &&
      widget.bannerId!.isNotEmpty;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      _loadBanner();
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _linkController.dispose();
    _urutanController.dispose();
    super.dispose();
  }

  Future<void> _loadBanner() async {

    setState(() {
      _loading = true;
    });

    try {

      final banner = await ref.read(
        bannerByIdProvider(
          widget.bannerId!,
        ).future,
      );

      if (banner != null) {

        _judulController.text =
            banner.judul;

        _deskripsiController.text =
            banner.deskripsi ?? "";

        _linkController.text =
            banner.linkTarget ?? "";

        _urutanController.text =
            banner.urutan.toString();

        _aktif =
            banner.aktif;

        _imageUrl =
            banner.gambar;

      }

    } catch (e) {

      if (mounted) {

        SnackbarHelper.error(
          context,
          e.toString(),
        );

      }

    }

    if (mounted) {

      setState(() {

        _loading = false;

      });

    }

  }

  Future<void> _pickImage() async {

    final file = await _picker.pickImage(

      source: ImageSource.gallery,

      imageQuality: 80,

    );

    if (file == null) return;

    setState(() {

      _selectedImage =
          File(file.path);

    });

  }
    Future<String?> _uploadImage() async {

    if (_selectedImage == null) {
      return _imageUrl;
    }

    return await _storageService.uploadBannerImage(
      _selectedImage!,
    );

  }

  Future<void> _saveBanner() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {

      final imageUrl = await _uploadImage();

      final banner = BannerModel(

        id: widget.bannerId ?? "",

        gambar: imageUrl ?? "",

        judul: _judulController.text.trim(),

        deskripsi:
            _deskripsiController.text.trim(),

        linkTarget:
            _linkController.text.trim(),

        urutan:
            int.tryParse(
                  _urutanController.text,
                ) ??
                0,

        aktif: _aktif,

        createdAt: DateTime.now(),

      );

      final service = ref.read(
        bannerServiceProvider,
      );

      if (isEdit) {

        await service.updateBanner(
          widget.bannerId!,
          banner.toJson(),
        );

      } else {

        await service.createBanner(
          banner,
        );

      }

      if (!mounted) return;

      SnackbarHelper.success(

        context,

        isEdit
            ? "Banner berhasil diupdate"
            : "Banner berhasil ditambahkan",

      );

      context.pop();

    } catch (e) {

      if (mounted) {

        SnackbarHelper.error(
          context,
          e.toString(),
        );

      }

    }

    if (mounted) {

      setState(() {

        _loading = false;

      });

    }

  }

  Future<void> _deleteBanner() async {

    if (!isEdit) return;

    final confirm = await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Delete Banner",
          ),

          content: const Text(
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

        );

      },

    );

    if (confirm != true) {
      return;
    }

    await ref
        .read(
          bannerServiceProvider,
        )
        .deleteBanner(
          widget.bannerId!,
        );

    if (!mounted) return;

    SnackbarHelper.success(
      context,
      "Banner berhasil dihapus",
    );

    context.go(
      RouteNames.adminBannerList,
    );

  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {

      return const Scaffold(

        body: Center(

          child:
              CircularProgressIndicator(),

        ),

      );

    }
return Scaffold(

  backgroundColor: AppColors.backgroundLight,

  appBar: AppBar(

    title: Text(

      isEdit
          ? "Edit Banner"
          : "Tambah Banner",

    ),

    actions: [

      TextButton(

        onPressed:
            _loading
                ? null
                : _saveBanner,

        child: const Text(
          "SAVE",
        ),

      ),

    ],

  ),

  body: SingleChildScrollView(

    padding: const EdgeInsets.all(
      AppDimensions.spacingXL,
    ),

    child: Form(

      key: _formKey,

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Center(

            child: GestureDetector(

              onTap: _pickImage,

              child: Container(

                height: 220,

                width: double.infinity,

                decoration: BoxDecoration(

                  color: Colors.grey.shade200,

                  borderRadius:
                      BorderRadius.circular(18),

                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),

                ),

                child: _selectedImage != null

                    ? ClipRRect(

                        borderRadius:
                            BorderRadius.circular(
                                18),

                        child: Image.file(

                          _selectedImage!,

                          fit: BoxFit.cover,

                        ),

                      )

                    : _imageUrl != null &&
                            _imageUrl!.isNotEmpty

                        ? ClipRRect(

                            borderRadius:
                                BorderRadius.circular(
                                    18),

                            child: Image.network(

                              _imageUrl!,

                              fit: BoxFit.cover,

                            ),

                          )

                        : Column(

                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [

                              Icon(

                                Icons.image,

                                size: 60,

                                color: Colors.grey.shade700,

                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              const Text(

                                "Tap untuk memilih gambar",

                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                ),

                              ),

                            ],

                          ),

              ),

            ),

          ),

          const SizedBox(height: 25),

          CustomTextField(

            controller:
                _judulController,

            label: "Judul Banner",

            hintText:
                "Promo Haircut",

            prefixIcon:
                Icons.campaign,

            validator: (value) {

              if (value == null ||
                  value.trim().isEmpty) {

                return "Judul wajib diisi";

              }

              return null;

            },

          ),

          const SizedBox(height: 20),

          CustomTextField(

            controller:
                _deskripsiController,

            label: "Deskripsi",

            hintText:
                "Promo bulan Juli",

            prefixIcon:
                Icons.description,

            maxLines: 4,

          ),

          const SizedBox(height: 20),

          CustomTextField(

            controller:
                _linkController,

            label: "Link Target",

            hintText:
                "/customer/home",

            prefixIcon:
                Icons.link,

          ),

          const SizedBox(height: 20),

          CustomTextField(

            controller:
                _urutanController,

            label: "Urutan",

            hintText: "1",

            prefixIcon:
                Icons.sort,

            keyboardType:
                TextInputType.number,

            validator: (value) {

              if (value == null ||
                  value.isEmpty) {

                return "Urutan wajib diisi";

              }

              return null;

            },

          ),

          const SizedBox(height: 25),

          Card(

            child: SwitchListTile(

              value: _aktif,

              activeThumbColor:
                  AppColors.gold,

              title: const Text(

                "Banner Aktif",

              ),

              subtitle: Text(

                _aktif

                    ? "Banner tampil ke Customer"

                    : "Banner disembunyikan",

              ),

              onChanged: (value) {

                setState(() {

                  _aktif = value;

                });

              },

            ),

          ),

          const SizedBox(height: 30),

          SizedBox(

            width: double.infinity,

            height: 52,

            child: ElevatedButton.icon(

              icon: const Icon(
                Icons.save,
              ),

              label: Text(

                isEdit

                    ? "UPDATE BANNER"

                    : "SIMPAN BANNER",

              ),

              onPressed: _saveBanner,

            ),

          ),

          if (isEdit) ...[

            const SizedBox(height: 15),

            SizedBox(

              width: double.infinity,

              height: 52,

              child: OutlinedButton.icon(

                icon: const Icon(
                  Icons.delete,
                ),

                label: const Text(
                  "DELETE BANNER",
                ),

                style:
                    OutlinedButton.styleFrom(

                  foregroundColor:
                      Colors.red,

                ),

                onPressed:
                    _deleteBanner,

              ),

            ),

          ],

        ],

      ),

    ),

  ),

);

}

}
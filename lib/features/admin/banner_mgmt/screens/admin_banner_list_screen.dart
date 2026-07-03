import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../models/banner_model.dart';
import '../providers/admin_banner_provider.dart';

/// Admin banner management screen with inline add/edit form.
///
/// Features:
/// - List all banners with active/inactive status
/// - Toggle active status inline
/// - Add new banner with image upload
/// - Delete banner with confirmation
/// - Real-time list from Firestore
class AdminBannerListScreen extends ConsumerStatefulWidget {
  const AdminBannerListScreen({super.key});

  @override
  ConsumerState<AdminBannerListScreen> createState() => _AdminBannerListScreenState();
}

class _AdminBannerListScreenState extends ConsumerState<AdminBannerListScreen> {
  bool _showForm = false;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _linkController = TextEditingController();
  final _orderController = TextEditingController(text: '0');
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _linkController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _showForm = false;
      _titleController.clear();
      _descController.clear();
      _linkController.clear();
      _orderController.text = '0';
      _selectedImage = null;
    });
  }

  Future<void> _saveBanner() async {
    if (_titleController.text.trim().isEmpty || _selectedImage == null) {
      SnackbarHelper.error(context, 'Title and image are required');
      return;
    }
    setState(() => _isSaving = true);

    try {
      // Upload image first
      final imageUrl = await StorageService().uploadBannerImage(_selectedImage!);

      final service = ref.read(bannerServiceProvider);
      await service.createBanner(BannerModel(
        id: '',
        gambar: imageUrl,
        judul: _titleController.text.trim(),
        deskripsi: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        linkTarget: _linkController.text.trim().isNotEmpty ? _linkController.text.trim() : null,
        urutan: int.tryParse(_orderController.text) ?? 0,
        createdAt: DateTime.now(),
      ));

      if (mounted) {
        SnackbarHelper.success(context, 'Banner created!');
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        SnackbarHelper.error(context, 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(allBannersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
  title: const Text('Manage Banners'),

  leading: Builder(
    builder: (context) => IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    ),
  ),

  actions: [

    if (!_showForm)
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Add Banner',
        onPressed: () {
          context.push(RouteNames.adminBannerAdd);
        },
      ),

    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        ref.invalidate(allBannersProvider);
      },
    ),

  ],

),
      body: Column(
        children: [
          // Add form
          if (_showForm) _buildAddForm(),

          // Banner list
          Expanded(
            child: bannersAsync.when(
              loading: () => const LoadingWidget(message: 'Loading banners...'),
              error: (_, _) => const EmptyStateWidget(icon: Icons.error_outline, title: 'Error loading banners'),
              data: (banners) {
                if (banners.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.photo_library,
                    title: 'No Banners Yet',
                    description: 'Add a promotional banner',
                    actionText: 'Add Banner',
                    onAction: () => setState(() => _showForm = true),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.spacingXL),
                  itemCount: banners.length,
                  itemBuilder: (context, index) => _buildBannerCard(banners[index], index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXL),
      margin: const EdgeInsets.all(AppDimensions.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppDimensions.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('New Banner', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              IconButton(icon: const Icon(Icons.close), onPressed: _resetForm),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),

          // Image picker
          GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
              if (img != null) setState(() => _selectedImage = File(img.path));
            },
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(color: AppColors.mediumGrey, style: BorderStyle.solid),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, color: AppColors.gold, size: 36),
                        SizedBox(height: 8),
                        Text('Tap to select image', style: TextStyle(color: AppColors.darkGrey)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMD),

          CustomTextField(
            controller: _titleController,
            label: 'Title',
            hintText: 'Banner title',
            prefixIcon: Icons.title,
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          CustomTextField(
            controller: _descController,
            label: 'Description (optional)',
            hintText: 'Short description',
            prefixIcon: Icons.description_outlined,
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _linkController,
                  label: 'Link (optional)',
                  hintText: '/route or URL',
                  prefixIcon: Icons.link,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              SizedBox(
                width: 100,
                child: CustomTextField(
                  controller: _orderController,
                  label: 'Order',
                  hintText: '0',
                  prefixIcon: Icons.sort,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveBanner,
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Banner'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildBannerCard(BannerModel banner, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppDimensions.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG)),
            child: CachedImage(
              imageUrl: banner.gambar,
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMD),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(banner.judul, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      if (banner.deskripsi != null)
                        Text(banner.deskripsi!, style: const TextStyle(color: AppColors.darkGrey, fontSize: 12)),
                      Text('Order: ${banner.urutan}', style: const TextStyle(color: AppColors.mediumGrey, fontSize: 11)),
                    ],
                  ),
                ),
                // Active toggle
                Switch(
                  value: banner.aktif,
                  activeTrackColor: AppColors.successGreen,
                  onChanged: (v) async {
                    await ref.read(bannerServiceProvider).toggleBanner(banner.id, v);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                  onPressed: () => _confirmDelete(banner),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 60).ms).fadeIn();
  }

  Future<void> _confirmDelete(BannerModel banner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Banner'),
        content: Text('Delete "${banner.judul}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(bannerServiceProvider).deleteBanner(banner.id);
        if (mounted) {
          SnackbarHelper.success(context, 'Banner deleted');
        }
      } catch (e) {
        if (mounted) {
          SnackbarHelper.error(context, 'Failed: $e');
        }
      }
    }
  }
}

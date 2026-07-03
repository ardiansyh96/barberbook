import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../auth/providers/auth_provider.dart';

/// Edit Profile screen allowing users to update their profile information.
///
/// Features:
/// - Change profile photo (from camera or gallery)
/// - Update name
/// - Update phone number
/// - Upload photo to Firebase Storage
/// - Update Firestore user document
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _selectedImage;
  String? _currentPhoto;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Load current user data into form fields
  void _loadUserData() {
    final user = ref.read(authStateProvider).whenOrNull(data: (u) => u);
    if (user != null) {
      _nameController.text = user.nama;
      _phoneController.text = user.nomorHP ?? '';
      _currentPhoto = user.photo;
    }
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.error(context, 'Failed to pick image: $e');
      }
    }
  }

  /// Show bottom sheet for image source selection
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryBlack),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryBlack),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null || _currentPhoto != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                  title: const Text('Remove Photo', style: TextStyle(color: AppColors.errorRed)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _currentPhoto = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Save profile changes
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final user = ref.read(authStateProvider).whenOrNull(data: (u) => u);
    if (user == null) {
      setState(() => _isSaving = false);
      SnackbarHelper.error(context, 'No user logged in');
      return;
    }

    try {
      // Upload photo if selected
      String? photoUrl = _currentPhoto;
      if (_selectedImage != null) {
        final storageService = StorageService();
        photoUrl = await storageService.uploadProfilePhoto(
          _selectedImage!,
          user.uid,
        );
      }

      // Build updates map
      final updates = <String, dynamic>{
        'nama': _nameController.text.trim(),
        'nomorHP': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'photo': photoUrl,
      };

      // Update profile in Firestore
      await ref.read(authServiceProvider).updateProfile(user.uid, updates);

      if (mounted) {
        SnackbarHelper.success(context, 'Profile updated successfully!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        SnackbarHelper.error(context, 'Failed to update profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimensions.spacingLG),

              // ─── Profile Photo ──────────────────────────────────────
              _buildPhotoSection(),
              const SizedBox(height: AppDimensions.spacingXXXL),

              // ─── Name Field ─────────────────────────────────────────
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingLG),

              // ─── Phone Field ────────────────────────────────────────
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hintText: 'Enter your phone number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length < 10) {
                      return 'Phone number seems too short';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingLG),

              // ─── Email (read-only) ──────────────────────────────────
              _buildEmailField(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Photo Section ─────────────────────────────────────────────────
  Widget _buildPhotoSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _showImageSourceSheet,
          child: Stack(
            children: [
              // Photo preview
              _buildPhotoPreview(),

              // Camera overlay
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 3),
                    boxShadow: AppDimensions.shadowMD,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSM),
        TextButton(
          onPressed: _showImageSourceSheet,
          child: const Text(
            'Change Photo',
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Photo Preview ─────────────────────────────────────────────────
  Widget _buildPhotoPreview() {
    // Show selected new image first
    if (_selectedImage != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(_selectedImage!),
      );
    }

    // Show current photo from storage
    if (_currentPhoto != null && _currentPhoto!.isNotEmpty) {
      return CachedImage(
        imageUrl: _currentPhoto!,
        width: 120,
        height: 120,
        borderRadius: 60,
        fit: BoxFit.cover,
      );
    }

    // Fallback to initial avatar
    final user = ref.read(authStateProvider).whenOrNull(data: (u) => u);
    return CircleAvatar(
      radius: 60,
      backgroundColor: AppColors.gold.withValues(alpha: 0.15),
      child: Text(
        user != null && user.nama.isNotEmpty
            ? user.nama[0].toUpperCase()
            : '?',
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: AppColors.gold,
        ),
      ),
    );
  }

  // ─── Email Field (Read-only) ───────────────────────────────────────
  Widget _buildEmailField() {
    final user = ref.read(authStateProvider).whenOrNull(data: (u) => u);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLG),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        children: [
          const Icon(Icons.email_outlined, color: AppColors.mediumGrey),
          const SizedBox(width: AppDimensions.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Email',
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
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
}

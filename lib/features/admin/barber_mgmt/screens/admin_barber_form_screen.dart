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
import '../../../customer/barber/models/barber_model.dart';
import '../../../customer/barber/providers/barber_provider.dart';

/// Admin barber form screen for adding or editing a barber.
///
/// Fields: name, specialty, experience, working hours, photo, active status.
class AdminBarberFormScreen extends ConsumerStatefulWidget {
  final String? barberId;

  const AdminBarberFormScreen({super.key, this.barberId});

  @override
  ConsumerState<AdminBarberFormScreen> createState() => _AdminBarberFormScreenState();
}

class _AdminBarberFormScreenState extends ConsumerState<AdminBarberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  TimeOfDay _jamMasuk = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _jamPulang = const TimeOfDay(hour: 21, minute: 0);
  bool _statusAktif = true;
  File? _selectedImage;
  String? _currentPhoto;
  bool _isSaving = false;
  bool _isLoading = false;

  bool get isEditing => widget.barberId != null && widget.barberId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadBarber();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadBarber() async {
    setState(() => _isLoading = true);
    final barber = await ref.read(barberByIdProvider(widget.barberId!).future);
    if (barber != null && mounted) {
      _nameController.text = barber.nama;
      _specialtyController.text = barber.spesialis;
      _experienceController.text = barber.pengalaman.toString();
      _statusAktif = barber.statusAktif;
      _currentPhoto = barber.foto;
      _jamMasuk = _parseTime(barber.jamMasuk);
      _jamPulang = _parseTime(barber.jamPulang);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay tod) =>
      '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String? photoUrl = _currentPhoto;
      if (_selectedImage != null) {
        photoUrl = await StorageService().uploadBarberPhoto(_selectedImage!, widget.barberId ?? 'new');
      }

      final service = ref.read(barberServiceProvider);
      final data = {
        'nama': _nameController.text.trim(),
        'spesialis': _specialtyController.text.trim(),
        'pengalaman': int.parse(_experienceController.text),
        'foto': photoUrl,
        'statusAktif': _statusAktif,
        'jamMasuk': _formatTime(_jamMasuk),
        'jamPulang': _formatTime(_jamPulang),
      };

      if (isEditing) {
        await service.updateBarber(widget.barberId!, data);
      } else {
        data['rating'] = 0.0;
        data['totalReviews'] = 0;
        data['createdAt'] = DateTime.now();
        await service.createBarber(BarberModel(
          id: '',
          nama: data['nama'] as String,
          spesialis: data['spesialis'] as String,
          pengalaman: data['pengalaman'] as int,
          foto: data['foto'] as String?,
          statusAktif: data['statusAktif'] as bool,
          jamMasuk: data['jamMasuk'] as String,
          jamPulang: data['jamPulang'] as String,
          createdAt: DateTime.now(),
        ));
      }

      if (mounted) {
        SnackbarHelper.success(context, isEditing ? 'Barber updated!' : 'Barber created!');
        context.pop();
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(isEditing ? 'Edit Barber' : 'Add Barber')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Barber' : 'Add Barber'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Photo
              _buildPhotoPicker(),
              const SizedBox(height: AppDimensions.spacingXL),

              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'Barber name',
                prefixIcon: Icons.person,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppDimensions.spacingLG),

              CustomTextField(
                controller: _specialtyController,
                label: 'Specialty',
                hintText: 'e.g. Haircuts, Facial, Hairdo',
                prefixIcon: Icons.work,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppDimensions.spacingLG),

              CustomTextField(
                controller: _experienceController,
                label: 'Experience (years)',
                hintText: 'Years of experience',
                prefixIcon: Icons.emoji_events_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = int.tryParse(v);
                  if (n == null || n < 0) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingLG),

              // Working hours
              Row(
                children: [
                  Expanded(child: _buildTimePicker('Start Time', _jamMasuk, (t) => setState(() => _jamMasuk = t))),
                  const SizedBox(width: AppDimensions.spacingMD),
                  Expanded(child: _buildTimePicker('End Time', _jamPulang, (t) => setState(() => _jamPulang = t))),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingLG),

              // Active status switch
              SwitchListTile(
                title: const Text('Active Status', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(_statusAktif ? 'Barber is visible to customers' : 'Barber is hidden from customers'),
                value: _statusAktif,
                activeTrackColor: AppColors.successGreen,
                onChanged: (v) => setState(() => _statusAktif = v),
                tileColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: () => _pickImage(),
      child: Column(
        children: [
          Stack(
            children: [
              _buildPhotoPreview(),
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
                  child: const Icon(Icons.camera_alt, color: AppColors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Tap to change photo', style: TextStyle(color: AppColors.gold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    if (_selectedImage != null) {
      return CircleAvatar(radius: 50, backgroundImage: FileImage(_selectedImage!));
    }
    if (_currentPhoto != null && _currentPhoto!.isNotEmpty) {
      return CachedImage(imageUrl: _currentPhoto!, width: 100, height: 100, borderRadius: 50, fit: BoxFit.cover);
    }
    return CircleAvatar(
      radius: 50,
      backgroundColor: AppColors.gold.withValues(alpha: 0.15),
      child: const Icon(Icons.person, color: AppColors.gold, size: 40),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 85);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Widget _buildTimePicker(String label, TimeOfDay value, ValueChanged<TimeOfDay> onChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: value);
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingLG),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.darkGrey, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 18, color: AppColors.gold),
                const SizedBox(width: 6),
                Text(_formatTime(value), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

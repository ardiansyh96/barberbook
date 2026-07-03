import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/providers/auth_provider.dart';

/// Change Password screen for updating the user's account password.
///
/// Features:
/// - Current password verification (re-authentication)
/// - New password with strength validation
/// - Confirm new password
/// - Success feedback and auto-navigation back
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Change password with re-authentication
  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final user = ref.read(authStateProvider).whenOrNull(data: (u) => u);
    if (user == null) {
      setState(() => _isSaving = false);
      SnackbarHelper.error(context, 'No user logged in');
      return;
    }

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);

      // Re-authenticate with current password
      await authNotifier.reauthenticate(
        user.email,
        _currentPasswordController.text,
      );

      // Change password
      await authNotifier.changePassword(_newPasswordController.text);

      if (mounted) {
        SnackbarHelper.success(context, 'Password changed successfully!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        // Check for specific error messages
        final message = e.toString().toLowerCase();
        if (message.contains('wrong-password') ||
            message.contains('invalid-credential')) {
          SnackbarHelper.error(context, 'Current password is incorrect');
        } else {
          SnackbarHelper.error(context, 'Failed to change password: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header Info ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLG),
                decoration: BoxDecoration(
                  color: AppColors.infoBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  border: Border.all(
                    color: AppColors.infoBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.infoBlue),
                    SizedBox(width: AppDimensions.spacingMD),
                    Expanded(
                      child: Text(
                        'Enter your current password to verify your identity, then set a new password.',
                        style: TextStyle(
                          color: AppColors.infoBlue,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXL),

              // ─── Current Password ───────────────────────────────────
              CustomTextField(
                controller: _currentPasswordController,
                label: 'Current Password',
                hintText: 'Enter your current password',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Current password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingLG),

              // ─── New Password ───────────────────────────────────────
              CustomTextField(
                controller: _newPasswordController,
                label: 'New Password',
                hintText: 'Enter new password (min. 8 characters)',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'New password is required';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingLG),

              // ─── Confirm New Password ───────────────────────────────
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                hintText: 'Re-enter new password',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingXXXL),

              // ─── Submit Button ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightLG,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

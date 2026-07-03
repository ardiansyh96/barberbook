import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

/// Registration screen for new Customer accounts.
///
/// Admin accounts are pre-created in Firebase and cannot be registered
/// through this screen. Only customers can self-register.
///
/// Features:
/// - Full name, email, phone, password, confirm password fields
/// - Client-side validation (email format, password 8+ chars, phone format)
/// - Loading state with disabled inputs
/// - Success: shows snackbar and navigates to Email Verification
/// - Error: shows error snackbar
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle registration: validate form, call auth provider, navigate on success.
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final user = await authNotifier.register(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nomorHP: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (user != null) {
      SnackbarHelper.success(
        context,
        'Registration successful! Please check your email for verification.',
      );
      context.go(RouteNames.emailVerification);
    } else {
      final error = ref.read(authNotifierProvider).errorMessage;
      if (error != null) {
        SnackbarHelper.error(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXXL,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.spacingLG),

                // Header
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.displaySmall,
                ).animate().fadeIn().slideY(begin: 0.2),
                const SizedBox(height: AppDimensions.spacingSM),
                Text(
                  'Sign up to start booking your barber',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkGrey,
                      ),
                ).animate(delay: 100.ms).fadeIn(),

                const SizedBox(height: AppDimensions.spacingXXL),

                // Full Name
                CustomTextField(
                  controller: _namaController,
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outlined,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.name(v, 'Full Name'),
                ).animate(delay: 200.ms).fadeIn(),

                const SizedBox(height: AppDimensions.spacingLG),

                // Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ).animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: AppDimensions.spacingLG),

                // Phone Number
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hintText: '08xxxxxxxxxx',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: Validators.phone,
                ).animate(delay: 400.ms).fadeIn(),

                const SizedBox(height: AppDimensions.spacingLG),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Minimum 8 characters',
                  prefixIcon: Icons.lock_outlined,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                ).animate(delay: 500.ms).fadeIn(),

                const SizedBox(height: AppDimensions.spacingLG),

                // Confirm Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  prefixIcon: Icons.lock_outlined,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleRegister(),
                  validator: (value) => Validators.confirmPassword(
                    _passwordController.text,
                  )(value),
                ).animate(delay: 600.ms).fadeIn(),

                const SizedBox(height: AppDimensions.spacingXXL),

                // Register Button
                SizedBox(
                  height: AppDimensions.buttonHeightLG,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlack,
                      foregroundColor: AppColors.white,
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.gold,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: AppDimensions.spacingLG),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

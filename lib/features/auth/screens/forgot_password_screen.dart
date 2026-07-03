import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

/// Forgot Password screen.
///
/// Allows users to request a password reset email.
///
/// Features:
/// - Email validation using [Validators]
/// - Loading state with disabled button
/// - Success: shows success feedback with email icon and back-to-login button
/// - Error: shows error snackbar
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Handle password reset: validate email, call auth provider, show success.
  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authNotifierProvider.notifier)
        .resetPassword(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      setState(() => _emailSent = true);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXXL,
          ),
          child:
              _emailSent ? _buildSuccessState(context) : _buildFormState(context, authState),
        ),
      ),
    );
  }

  /// Success state: shows email sent confirmation.
  Widget _buildSuccessState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(flex: 2),

        // Success Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 56,
            color: AppColors.successGreen,
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: AppDimensions.spacingXXL),

        // Title
        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ).animate(delay: 200.ms).fadeIn(),
        const SizedBox(height: AppDimensions.spacingMD),

        // Description
        Text(
          "We've sent a password reset link to:\n${_emailController.text.trim()}",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkGrey,
              ),
          textAlign: TextAlign.center,
        ).animate(delay: 300.ms).fadeIn(),

        const SizedBox(height: AppDimensions.spacingGiant),

        // Back to Login Button
        SizedBox(
          height: AppDimensions.buttonHeightLG,
          child: ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlack,
              foregroundColor: AppColors.white,
            ),
            child: const Text(
              'Back to Login',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),

        const SizedBox(height: AppDimensions.spacingLG),

        // Resend hint
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: const Text(
            "Didn't receive the email? Try again",
            style: TextStyle(fontSize: 14),
          ),
        ).animate(delay: 600.ms).fadeIn(),

        const Spacer(flex: 2),
      ],
    );
  }

  /// Form state: email input and reset button.
  Widget _buildFormState(BuildContext context, AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimensions.spacingGiant),

          // Icon
          const Icon(
            Icons.lock_reset,
            size: 64,
            color: AppColors.gold,
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: AppDimensions.spacingXL),

          // Title
          Text(
            'Forgot Password?',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: AppDimensions.spacingSM),

          // Description
          Text(
            "Enter your email address and we'll send you a link to reset your password.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.darkGrey,
                ),
            textAlign: TextAlign.center,
          ).animate(delay: 300.ms).fadeIn(),

          const SizedBox(height: AppDimensions.spacingXXXL),

          // Email Field
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleReset(),
            validator: Validators.email,
          ).animate(delay: 400.ms).fadeIn(),

          const SizedBox(height: AppDimensions.spacingXXL),

          // Reset Button
          SizedBox(
            height: AppDimensions.buttonHeightLG,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _handleReset,
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
                      'Send Reset Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),
        ],
      ),
    );
  }
}

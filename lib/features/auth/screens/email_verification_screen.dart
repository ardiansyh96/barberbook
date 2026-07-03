import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../providers/auth_provider.dart';

/// Email Verification screen shown after registration.
///
/// Features:
/// - Polls Firebase every 3 seconds to check verification status
/// - Auto-redirects to login when email is verified
/// - Resend verification email with 60-second cooldown
/// - Back to Login button for manual navigation
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _pollTimer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // Start polling for email verification status
    _startPolling();
    // Set initial cooldown for resend button
    _startCooldown();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  /// Poll Firebase every 3 seconds to check if email is verified.
  /// Auto-redirects to login when verified.
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final isVerified =
          await ref.read(authNotifierProvider.notifier).checkEmailVerified();

      if (!mounted) return;

      if (isVerified) {
        timer.cancel();
        SnackbarHelper.success(context, 'Email verified successfully!');
        context.go(RouteNames.login);
      }
    });
  }

  /// Start a 60-second cooldown for the resend button.
  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  /// Resend verification email and restart cooldown.
  Future<void> _handleResend() async {
    if (_isResending || _resendCooldown > 0) return;

    setState(() => _isResending = true);

    final success =
        await ref.read(authNotifierProvider.notifier).sendVerificationEmail();

    if (!mounted) return;
    setState(() => _isResending = false);

    if (success) {
      SnackbarHelper.success(context, 'Verification email sent!');
      _startCooldown();
    } else {
      final error = ref.read(authNotifierProvider).errorMessage;
      if (error != null) {
        SnackbarHelper.error(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXXL,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // Email icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread,
                  size: 48,
                  color: AppColors.gold,
                ),
              ).animate().scale(
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: AppDimensions.spacingXXL),

              // Title
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
              const SizedBox(height: AppDimensions.spacingMD),

              // Description
              Text(
                "We've sent a verification link to your email address. Please check your inbox and verify your account.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkGrey,
                    ),
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn(),

              const SizedBox(height: AppDimensions.spacingGiant),

              // Proceed to Login
              SizedBox(
                height: AppDimensions.buttonHeightLG,
                child: ElevatedButton(
                  onPressed: () => context.go(RouteNames.login),
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

              // Resend email with cooldown
              TextButton(
                onPressed: _handleResend,
                child: _isResending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _resendCooldown > 0
                            ? "Resend email (${_resendCooldown}s)"
                            : "Didn't receive the email? Resend",
                        style: const TextStyle(fontSize: 14),
                      ),
              ).animate(delay: 600.ms).fadeIn(),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

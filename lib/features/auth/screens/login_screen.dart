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
import '../../../../main.dart';
import '../providers/auth_provider.dart';

/// Login screen for both Customer and Admin roles.
///
/// Features:
/// - Email/password validation using [Validators]
/// - Remember Me: saves email to SharedPreferences for auto-fill
/// - Auto-load saved email on init if Remember Me was previously enabled
/// - Forgot password navigation
/// - Register navigation for new customers
/// - Loading state with disabled inputs
/// - RBAC redirect after successful login
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    // Load saved email from SharedPreferences if Remember Me was enabled
    _loadSavedEmail();
  }

  /// Load saved email from SharedPreferences and auto-fill the email field.
  void _loadSavedEmail() {
    if (sharedPrefsService.rememberMe) {
      final savedEmail = sharedPrefsService.savedEmail;
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
        _rememberMe = true;
        // Auto-focus password field since email is pre-filled
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _passwordFocusNode.requestFocus();
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Handle login action with Remember Me persistence.
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final user = await authNotifier.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    if (user != null) {
      // Navigate based on user role (GoRouter redirect also handles this)
      if (user.isAdmin) {
        context.go(RouteNames.adminHome);
      } else {
        context.go(RouteNames.customerHome);
      }
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
                const SizedBox(height: AppDimensions.spacingGiant),

                // App Logo / Icon
                Icon(
                  Icons.content_cut,
                  size: 56,
                  color: AppColors.gold,
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: AppDimensions.spacingLG),

                // Title
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: AppDimensions.spacingSM),

                // Subtitle
                Text(
                  'Sign in to continue to BarberBook',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkGrey,
                      ),
                  textAlign: TextAlign.center,
                ).animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: AppDimensions.spacingXXXL),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  label: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.1),

                const SizedBox(height: AppDimensions.spacingLG),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  label: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock_outlined,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
                  validator: Validators.password,
                ).animate(delay: 500.ms).fadeIn().slideX(begin: -0.1),

                const SizedBox(height: AppDimensions.spacingMD),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (v) =>
                                setState(() => _rememberMe = v ?? false),
                            activeColor: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingSM),
                        Text(
                          'Remember me',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.forgotPassword),
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ).animate(delay: 600.ms).fadeIn(),

                const SizedBox(height: AppDimensions.spacingXXL),

                // Login Button
                SizedBox(
                  height: AppDimensions.buttonHeightLG,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleLogin,
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
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: AppDimensions.spacingXXL),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.register),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ).animate(delay: 800.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:driving_license_exam/core/presentation/widgets/app_scaffold.dart';
import 'package:driving_license_exam/core/providers/auth_provider.dart';
import 'package:driving_license_exam/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../../core/localization/app_localization.dart';
import '../../../../core/widgets/auth_text_field.dart';
import '../../../../core/widgets/auth_button.dart';
import 'forgot_password_screen.dart';
import '../../../../core/widgets/custom_alert_dialog.dart';
import '../../../../core/services/logger_service.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authProvider.notifier).signIn(
            _emailController.text,
            _passwordController.text,
          );

      final state = ref.read(authProvider);
      if (state.error != null && mounted) {
        showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            title: 'Login Failed',
            message: state.error!,
            primaryButtonText: 'Try Again',
            icon: Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
          ),
        );
      } else if (state.user != null && mounted) {
        LoggerService.info('Navigating to home screen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AppScaffold()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Text(
                  AppLocalization.of(context).translate('auth.welcome'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalization.of(context).translate('auth.sign_in_desc'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 48),
                AuthTextField(
                  controller: _emailController,
                  hintText:
                      AppLocalization.of(context).translate('auth.email_hint'),
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  onChanged: (_) {},
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return AppLocalization.of(context)
                          .translate('auth.email_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordController,
                  hintText: AppLocalization.of(context)
                      .translate('auth.password_hint'),
                  obscureText: !_isPasswordVisible,
                  prefixIcon: Icons.lock_outlined,
                  onChanged: (_) {},
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return AppLocalization.of(context)
                          .translate('auth.password_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalization.of(context)
                          .translate('auth.forgot_password'),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AuthButton(
                  onPressed: state.isLoading ? null : _signIn,
                  isLoading: state.isLoading,
                  text: AppLocalization.of(context)
                      .translate('auth.sign_in_button'),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    state.error!,
                    style: TextStyle(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalization.of(context)
                        .translate('auth.no_account')),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalization.of(context).translate('auth.sign_up'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

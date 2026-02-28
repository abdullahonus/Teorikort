import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/presentation/widgets/app_scaffold.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/auth_text_field.dart';
import 'package:teorikort/core/widgets/auth_button.dart';
import '../provider/auth_provider.dart';
import 'sign_up_view.dart';
import 'forgot_password_view.dart';

class SignInView extends ConsumerStatefulWidget {
  const SignInView({super.key});

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
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
      await ref
          .read(authProvider.notifier)
          .signIn(_emailController.text, _passwordController.text);

      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppScaffold()),
          (route) => false,
        );
      } else if (authState.error != null) {
        log(authState.error!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // select ile sadece gerekli alanlar dinleniyor → gereksiz rebuild yok
    final isLoading =
        ref.watch(authProvider.select((s) => s.isLoading));
    final error = ref.watch(authProvider.select((s) => s.error));
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
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 48),
                AuthTextField(
                  controller: _emailController,
                  hintText: AppLocalization.of(context)
                      .translate('auth.email_hint'),
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
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordView()),
                    ),
                    child: Text(AppLocalization.of(context)
                        .translate('auth.forgot_password')),
                  ),
                ),
                const SizedBox(height: 32),
                AuthButton(
                  onPressed: isLoading ? null : _signIn,
                  isLoading: isLoading,
                  text: AppLocalization.of(context)
                      .translate('auth.sign_in_button'),
                ),
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    error,
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
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SignUpView()),
                      ),
                      child: Text(AppLocalization.of(context)
                          .translate('auth.sign_up')),
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

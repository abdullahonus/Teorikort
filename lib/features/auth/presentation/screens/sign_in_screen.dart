import 'dart:developer';

import 'package:teorikort/core/presentation/widgets/app_scaffold.dart';
import '../../presentation/providers/auth_provider.dart';
import 'package:teorikort/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localization.dart';
import '../../../../core/widgets/auth_text_field.dart';
import '../../../../core/widgets/auth_button.dart';
import 'forgot_password_screen.dart';

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
      try {
        await ref.read(authStateProvider.notifier).signIn(
              _emailController.text,
              _passwordController.text,
            );

        if (!mounted) return;

        final state = ref.read(authStateProvider);

        // Başarılı giriş durumu - hem token hem error kontrolü
        if (state.user != null && state.token != null && state.error == null) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AppScaffold()),
            (route) => false,
          );
        } else if (state.error != null) {
          log(state.error.toString());
        }
      } catch (e) {
        if (!mounted) return;
        log(e.toString());
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await ref.read(authStateProvider.notifier).logout();

      if (!mounted) return;

      // Giriş sayfasına yönlendir
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authStateProvider);
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

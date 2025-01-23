import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localization.dart';
import '../providers/auth_provider.dart';
import '../../../../core/widgets/auth_text_field.dart';
import '../../../../core/widgets/auth_button.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authStateProvider.notifier).signUp(
            _emailController.text,
            _passwordController.text,
            _nameController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authStateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalization.of(context).translate('auth.create_account'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalization.of(context).translate('auth.sign_up_desc'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 32),
                AuthTextField(
                  controller: _nameController,
                  hintText:
                      AppLocalization.of(context).translate('Kullanıcı Adı'),
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return AppLocalization.of(context)
                          .translate('auth.name_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                    final emailRegex =
                        RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
                    if (!emailRegex.hasMatch(value!)) {
                      return AppLocalization.of(context)
                          .translate('auth.invalid_email');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordController,
                  hintText: AppLocalization.of(context).translate('Şifre'),
                  obscureText: !_isPasswordVisible,
                  prefixIcon: Icons.lock_outline,
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
                    if (value!.length < 6) {
                      return AppLocalization.of(context)
                          .translate('auth.password_length');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _confirmPasswordController,
                  hintText: AppLocalization.of(context)
                      .translate('auth.confirm_password'),
                  obscureText: !_isConfirmPasswordVisible,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return AppLocalization.of(context)
                          .translate('auth.confirm_password_required');
                    }
                    if (value != _passwordController.text) {
                      return AppLocalization.of(context)
                          .translate('auth.passwords_not_match');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                AuthButton(
                  onPressed: state.isLoading ? null : _signUp,
                  isLoading: state.isLoading,
                  text: AppLocalization.of(context).translate('auth.sign_up'),
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
                    Text(
                      AppLocalization.of(context)
                          .translate('auth.have_account'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        AppLocalization.of(context).translate('auth.sign_in'),
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

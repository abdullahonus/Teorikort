import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localization.dart';
import '../../../../core/widgets/auth_text_field.dart';
import '../../../../core/widgets/auth_button.dart';
import '../providers/reset_password_provider.dart';
import '../../data/models/reset_password_state.dart';
import '../../../../features/auth/presentation/screens/sign_in_screen.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    required this.email,
    required this.otp,
    super.key,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  int _passwordStrength = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalization.of(context).translate('auth.reset_password')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 64,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  AppLocalization.of(context)
                      .translate('auth.new_password_title'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalization.of(context)
                      .translate('auth.new_password_desc'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Şifre Alanı
                AuthTextField(
                  controller: _passwordController,
                  hintText: AppLocalization.of(context)
                      .translate('auth.new_password'),
                  obscureText: !_isPasswordVisible,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  onChanged: _validatePassword,
                  validator: _passwordValidator,
                ),
                // Şifre Gücü Göstergesi
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _passwordStrength / 100,
                    backgroundColor: colorScheme.surfaceVariant,
                    color: _getStrengthColor(colorScheme),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStrengthText(),
                    style: TextStyle(
                      color: _getStrengthColor(colorScheme),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Şifre Tekrar Alanı
                AuthTextField(
                  controller: _confirmPasswordController,
                  hintText: AppLocalization.of(context)
                      .translate('auth.confirm_password'),
                  obscureText: !_isConfirmPasswordVisible,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(() =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                  validator: _confirmPasswordValidator,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 32),
                AuthButton(
                  onPressed: state.isLoading ? null : _resetPassword,
                  isLoading: state.isLoading,
                  text: AppLocalization.of(context)
                      .translate('auth.reset_password_button'),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    state.error!,
                    style: TextStyle(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _validatePassword(String value) async {
    await ref.read(resetPasswordProvider.notifier).validatePassword(value);
    final state = ref.read(resetPasswordProvider);
    setState(() {
      _passwordStrength = state.strength;
    });
    return;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.of(context).translate('auth.password_required');
    }
    if (value.length < 8) {
      return AppLocalization.of(context).translate('auth.password_length');
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.of(context)
          .translate('auth.confirm_password_required');
    }
    if (value != _passwordController.text) {
      return AppLocalization.of(context).translate('auth.passwords_not_match');
    }
    return null;
  }

  Color _getStrengthColor(ColorScheme colorScheme) {
    if (_passwordStrength < 30) return colorScheme.error;
    if (_passwordStrength < 60) return colorScheme.primary;
    return colorScheme.tertiary;
  }

  String _getStrengthText() {
    if (_passwordStrength < 30) {
      return AppLocalization.of(context).translate('auth.password_weak');
    }
    if (_passwordStrength < 60) {
      return AppLocalization.of(context).translate('auth.password_medium');
    }
    return AppLocalization.of(context).translate('auth.password_strong');
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(resetPasswordProvider.notifier).resetPassword(
            widget.email,
            widget.otp,
            _passwordController.text,
          );

      final state = ref.read(resetPasswordProvider);
      if (!state.isLoading && state.error == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalization.of(context).translate('auth.reset_success'),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
        );
      }
    }
    return;
  }
}

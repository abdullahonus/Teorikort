import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/presentation/widgets/app_scaffold.dart';
import 'package:teorikort/core/providers/locale_provider.dart';
import 'package:teorikort/core/widgets/auth_button.dart';
import 'package:teorikort/core/widgets/auth_text_field.dart';
import 'package:teorikort/data/splash_response_model.dart';

import '../provider/auth_provider.dart';
import 'forgot_password_view.dart';
import 'sign_up_view.dart';

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

  void _showLanguagePicker(
    BuildContext context,
    List<LanguageModel> languages,
    String currentCode,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LanguagePickerSheet(
        languages: languages,
        currentCode: currentCode,
        onSelected: (code) {
          ref.read(localeProvider.notifier).setLocale(code);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    final error = ref.watch(authProvider.select((s) => s.error));
    final currentLocale = ref.watch(localeProvider);
    final languages = ref.watch(availableLanguagesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // ── Teal header dekorasyon ──────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.75),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),

          // ── Ana içerik ─────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Logo & başlık (header alanında)
                  SizedBox(
                    height: size.height * 0.28,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Uygulama ikonu
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              'assets/icons/ic_app_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Teorikort',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ehliyet Sınav Hazırlık',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.80),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Form kartı ─────────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.08),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Başlık
                          Text(
                            AppLocalization.of(context)
                                .translate('auth.welcome'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalization.of(context)
                                .translate('auth.sign_in_desc'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.55),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Email
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
                          const SizedBox(height: 14),

                          // Şifre
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
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(() =>
                                  _isPasswordVisible = !_isPasswordVisible),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return AppLocalization.of(context)
                                    .translate('auth.password_required');
                              }
                              return null;
                            },
                          ),

                          // Şifremi Unuttum
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordView()),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 6),
                              ),
                              child: Text(
                                AppLocalization.of(context)
                                    .translate('auth.forgot_password'),
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Giriş Yap butonu
                          AuthButton(
                            onPressed: isLoading ? null : _signIn,
                            isLoading: isLoading,
                            text: AppLocalization.of(context)
                                .translate('auth.sign_in_button'),
                          ),

                          // Hata mesajı
                          if (error != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: colorScheme.error.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.error.withOpacity(0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 18, color: colorScheme.error),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style: TextStyle(
                                          color: colorScheme.error,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Kayıt ol linki
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalization.of(context)
                                    .translate('auth.no_account'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SignUpView()),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                ),
                                child: Text(
                                  AppLocalization.of(context)
                                      .translate('auth.sign_up'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Dil Chip — EN ÜSTTE olması için stack'in son child'ı ────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 14, right: 20),
                child: _LanguageChip(
                  languages: languages,
                  currentCode: currentLocale.languageCode,
                  onTap: () => _showLanguagePicker(
                    context,
                    languages,
                    currentLocale.languageCode,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dil Chip (sağ üst) ───────────────────────────────────────────────────────
class _LanguageChip extends StatelessWidget {
  final List<LanguageModel> languages;
  final String currentCode;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.languages,
    required this.currentCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final current = languages.firstWhere(
      (l) => l.code == currentCode,
      orElse: () =>
          LanguageModel(code: currentCode, name: currentCode.toUpperCase()),
    );
    final flag = _getFlag(current.code);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.50), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              current.code.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ─── Dil Seçici Bottom Sheet ──────────────────────────────────────────────────
class _LanguagePickerSheet extends StatelessWidget {
  final List<LanguageModel> languages;
  final String currentCode;
  final ValueChanged<String> onSelected;

  const _LanguagePickerSheet({
    required this.languages,
    required this.currentCode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Dil Seç / Select Language',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          ...languages.map((lang) {
            final isSelected = lang.code == currentCode;
            final flag = _getFlag(lang.code);
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withOpacity(0.08)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(flag, style: const TextStyle(fontSize: 24)),
                ),
              ),
              title: Text(
                lang.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                lang.code.toUpperCase(),
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
              trailing: isSelected
                  ? Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 16),
                    )
                  : null,
              onTap: () => onSelected(lang.code),
            );
          }),
        ],
      ),
    );
  }
}

/// Dil koduna göre emoji bayrak
String _getFlag(String code) {
  switch (code.toLowerCase()) {
    case 'tr':
      return '🇹🇷';
    case 'en':
      return '🇬🇧';
    case 'sv':
      return '🇸🇪';
    case 'de':
      return '🇩🇪';
    case 'fr':
      return '🇫🇷';
    case 'ar':
      return '🇸🇦';
    case 'nl':
      return '🇳🇱';
    case 'pl':
      return '🇵🇱';
    case 'fi':
      return '🇫🇮';
    case 'no':
      return '🇳🇴';
    case 'da':
      return '🇩🇰';
    default:
      return '🌐';
  }
}

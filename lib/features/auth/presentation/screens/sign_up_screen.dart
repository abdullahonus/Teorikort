import 'package:teorikort/core/presentation/widgets/app_scaffold.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await ref.read(authStateProvider.notifier).signUp(
              _emailController.text.trim(),
              _passwordController.text,
              _nameController.text.trim(),
              lastname: _lastnameController.text.trim(),
              phone: _phoneController.text.trim(),
            );

        if (!mounted) return;

        // Başarılı kayıt sonrası ana sayfaya yönlendir
        if (ref.read(authStateProvider).user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AppScaffold()),
          );
        }
      } catch (e) {
        if (!mounted) return;
        showErrorDialog(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
              AppLocalization.of(context).translate('auth.sign_up_title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText:
                      AppLocalization.of(context).translate('auth.first_name'),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalization.of(context)
                        .translate('auth.first_name_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastnameController,
                decoration: InputDecoration(
                  labelText:
                      AppLocalization.of(context).translate('auth.last_name'),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalization.of(context)
                        .translate('auth.last_name_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText:
                      AppLocalization.of(context).translate('auth.email_hint'),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalization.of(context)
                        .translate('auth.email_required');
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return AppLocalization.of(context)
                        .translate('auth.email_invalid');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText:
                      AppLocalization.of(context).translate('auth.phone'),
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalization.of(context)
                        .translate('auth.phone_required');
                  }
                  // Basit telefon numarası validasyonu
                  if (value.length < 10) {
                    return AppLocalization.of(context)
                        .translate('auth.phone_invalid');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: AppLocalization.of(context)
                      .translate('auth.password_hint'),
                  prefixIcon: const Icon(Icons.lock),
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalization.of(context)
                        .translate('auth.password_required');
                  }
                  if (value.length < 6) {
                    return AppLocalization.of(context)
                        .translate('auth.password_length');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.primaryColor,
                ),
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        AppLocalization.of(context).translate('auth.sign_up')),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    state.error!,
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/signin'),
                child: Text(AppLocalization.of(context)
                    .translate('auth.already_have_account')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hata'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tamam'),
        ),
      ],
    ),
  );
}

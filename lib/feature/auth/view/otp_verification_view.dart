import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_bar_widget.dart';
import 'package:teorikort/core/widgets/auth_button.dart';

import '../provider/auth_provider.dart';

class OtpVerificationView extends ConsumerStatefulWidget {
  final String email;
  final VoidCallback onVerificationComplete;

  const OtpVerificationView({
    super.key,
    required this.email,
    required this.onVerificationComplete,
  });

  @override
  ConsumerState<OtpVerificationView> createState() =>
      _OtpVerificationViewState();
}

class _OtpVerificationViewState extends ConsumerState<OtpVerificationView> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _resendTimer;
  int _resendSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _startResendTimer() {
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendCode() async {
    // TODO: AuthNotifier'a sendOTP eklendiğinde burası güncellenir
    _startResendTimer();
  }

  Future<void> _verifyOTP() async {
    final otp = _otp;
    if (otp.length == 6) {
      // TODO: AuthNotifier'a verifyOTP eklendiğinde burası güncellenir
      final authState = ref.read(authProvider);
      if (!authState.isLoading && authState.error == null) {
        widget.onVerificationComplete();
      }
    }
  }

  Widget _buildOTPFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: 45,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(fontSize: 24),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (value) {
              if (value.length == 1 && index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
              if (_controllers.every((c) => c.text.length == 1)) {
                _verifyOTP();
              }
            },
            textInputAction:
                index == 5 ? TextInputAction.done : TextInputAction.next,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    final error = ref.watch(authProvider.select((s) => s.error));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppHeader(
        title: AppLocalization.of(context).translate('auth.otp_title'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                final focused = FocusScope.of(context).focusedChild;
                if (focused != null) {
                  final index = _focusNodes.indexOf(focused);
                  if (index > 0 && _controllers[index].text.isEmpty) {
                    _controllers[index - 1].clear();
                    _focusNodes[index - 1].requestFocus();
                  }
                }
              }
              return KeyEventResult.ignored;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.verified_user_outlined,
                    size: 64, color: colorScheme.primary),
                const SizedBox(height: 32),
                Text(
                  AppLocalization.of(context).translate('auth.otp_title'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalization.of(context)
                      .translate('auth.otp_desc')
                      .replaceAll('%s', widget.email),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _buildOTPFields(),
                const SizedBox(height: 32),
                AuthButton(
                  onPressed: isLoading ? null : _verifyOTP,
                  isLoading: isLoading,
                  text:
                      AppLocalization.of(context).translate('auth.verify_code'),
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
                TextButton(
                  onPressed: _resendSeconds > 0 ? null : _resendCode,
                  child: Text(
                    AppLocalization.of(context).translate('auth.resend_code'),
                    style: TextStyle(
                      color: _resendSeconds > 0
                          ? colorScheme.onSurface.withValues(alpha: 0.5)
                          : null,
                    ),
                  ),
                ),
                if (_resendSeconds > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${_resendSeconds}s',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

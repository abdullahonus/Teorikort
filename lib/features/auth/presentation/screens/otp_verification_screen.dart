import 'package:driving_license_exam/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localization.dart';
import '../providers/auth_provider.dart';
import '../../../../core/widgets/auth_button.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final VoidCallback onVerificationComplete;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.onVerificationComplete,
  });

  @override
  ConsumerState<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  Timer? _resendTimer;
  int _resendSeconds = 0;

  @override
  void initState() {
    super.initState();
    // İlk field'a otomatik focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
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
            cursorColor: Theme.of(context).colorScheme.primary,
            cursorWidth: 2,
            decoration: InputDecoration(
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
              if (value.length == 1) {
                if (index < 5) {
                  _focusNodes[index + 1].requestFocus();
                }
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

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 60;
    });

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
    await ref.read(authProvider.notifier).sendOTP(widget.email);
    _startResendTimer();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOTP() async {
    final otp = _otp;
    if (otp.length == 6) {
      await ref.read(authProvider.notifier).verifyOTP(widget.email, otp);
      final state = ref.read(authProvider);
      if (!state.isLoading && state.error == null) {
        widget.onVerificationComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
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
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                final currentFocus = FocusScope.of(context).focusedChild;
                if (currentFocus != null) {
                  final index = _focusNodes.indexOf(currentFocus as FocusNode);
                  if (index != -1) {
                    if (_controllers[index].text.isEmpty && index > 0) {
                      _controllers[index - 1].clear();
                      _focusNodes[index - 1].requestFocus();
                    }
                  }
                }
              }
              return KeyEventResult.ignored;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 64,
                  color: colorScheme.primary,
                ),
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
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _buildOTPFields(),
                const SizedBox(height: 32),
                AuthButton(
                  onPressed: state.isLoading ? null : _verifyOTP,
                  isLoading: state.isLoading,
                  text:
                      AppLocalization.of(context).translate('auth.verify_code'),
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
                Column(
                  children: [
                    TextButton(
                      onPressed: _resendSeconds > 0 ? null : _resendCode,
                      child: Text(
                        AppLocalization.of(context)
                            .translate('auth.resend_code'),
                        style: TextStyle(
                          color: _resendSeconds > 0
                              ? colorScheme.onSurface.withOpacity(0.5)
                              : null,
                        ),
                      ),
                    ),
                    if (_resendSeconds > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${_resendSeconds}s',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
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

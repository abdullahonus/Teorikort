import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifier/auth_notifier.dart';
import '../state/auth_state.dart';

// ──────────────────────────────────────────────────────────────────────────────
// AUTH PROVIDER
// Spec: NotifierProvider<XxxNotifier, XxxState>(XxxNotifier.new)
// Widget kullanımı:
//   ref.watch(authProvider)                       → AuthState
//   ref.watch(authProvider.select((s) => s.user)) → sadece user alanı
//   ref.read(authProvider.notifier).signIn(...)   → action tetikle
// ──────────────────────────────────────────────────────────────────────────────

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

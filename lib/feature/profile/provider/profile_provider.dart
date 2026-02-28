import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifier/profile_notifier.dart';
import '../state/profile_state.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PROFILE PROVIDER
// Spec: NotifierProvider<XxxNotifier, XxxState>(XxxNotifier.new)
// ──────────────────────────────────────────────────────────────────────────────

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);

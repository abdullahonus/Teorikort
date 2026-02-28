import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifier/exam_notifier.dart';
import '../notifier/exam_session_notifier.dart';
import '../state/exam_state.dart';
import '../state/exam_session_state.dart';

// ──────────────────────────────────────────────────────────────────────────────
// EXAM PROVIDERS
// Spec: NotifierProvider<XxxNotifier, XxxState>(XxxNotifier.new)
// ──────────────────────────────────────────────────────────────────────────────

/// Provider for the exam list and category management.
final examProvider = NotifierProvider<ExamNotifier, ExamState>(
  ExamNotifier.new,
);

/// Provider for active exam taking sessions.
final examSessionProvider =
    AutoDisposeNotifierProvider<ExamSessionNotifier, ExamSessionState>(
  ExamSessionNotifier.new,
);

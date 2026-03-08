import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_html_text.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';

import '../model/exam_question.dart';
import '../provider/exam_provider.dart';
import '../state/exam_session_state.dart';
import 'exam_result_view.dart';

class ExamSessionView extends ConsumerStatefulWidget {
  final String categoryId;
  final String examTitle;
  final String? difficulty;
  final String examType;
  final int initialSeconds;

  const ExamSessionView({
    super.key,
    required this.categoryId,
    required this.examTitle,
    this.difficulty,
    this.examType = 'final',
    this.initialSeconds = 2700, // 45 minutes
  });

  @override
  ConsumerState<ExamSessionView> createState() => _ExamSessionViewState();
}

class _ExamSessionViewState extends ConsumerState<ExamSessionView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(examSessionProvider.notifier).startExam(
          widget.categoryId, widget.initialSeconds,
          examType: widget.examType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(examSessionProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(examSessionProvider, (previous, next) {
      if (next.isFinished && next.lastResult != null && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExamResultView(
              result: next.lastResult!,
              questions: next.questions,
              userAnswers: next.userAnswers,
            ),
          ),
        );
      }
    });

    if (state.isLoading && state.questions.isEmpty) {
      return const Scaffold(body: AppLoadingWidget.fullscreen());
    }

    if (state.error != null && state.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(state.error!)),
      );
    }

    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examTitle),
        actions: [
          _buildTimer(context, state.remainingSeconds),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (state.currentQuestionIndex + 1) / state.questions.length,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalization.of(context)
                              .translate('quiz.question_count') !=
                          'quiz.question_count'
                      ? AppLocalization.of(context)
                          .translate('quiz.question_count')
                          .replaceAll('%d', '${state.currentQuestionIndex + 1}')
                          .replaceFirst('%d', '${state.questions.length}')
                      : 'Soru ${state.currentQuestionIndex + 1} / ${state.questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _buildQuestionList(context, ref, state),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentQuestion.imageUrl != null &&
                      currentQuestion.imageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          currentQuestion.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  AppHtmlText(
                    htmlData: currentQuestion.question,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  ...currentQuestion.options.map((option) => _buildOption(
                      context,
                      currentQuestion.id,
                      option,
                      state.userAnswers[currentQuestion.id])),
                ],
              ),
            ),
          ),
          _buildBottomNav(context, ref, state),
        ],
      ),
    );
  }

  Widget _buildTimer(BuildContext context, int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSecs = seconds % 60;
    final color =
        seconds < 300 ? Colors.red : Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                '${minutes.toString().padLeft(2, '0')}:${remainingSecs.toString().padLeft(2, '0')}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionList(
      BuildContext context, WidgetRef ref, ExamSessionState state) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.questions.length,
          itemBuilder: (context, index) {
            final q = state.questions[index];
            final isAnswered = state.userAnswers.containsKey(q.id);
            final isCurrent = index == state.currentQuestionIndex;

            return GestureDetector(
              onTap: () =>
                  ref.read(examSessionProvider.notifier).jumpToQuestion(index),
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                    color: isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : (isAnswered
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : (isAnswered
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent),
                      width: 2,
                    )),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isCurrent
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                    fontWeight: isCurrent ? FontWeight.bold : null,
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildOption(BuildContext context, String questionId,
      ExamOption option, String? selectedOptionId) {
    final isSelected = selectedOptionId == option.id;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => ref
            .read(examSessionProvider.notifier)
            .selectOption(questionId, option.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.outline,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppHtmlText(
                  htmlData: option.text,
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(
      BuildContext context, WidgetRef ref, ExamSessionState state) {
    final isLast = state.currentQuestionIndex == state.questions.length - 1;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      color: colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (state.currentQuestionIndex > 0)
            OutlinedButton(
              onPressed: () =>
                  ref.read(examSessionProvider.notifier).previousQuestion(),
              child:
                  Text(AppLocalization.of(context).translate('quiz.previous')),
            )
          else
            const SizedBox(),
          ElevatedButton(
            onPressed: () {
              if (isLast) {
                _showFinishConfirmation(context, ref);
              } else {
                ref.read(examSessionProvider.notifier).nextQuestion();
              }
            },
            child: Text(isLast
                ? AppLocalization.of(context).translate('quiz.finish')
                : AppLocalization.of(context).translate('quiz.next')),
          ),
        ],
      ),
    );
  }

  void _showFinishConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            AppLocalization.of(context).translate('quiz.confirm_finish_title')),
        content: Text(
            AppLocalization.of(context).translate('quiz.confirm_finish_desc')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text(AppLocalization.of(context).translate('quiz.cancel'))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(examSessionProvider.notifier).finishExam(
                    categoryId: widget.categoryId,
                    examType: widget.examType,
                  );
            },
            child: Text(
                AppLocalization.of(context).translate('quiz.finish_button')),
          ),
        ],
      ),
    );
  }
}

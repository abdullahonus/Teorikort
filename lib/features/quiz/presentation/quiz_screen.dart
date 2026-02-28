import 'package:teorikort/features/quiz/data/models/quiz_data.dart';
import 'package:teorikort/features/quiz/data/services/quiz_service.dart' hide ExamCategory;
import 'package:teorikort/features/quiz/presentation/quiz_result_screen.dart';
import 'package:teorikort/features/quiz/presentation/widgets/quiz_progress_widget.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:teorikort/features/quiz/presentation/widgets/question_navigation_dialog.dart';
import 'package:teorikort/features/exam/data/models/exam_result.dart';
import 'package:teorikort/features/exam/data/services/exam_result_service.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/services/user_service.dart';

import 'package:teorikort/features/exam/data/services/exam_service.dart';
import 'package:teorikort/features/reports/data/services/report_service.dart';

class QuizScreen extends StatefulWidget {
  final String examTitle;
  final List<Map<String, dynamic>>? questions;
  final List<QuizQuestion>? quizQuestions;
  final String category;
  final String? difficulty;
  final String? examType;

  const QuizScreen({
    super.key,
    required this.examTitle,
    this.questions,
    this.quizQuestions,
    this.category = '1',
    this.difficulty,
    this.examType,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  final ExamService _examService = ExamService();
  List<QuizQuestion> questions = [];
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool isLoading = true;
  int remainingSeconds = 1800; // API'den gelene kadar varsayılan 30dk

  late Timer _timer;

  int correctAnswers = 0;
  int wrongAnswers = 0;
  final DateTime startTime = DateTime.now();

  Map<int, String> userAnswers = {};

  List<bool> get answeredQuestions {
    return List.generate(
      questions.length,
      (index) => userAnswers.containsKey(index),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.quizQuestions != null) {
      questions = widget.quizQuestions!;
      isLoading = false;
      _startTimer();
    } else if (widget.questions != null) {
      questions = widget.questions!
          .map((q) => QuizQuestion.fromJson(q))
          .toList();
      isLoading = false;
      _startTimer();
    } else {
      _loadQuestions();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          _timer.cancel();
          _showResults(isTimeOut: true);
        }
      });
    });
  }


  void _selectAnswer(String optionId) {
    setState(() {
      selectedAnswer = optionId;
      userAnswers[currentQuestionIndex] = optionId;
    });
  }

  Future<void> _loadQuestions() async {
    try {
      final loadedQuestions =
          await _quizService.loadQuizQuestions(widget.category);
      if (mounted) {
        setState(() {
          questions = loadedQuestions.data ?? [];
          isLoading = false;
          _startTimer();
        });
      }
    } catch (e) {
      print('Error in _loadQuestions: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  String _getLocalizedText(dynamic field) {
    if (field is Map<String, dynamic>) {
      final lang = AppLocalization.of(context).locale.languageCode;
      return field[lang] ?? field['tr'] ?? field['en'] ?? '';
    }
    return field?.toString() ?? '';
  }

  void _showResults({bool isTimeOut = false}) {
    _timer.cancel();

    int finalCorrect = 0;
    int finalWrong = 0;
    for (int i = 0; i < questions.length; i++) {
      final userAnswer = userAnswers[i];
      if (userAnswer != null) {
        if (userAnswer == questions[i].correctAnswer) {
          finalCorrect++;
        } else {
          finalWrong++;
        }
      }
    }

    setState(() {
      correctAnswers = finalCorrect;
      wrongAnswers = finalWrong;
    });

    final duration = DateTime.now().difference(startTime);
    final now = DateTime.now();
    final totalQ = questions.length;
    final empty = totalQ - finalCorrect - finalWrong;
    final score = totalQ > 0 ? (finalCorrect / totalQ) * 100 : 0.0;

    final userService = UserService();
    final examResult = ExamResult(
      id: now.millisecondsSinceEpoch.toString(),
      userId: userService.currentUserId,
      userName: userService.currentUserName,
      category: widget.category,
      totalQuestions: totalQ,
      correctAnswers: finalCorrect,
      scorePercentage: score,
      duration: duration,
      completedAt: now,
    );

    final List<Map<String, dynamic>> detailedAnswers = [];
    for (int i = 0; i < questions.length; i++) {
      final userAnswer = userAnswers[i];
      detailedAnswers.add({
        'question_id': questions[i].id,
        'selected_answer': userAnswer ?? '',
        'correct_answer': questions[i].correctAnswer,
        'is_correct': userAnswer == questions[i].correctAnswer,
      });
    }

    final durationSeconds = duration.inSeconds;

    _quizService.submitExamResult(
      category: widget.category,
      correctAnswers: finalCorrect,
      wrongAnswers: finalWrong,
      emptyAnswers: empty,
      scorePercentage: score,
      completedAt: now,
      examType: widget.examType ?? (widget.examTitle.toLowerCase().contains('mock') || widget.examTitle.contains('Deneme') ? 'mock' : 'category'),
      difficulty: widget.difficulty ?? 'medium',
      durationSeconds: durationSeconds,
      answers: detailedAnswers,
    ).then((res) {
      if (!res.success) {
        print('Exam result submit failed: ${res.message}');
      }
    });

    ExamResultService().saveExamResult(examResult).then((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            totalQuestions: totalQ,
            correctAnswers: finalCorrect,
            totalTime: duration,
            isTimeOut: isTimeOut,
            questions: questions,
            userAnswers: userAnswers,
          ),
        ),
      );
    });
  }

  Future<void> _showReportDialog(String questionId) async {
    final TextEditingController reportController = TextEditingController();
    final l10n = AppLocalization.of(context);
    final reportService = ReportService();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('report.title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('report.description')),
            const SizedBox(height: 16),
            TextField(
              controller: reportController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.translate('report.hint'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('report.cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reportController.text.trim().isEmpty) return;
              
              final response = await reportService.reportQuestion(
                questionId: questionId,
                description: reportController.text.trim(),
                context: context,
              );

              if (mounted) {
                Navigator.pop(context);
                if (response.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.translate('report.success'))),
                  );
                }
              }
            },
            child: Text(l10n.translate('report.submit')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || questions.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.examTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.report_gmailerrorred, color: colorScheme.error),
            onPressed: () => _showReportDialog(currentQuestion.id),
          ),
          IconButton(
            icon: Icon(Icons.grid_view, color: colorScheme.onSurface),
            onPressed: () {
              QuestionNavigationDialog.show(
                context,
                currentQuestion: currentQuestionIndex + 1,
                totalQuestions: questions.length,
                answeredQuestions: answeredQuestions,
                onQuestionSelected: (index) {
                  setState(() {
                    currentQuestionIndex = index - 1;
                  });
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: colorScheme.surface,
            child: QuizProgressWidget(
              currentQuestion: currentQuestionIndex + 1,
              totalQuestions: questions.length,
              timeRemaining: Duration(seconds: remainingSeconds),
              showTimer: true,
              progressColor: colorScheme.primary,
              answeredQuestions: answeredQuestions,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalization.of(context)
                          .translate('quiz.question_badge')
                          .replaceFirst('%d', '${currentQuestionIndex + 1}'),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getLocalizedText(currentQuestion.question),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...currentQuestion.options.map((option) => _buildOptionItem(
                        context: context,
                        option: option,
                        isSelected:
                            userAnswers[currentQuestionIndex] == option.id,
                        onTap: () {
                          setState(() {
                            userAnswers[currentQuestionIndex] = option.id;
                          });
                        },
                      )),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: currentQuestionIndex > 0
                      ? () {
                          setState(() {
                            currentQuestionIndex--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(AppLocalization.of(context)
                      .translate('quiz.buttons.previous')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceVariant,
                    foregroundColor: colorScheme.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (currentQuestionIndex == questions.length - 1) {
                      _showResults();
                    } else {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    }
                  },
                  icon: Icon(
                    currentQuestionIndex == questions.length - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                    color: colorScheme.onPrimary,
                  ),
                  label: Text(
                    currentQuestionIndex == questions.length - 1
                        ? AppLocalization.of(context)
                            .translate('quiz.buttons.finish')
                        : AppLocalization.of(context)
                            .translate('quiz.buttons.next'),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required Option option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(option.id),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outline,
                width: 1,
              ),
              boxShadow: [
                if (!isSelected)
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
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
                      width: 2,
                    ),
                    color:
                        isSelected ? colorScheme.onPrimary : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _getLocalizedText(option.text),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

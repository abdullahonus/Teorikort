import 'package:driving_license_exam/features/quiz/data/models/quiz_data.dart';
import 'package:driving_license_exam/features/quiz/data/services/quiz_service.dart';
import 'package:driving_license_exam/features/quiz/presentation/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:driving_license_exam/features/quiz/presentation/widgets/question_navigation_dialog.dart';
import 'package:driving_license_exam/features/exam/data/models/exam_result.dart';
import 'package:driving_license_exam/features/exam/data/services/exam_result_service.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';
import 'package:driving_license_exam/core/services/user_service.dart';

class QuizScreen extends StatefulWidget {
  final String examTitle;
  final List<Map<String, dynamic>>? questions;
  final String category;

  const QuizScreen({
    super.key,
    required this.examTitle,
    this.questions,
    this.category = 'traffic_signs',
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  List<QuizQuestion> questions = [];
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool isLoading = true;
  late int remainingSeconds; // Her soru için 2 dakika

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
    if (widget.questions != null) {
      // Mock sınavından gelen soruları kullan
      _convertAndLoadQuestions();
      // Her soru için 2 dakika süre ver
      remainingSeconds = widget.questions!.length * 10;
    } else {
      // Normal quiz soruları için QuizService'i kullan
      _loadQuestions();
      remainingSeconds = 60; // Varsayılan süre
    }
    _startTimer();
  }

  void _convertAndLoadQuestions() {
    try {
      final convertedQuestions = widget.questions!.map((q) {
        return QuizQuestion(
          id: q['id'] as String,
          question: q['question'] as String,
          imageUrl: q['image_url'] as String?,
          options: (q['options'] as List<dynamic>).asMap().entries.map((entry) {
            return Option(
              id: entry.key.toString(),
              text: entry.value as String,
            );
          }).toList(),
          correctAnswer: q['correct_answer'].toString(),
          explanation: q['explanation'] as String,
        );
      }).toList();

      setState(() {
        questions = convertedQuestions;
        isLoading = false;
      });
    } catch (e) {
      print('Error converting questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  void _moveToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
      });
    } else {
      _calculateFinalScore();
    }
  }

  void _selectAnswer(String optionId) {
    setState(() {
      selectedAnswer = optionId;
      // Store the selected answer
      userAnswers[currentQuestionIndex] = optionId;

      // Check if the answer is correct
      final currentQuestion = questions[currentQuestionIndex];
      final isCorrect = optionId == currentQuestion.correctAnswer;

      if (isCorrect) {
        correctAnswers++;
      } else {
        wrongAnswers++;
      }

      print(
          'Answer selected for question ${currentQuestionIndex + 1}: $optionId');
      print('Correct answer: ${currentQuestion.correctAnswer}');
      print('Is correct: $isCorrect');
    });
  }

  Future<void> _loadQuestions() async {
    try {
      final loadedQuestions =
          await _quizService.loadQuizQuestions(widget.category);
      if (mounted) {
        setState(() {
          questions = loadedQuestions;
          isLoading = false;
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

  // Final score calculation
  void _calculateFinalScore() {
    correctAnswers = 0;
    wrongAnswers = 0;

    // Check all answers
    for (int i = 0; i < questions.length; i++) {
      final userAnswer = userAnswers[i];
      if (userAnswer != null) {
        if (userAnswer == questions[i].correctAnswer) {
          correctAnswers++;
        } else {
          wrongAnswers++;
        }
      }
    }

    print('Final Score:');
    print('Total Questions: ${questions.length}');
    print('Correct Answers: $correctAnswers');
    print('Wrong Answers: $wrongAnswers');

    _showResults();
  }

  void _showResults({bool isTimeOut = false}) {
    _timer.cancel();
    final duration = DateTime.now().difference(startTime);

    // Sonucu kaydet
    final userService = UserService();
    final examResult = ExamResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userService.currentUserId,
      userName: userService.currentUserName,
      category: widget.category,
      totalQuestions: questions.length,
      correctAnswers: correctAnswers,
      scorePercentage: (correctAnswers / questions.length) * 100,
      duration: duration,
      completedAt: DateTime.now(),
    );

    ExamResultService().saveExamResult(examResult).then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            totalQuestions: questions.length,
            correctAnswers: correctAnswers,
            totalTime: duration,
            isTimeOut: isTimeOut,
            questions: questions,
            userAnswers: userAnswers,
          ),
        ),
      );
    });
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

    // Toplam süreyi hesapla (başlangıçtaki süre)
    final totalSeconds =
        widget.questions != null ? widget.questions!.length * 10 : 60;

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
            icon: Icon(Icons.grid_view, color: colorScheme.onPrimary),
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
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: remainingSeconds /
                      totalSeconds, // Süre göstergesini toplam süreye göre hesapla
                  backgroundColor: colorScheme.onPrimary.withOpacity(0.2),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soru ${currentQuestionIndex + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQuestion.question,
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
          Padding(
            padding: const EdgeInsets.all(20.0),
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
                  icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
                  label: Text(
                    'Prev',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    disabledBackgroundColor:
                        colorScheme.surfaceContainerHighest,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (currentQuestionIndex == questions.length - 1) {
                      _showResults(isTimeOut: false);
                    } else {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    }
                  },
                  label: Text(
                    'Next',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  icon: Icon(Icons.arrow_forward, color: colorScheme.onPrimary),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
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
                    option.text,
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

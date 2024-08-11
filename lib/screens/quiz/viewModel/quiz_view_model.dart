import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:taxi/screens/quiz_screen.dart';
import 'package:taxi/service/quiz_service.dart';

mixin QuizViewModel on State<QuizScreen> {
  final Map<int, List<String>> shuffledAnswers = {};
  ValueNotifier<int> selectQuestion = ValueNotifier(0);
  ValueNotifier<String?> selectedOption = ValueNotifier(null);
  bool showCorrect = false;
  Timer? questionTimer;
  ValueNotifier<int> timerSeconds = ValueNotifier(10);
  bool isTimerCancel = false;

  ValueNotifier<Map<String, String>?> quizAnswers = ValueNotifier(null);

  final PageController pageController = PageController();

  final IQuizService quizService = QuizService();

  @override
  void initState() {
    super.initState();
    quizAnswers.value = {};
    qustionTimer();
  }

  @override
  void dispose() {
    super.dispose();
    log("dispose");
    questionTimer?.cancel();
    isTimerCancel = true;
  }

  void qustionTimer() {
    if (isTimerCancel) return;
    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isTimerCancel) {
        questionTimer?.cancel();
        timer.cancel();
        return;
      }
      timerSeconds.value--;
      if (timerSeconds.value > 0) {
        return;
      }
      selectQuestion.value++;
      quizAnswers.value?.update(selectQuestion.value.toString(), (value) => "",
          ifAbsent: () => "");

      if (selectQuestion.value == 10) {
        questionTimer?.cancel();
        timer.cancel();
        setState(() {});
        return;
      }
      questionTimer?.cancel();
      timer.cancel();
      timerSeconds = ValueNotifier(10);

      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      qustionTimer();

      setState(() {});
    });
  }

  void onOptionTap({
    required String answerOption,
    required String correctOption,
  }) {
    log("selectQuestion: ${selectQuestion.value}, correctOption: $correctOption");

    if (selectQuestion.value == 10) {
      log("Quiz Completed");
      setState(() {});
      return;
    }
    questionTimer?.cancel();
    timerSeconds = ValueNotifier(10);

    if (selectedOption.value != null) return;
    quizAnswers.value?.update(
        selectQuestion.value.toString(), (value) => answerOption,
        ifAbsent: () => answerOption);
    log("answersLength: ${quizAnswers.value?.length}");
    quizAnswersCheck(index: selectQuestion.value, answerOption: answerOption);
    selectedOption.value = answerOption;

    if (answerOption != correctOption) {
      showCorrect = true;
    }
    if (selectQuestion.value == 9) {
      log("Quiz Completed");
      setState(() {});
      return;
    }
    Future.delayed(const Duration(milliseconds: 500), () async {
      nextQuesiton(selectQuestion.value + 1);

      await pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      qustionTimer();

      setState(() {});
    });
  }

  Future<Map<String, dynamic>?> getQuizList() async {
    return quizService.getQuiz();
  }

  void nextQuesiton(int index) {
    selectQuestion.value = index;
    log("selectQuestion: ${selectQuestion.value}");
    selectedOption.value = null;
    showCorrect = false;
  }

  bool? quizAnswersCheck({
    required int index,
    required String answerOption,
  }) {
    log("answers: ${quizAnswers.value}");
    log("index: ${index + 1}, answerOption: $answerOption");

    if (quizAnswers.value == null) return null;
    return quizAnswers.value!.containsKey("${index + 1}") &&
            quizAnswers.value!["${index + 1}"] == ""
        ? null
        : quizAnswers.value!["${index + 1}"] == answerOption
            ? true
            : false;
  }
}

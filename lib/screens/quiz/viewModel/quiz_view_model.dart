import 'package:flutter/material.dart';
import 'package:taxi/screens/quiz_screen.dart';
import 'package:taxi/service/quiz_service.dart';

mixin QuizViewModel on State<QuizScreen> {
  int? selectedOption;
  final int correctOption = 0; // Doğru cevabın indexi
  bool showCorrect = false;
  Map<String, dynamic>? quizData;

  final IQuizService quizService = QuizService();

  void onOptionTap(int index) {
    setState(() {
      selectedOption = index;
      if (index != correctOption) {
        showCorrect = true;
      }
    });
  }

  Future<void> getQuizList() async {
    quizData = await quizService.getQuiz();
  }
}

import 'package:driving_license_exam/core/localization/app_localization.dart';
import 'package:flutter/material.dart';

class QuestionNavigationDialog extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final List<bool> answeredQuestions;
  final Function(int) onQuestionSelected;

  const QuestionNavigationDialog({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.onQuestionSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required int currentQuestion,
    required int totalQuestions,
    required List<bool> answeredQuestions,
    required Function(int) onQuestionSelected,
  }) {
    final appBarHeight = AppBar().preferredSize.height;
    const bottomHeight = 64.0; // AppBar bottom height'ı 80'e güncellendi
    final topPadding = appBarHeight + bottomHeight;

    return showDialog(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Dialog(
          alignment: Alignment.topRight,
          insetPadding: const EdgeInsets.only(left: 60),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          child: QuestionNavigationDialog(
            currentQuestion: currentQuestion,
            totalQuestions: totalQuestions,
            answeredQuestions: answeredQuestions,
            onQuestionSelected: onQuestionSelected,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(context),
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildQuestionGrid(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const IconButton(onPressed: null, icon: SizedBox.shrink()),
          Text(
            AppLocalization.of(context).translate('quiz.question_list'),
            style: const TextStyle(
              color: Color(0xFF1A237E),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF1A237E),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionGrid(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: totalQuestions,
          itemBuilder: (context, index) {
            final questionNumber = index + 1;
            final isCurrentQuestion = questionNumber == currentQuestion;
            final isAnswered = answeredQuestions[index];

            return InkWell(
              onTap: () {
                onQuestionSelected(questionNumber);
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isAnswered || isCurrentQuestion
                      ? const Color(0xFF1A237E)
                      : Colors.white,
                  border: Border.all(
                    color: const Color(0xFF1A237E),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        questionNumber < 10
                            ? '0$questionNumber'
                            : '$questionNumber',
                        style: TextStyle(
                          color: isAnswered || isCurrentQuestion
                              ? Colors.white
                              : const Color(0xFF1A237E),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (isCurrentQuestion)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class QuestionNavigationOverlay extends StatefulWidget {
  final int currentQuestion;
  final int totalQuestions;
  final List<bool> answeredQuestions;
  final Function(int) onQuestionSelected;

  const QuestionNavigationOverlay({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.onQuestionSelected,
  });

  @override
  State<QuestionNavigationOverlay> createState() =>
      _QuestionNavigationOverlayState();
}

class _QuestionNavigationOverlayState extends State<QuestionNavigationOverlay> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (!_isExpanded) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                _buildQuestionGrid(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 24),
          const Text(
            'Question list',
            style: TextStyle(
              color: Color(0xFF1A237E),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isExpanded = false;
              });
            },
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

  Widget _buildQuestionGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: widget.totalQuestions,
            itemBuilder: (context, index) {
              final questionNumber = index + 1;
              final isCurrentQuestion = questionNumber == widget.currentQuestion;
              final isAnswered = widget.answeredQuestions[index];

              return InkWell(
                onTap: () => widget.onQuestionSelected(questionNumber),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';
import 'package:driving_license_exam/features/quiz/presentation/quiz_screen.dart';
import 'package:driving_license_exam/features/exam/data/services/mock_exam_service.dart';

class MockExamDifficultyScreen extends StatelessWidget {
  const MockExamDifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          AppLocalization.of(context).translate('mock_exam.select_difficulty'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalization.of(context).translate('mock_exam.description'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 32),
            _buildDifficultyCard(
              context,
              'difficulty_levels.easy',
              'mock_exam.easy_description',
              Icons.sentiment_satisfied,
              Colors.green,
              () => _startExam(context, 'easy'),
            ),
            const SizedBox(height: 16),
            _buildDifficultyCard(
              context,
              'difficulty_levels.medium',
              'mock_exam.medium_description',
              Icons.sentiment_neutral,
              Colors.orange,
              () => _startExam(context, 'medium'),
            ),
            const SizedBox(height: 16),
            _buildDifficultyCard(
              context,
              'difficulty_levels.hard',
              'mock_exam.hard_description',
              Icons.sentiment_dissatisfied,
              Colors.red,
              () => _startExam(context, 'hard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context,
    String titleKey,
    String descriptionKey,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalization.of(context).translate(titleKey),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalization.of(context).translate(descriptionKey),
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startExam(BuildContext context, String difficulty) async {
    try {
      // Yükleniyor göstergesi
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Soruları yükle
      final questions =
          await MockExamService().getQuestionsByDifficulty(difficulty);

      if (questions.isEmpty) {
        Navigator.pop(context); // Yükleniyor göstergesini kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalization.of(context).translate('common.error')),
          ),
        );
        return;
      }

      // Sınav başlığını oluştur
      String examTitle =
          '${AppLocalization.of(context).translate('exam_types.mock')} - ${AppLocalization.of(context).translate('difficulty_levels.$difficulty')}';

      // Yükleniyor göstergesini kapat
      Navigator.pop(context);

      // Quiz ekranına git
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            examTitle: examTitle,
            questions: questions, // Soruları QuizScreen'e gönder
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Yükleniyor göstergesini kapat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalization.of(context).translate('common.error')),
        ),
      );
    }
  }
}

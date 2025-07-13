import 'package:flutter/material.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';

class QuizProgressWidget extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final Duration? timeRemaining;
  final bool showTimer;
  final Color? progressColor;
  final Color? backgroundColor;
  final List<bool>?
      answeredQuestions; // Hangi soruların cevaplanmış olduğunu gösterir

  const QuizProgressWidget({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    this.timeRemaining,
    this.showTimer = false,
    this.progressColor,
    this.backgroundColor,
    this.answeredQuestions,
  });

  double get progressPercentage => currentQuestion / totalQuestions;
  int get remainingQuestions => totalQuestions - currentQuestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with question counter and timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuestionCounter(theme),
              if (showTimer && timeRemaining != null) _buildTimer(theme),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          _buildProgressBar(theme),

          const SizedBox(height: 8),

          // Bottom row with percentage and remaining questions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPercentageText(theme, context),
              _buildRemainingText(theme, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCounter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: progressColor ?? theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$currentQuestion / $totalQuestions',
        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTimer(ThemeData theme) {
    final minutes = timeRemaining!.inMinutes;
    final seconds = timeRemaining!.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: minutes < 5 ? Colors.red : Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return Column(
      children: [
        // Main progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Progress
              FractionallySizedBox(
                widthFactor: progressPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: progressColor ?? theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Step indicators
        _buildStepIndicators(theme),
      ],
    );
  }

  Widget _buildStepIndicators(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        totalQuestions > 10 ? 10 : totalQuestions,
        (index) {
          final stepNumber = totalQuestions > 10
              ? ((index + 1) * totalQuestions / 10).round()
              : index + 1;

          final isCompleted = currentQuestion > stepNumber;
          final isCurrent = currentQuestion == stepNumber;

          // Check if this question is answered
          bool isAnswered = false;
          if (answeredQuestions != null &&
              stepNumber <= answeredQuestions!.length) {
            isAnswered = answeredQuestions![stepNumber - 1];
          }

          Color backgroundColor;
          Color textColor;
          Widget? icon;

          if (isCompleted && isAnswered) {
            // Completed and answered - Green
            backgroundColor = Colors.green;
            textColor = Colors.white;
            icon = const Icon(Icons.check, size: 14, color: Colors.white);
          } else if (isCompleted && !isAnswered) {
            // Completed but not answered - Orange
            backgroundColor = Colors.orange;
            textColor = Colors.white;
            icon = const Icon(Icons.remove, size: 14, color: Colors.white);
          } else if (isCurrent) {
            // Current question - Primary color
            backgroundColor =
                (progressColor ?? theme.colorScheme.primary).withOpacity(0.3);
            textColor = progressColor ?? theme.colorScheme.primary;
          } else {
            // Not reached yet - Grey
            backgroundColor = theme.colorScheme.surfaceVariant;
            textColor = theme.colorScheme.onSurfaceVariant;
          }

          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(
                      color: progressColor ?? theme.colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Center(
              child: icon ??
                  Text(
                    stepNumber.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPercentageText(ThemeData theme, BuildContext context) {
    return Text(
      '${(progressPercentage * 100).toInt()}% ${AppLocalization.of(context).translate('quiz.progress.completed')}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildRemainingText(ThemeData theme, BuildContext context) {
    return Text(
      '$remainingQuestions ${AppLocalization.of(context).translate('quiz.progress.questions_remaining')}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// Compact version for smaller spaces
class QuizProgressCompact extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final Color? progressColor;

  const QuizProgressCompact({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    this.progressColor,
  });

  double get progressPercentage => currentQuestion / totalQuestions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Question counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: progressColor ?? theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$currentQuestion/$totalQuestions',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Progress bar
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: progressColor ?? theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Percentage
          Text(
            '${(progressPercentage * 100).toInt()}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Animated progress widget
class QuizProgressAnimated extends StatefulWidget {
  final int currentQuestion;
  final int totalQuestions;
  final Duration animationDuration;
  final Color? progressColor;

  const QuizProgressAnimated({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    this.animationDuration = const Duration(milliseconds: 300),
    this.progressColor,
  });

  @override
  State<QuizProgressAnimated> createState() => _QuizProgressAnimatedState();
}

class _QuizProgressAnimatedState extends State<QuizProgressAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.currentQuestion / widget.totalQuestions,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(QuizProgressAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentQuestion != widget.currentQuestion) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.currentQuestion / widget.totalQuestions,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalization.of(context)
                        .translate('quiz.progress.question_counter')
                        .replaceFirst('%d', '${widget.currentQuestion}')
                        .replaceFirst('%d', '${widget.totalQuestions}'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(_animation.value * 100).toInt()}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: widget.progressColor ?? theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _animation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.progressColor ?? theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:taxi/extencions/general.dart';

class LineProgressIndicator extends StatelessWidget {
  const LineProgressIndicator({
    super.key,
    required this.solvedQuestion,
    required this.amount,
    required this.title,
    required this.color,
    required double value,
  });

  final double solvedQuestion;
  final int amount;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.paddingTop(10.0),
          child: Row(
            children: [
              Text(
                title,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "${solvedQuestion.toStringAsFixed(0)} / ",
              ),
              Text("$amount"),
              SizedBox(
                width: context.width(.1),
              ),
            ],
          ),
        ),
        Padding(
          padding: context.paddingVertical(10),
          child: SimpleAnimationProgressBar(
            height: context.height(.005),
            width: MediaQuery.of(context).size.width / 2.2,
            backgroundColor: Colors.grey,
            foregrondColor: color,
            ratio: solvedQuestion,
            direction: Axis.horizontal,
            curve: Curves.fastLinearToSlowEaseIn,
            duration: const Duration(seconds: 3),
            borderRadius: BorderRadius.circular(10),
          ),
        )
      ],
    );
  }
}

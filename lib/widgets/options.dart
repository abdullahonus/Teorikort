import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChoiceOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool showCorrect;
  final VoidCallback onTap;

  const ChoiceOption({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.showCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected
              ? (isCorrect ? Colors.green.shade300 : Colors.red.shade200)
              : (showCorrect && isCorrect
                  ? Colors.green.shade300
                  : Colors.transparent),
          border: Border.all(
            color: isSelected
                ? (isCorrect ? Colors.green.shade300 : Colors.red.shade200)
                : (showCorrect && isCorrect
                    ? Colors.green.shade300
                    : Colors.grey),
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            SizedBox(width: 20.h),
            Icon(
              isSelected
                  ? (isCorrect ? Icons.check_circle_outline : Icons.close)
                  : (showCorrect && isCorrect
                      ? Icons.check_circle_outline
                      : Icons.circle_outlined),
              color: isSelected || (showCorrect && isCorrect)
                  ? Colors.white
                  : Colors.grey,
              size: 32.h,
            ),
            const SizedBox(width: 20),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12.h,
                  fontWeight: FontWeight.w500,
                  color: isSelected || (showCorrect && isCorrect)
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            SizedBox(width: 20.h),
          ],
        ),
      ),
    );
  }
}

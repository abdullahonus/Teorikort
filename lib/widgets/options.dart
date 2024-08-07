import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChoiceOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;

  const ChoiceOption({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected
              ? (isCorrect ? Colors.green.shade300 : Colors.red.shade200)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? (isCorrect ? Colors.green.shade300 : Colors.red.shade200)
                : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            SizedBox(width: 20.h),
            Icon(
              isSelected
                  ? (isCorrect ? Icons.check_circle_outline : Icons.close)
                  : Icons.circle_outlined,
              color: isSelected ? Colors.white : Colors.grey,
              size: 35.h,
            ),
            const SizedBox(width: 20),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.h,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi/widgets/options.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? selectedOption;
  final int correctOption = 0; // Doğru cevabın indexi
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Soru ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.h,
                    ),
                  ),
                  Text(
                    "1",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.h,
                    ),
                  ),
                  Text(
                    "/20",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      fontSize: 20.h,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                "Ailesiyle ile birlikte yolculuk yapan bir sürücü, aracını hız limitlerini aşakrak sürdüğünde ailesinin hayatındı da tehlikeye atmış olacaktır. Bu sürücü Hız",
                style: TextStyle(fontSize: 17.h, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 20.w,
              ),
              ChoiceOption(
                text: "A) 50 km/s",
                isSelected: selectedOption == 0,
                isCorrect: correctOption == 0,
                onTap: () {
                  setState(() {
                    selectedOption = 0;
                  });
                },
              ),
              SizedBox(height: 12.h),
              ChoiceOption(
                text: "B) 60 km/s",
                isSelected: selectedOption == 1,
                isCorrect: correctOption == 1,
                onTap: () {
                  setState(() {
                    selectedOption = 1;
                  });
                },
              ),
              SizedBox(height: 12.h),
              ChoiceOption(
                text: "C) 70 km/s",
                isSelected: selectedOption == 2,
                isCorrect: correctOption == 2,
                onTap: () {
                  setState(() {
                    selectedOption = 2;
                  });
                },
              ),
              SizedBox(height: 12.h),
              ChoiceOption(
                text: "D) 80 km/s",
                isSelected: selectedOption == 3,
                isCorrect: correctOption == 3,
                onTap: () {
                  setState(() {
                    selectedOption = 3;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

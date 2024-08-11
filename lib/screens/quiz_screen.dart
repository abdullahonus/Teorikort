import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:taxi/product/widgets/options.dart';
import 'package:taxi/screens/quiz/viewModel/quiz_view_model.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with QuizViewModel {
  late Future<Map<String, dynamic>?> quizListfuture;
  @override
  void initState() {
    super.initState();
    quizListfuture = getQuizList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("Quiz"),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder(
            future: quizListfuture,
            builder: (context, snapshot) {
              final Map<String, dynamic>? quizData = snapshot.data;
              final List<dynamic>? results = quizData?['results'];
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (results == null || results.isEmpty) {
                    return const Center(
                      child: Text("Veri Yok"),
                    );
                  }
                  return Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 20.h,
                            child: ListView.builder(
                              itemCount: results.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemExtent: 16.w,
                              itemBuilder: (BuildContext context, int index) {
                                return ValueListenableBuilder<int>(
                                    valueListenable: selectQuestion,
                                    builder: (context, value, _) {
                                      return InkWell(
                                        onTap: () {
                                          nextQuesiton(index);
                                          questionTimer?.cancel();
                                          timerSeconds = ValueNotifier(0);
                                          pageController.jumpToPage(index);
                                        },
                                        child: Icon(
                                          index == value
                                              ? Icons.circle
                                              : Icons.circle_outlined,
                                          size: 14.w,
                                        ),
                                      );
                                    });
                              },
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                            child:
                                ValueListenableBuilder<Map<String, dynamic>?>(
                                    valueListenable: quizAnswers,
                                    builder: (context, value, _) {
                                      return ListView.builder(
                                        itemCount: value?.length,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemExtent: 16.w,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final bool? isCorret =
                                              quizAnswersCheck(
                                                  index: index,
                                                  answerOption: results[index]
                                                      ['correct_answer']);
                                          return InkWell(
                                            onTap: () {
                                              nextQuesiton(index);
                                              questionTimer?.cancel();
                                              timerSeconds = ValueNotifier(0);
                                              pageController.jumpToPage(index);
                                            },
                                            child: Icon(
                                              Icons.circle,
                                              size: 14.w,
                                              color: isCorret != null
                                                  ? (isCorret
                                                      ? Colors.green
                                                      : Colors.red)
                                                  : Colors.grey,
                                            ),
                                          );
                                        },
                                      );
                                    }),
                          ),
                        ],
                      ),
                      ValueListenableBuilder<int>(
                          valueListenable: timerSeconds,
                          builder: (context, second, _) {
                            return LinearProgressIndicator(
                              value: second / 10,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                              backgroundColor: Colors.grey.shade300,
                            );
                          }),
                      Flexible(
                        child: PageView.builder(
                          itemCount: results.length,
                          controller: pageController,
                          itemBuilder: (BuildContext context, int index) {
                            final String correctAnswer =
                                results[index]['correct_answer'];
                            if (!shuffledAnswers.containsKey(index)) {
                              final List<dynamic> incorrectAnswers =
                                  results[index]['incorrect_answers'];
                              final List<String> answers = [
                                ...incorrectAnswers,
                                correctAnswer
                              ]..shuffle();

                              shuffledAnswers[index] = answers;
                            }
                            final answers = shuffledAnswers[index];
                            return Column(
                              children: [
                                ListTile(
                                  minLeadingWidth: 0,
                                  dense: true,
                                  horizontalTitleGap: 10,
                                  minVerticalPadding: 13.w,
                                  leading: Text(
                                    "${index + 1}-",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.h,
                                    ),
                                  ),
                                  title: HtmlWidget(
                                    results[index]['question'],
                                    textStyle: TextStyle(
                                      fontSize: 13.h,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                ...answers!.map(
                                  (e) => Padding(
                                    padding: EdgeInsets.only(bottom: 10.w),
                                    child: ValueListenableBuilder<String?>(
                                        valueListenable: selectedOption,
                                        builder: (context, value, _) {
                                          return ChoiceOption(
                                            text: e,
                                            isSelected: selectedOption.value !=
                                                    null
                                                ? value == e
                                                : quizAnswers.value != null &&
                                                    quizAnswers.value!
                                                        .containsKey(
                                                            index.toString()) &&
                                                    quizAnswers.value![
                                                            index.toString()] ==
                                                        e,
                                            isCorrect: answers.indexOf(e) ==
                                                answers.indexOf(correctAnswer),
                                            showCorrect: showCorrect,
                                            onTap: () => onOptionTap(
                                              answerOption: e,
                                              correctOption: correctAnswer,
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );

                case ConnectionState.none:
                  return const Center(
                    child: Text("Bağlantı Hatası"),
                  );
              }
            },
          ),
        ));
  }
}


/*SingleChildScrollView(
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
                style: TextStyle(fontSize: 15.h, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 20.w,
              ),
              ChoiceOption(
                text: "A) 50 km/s",
                isSelected: selectedOption == 0,
                isCorrect: correctOption == 0,
                showCorrect: showCorrect,
                onTap: () => onOptionTap(0),
              ),
              SizedBox(height: 10.h),
              ChoiceOption(
                text: "B) 60 km/s",
                isSelected: selectedOption == 1,
                isCorrect: correctOption == 1,
                showCorrect: showCorrect,
                onTap: () => onOptionTap(1),
              ),
              SizedBox(height: 10.h),
              ChoiceOption(
                text: "C) 70 km/s",
                isSelected: selectedOption == 2,
                isCorrect: correctOption == 2,
                showCorrect: showCorrect,
                onTap: () => onOptionTap(2),
              ),
              SizedBox(height: 10.h),
              ChoiceOption(
                text: "D) 80 km/s",
                isSelected: selectedOption == 3,
                isCorrect: correctOption == 3,
                showCorrect: showCorrect,
                onTap: () => onOptionTap(3),
              ),
              Row(
                children: [
                  Container(
                    height: 45.h,
                    width: 100.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.arrow_back_ios),
                  ),
                ],
              )
            ],
          ),
        ),
      ), */
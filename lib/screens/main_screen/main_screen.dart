import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:taxi/extencions/general.dart';
import 'package:taxi/widgets/appBar_widget.dart';
import 'package:taxi/widgets/card_widget.dart';
import 'package:taxi/widgets/line_chart_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool circleButtonToggle = false;

  final List<Color> colorList = [
    Colors.blue,
    Colors.orange,
    Colors.red,
    Colors.yellow,
    Colors.teal,
    Colors.indigo,
    Colors.deepOrange,
    Colors.deepPurple,
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: HomeAppBar(context),
          body: Column(
            children: [
              Padding(
                padding: context.paddingLeft(20),
                child: Image.asset("assets/icons/car.png"),
              ),
              Padding(
                padding: context.paddingLeft(20.0),
                child: const LineProgressIndicator(
                  solvedQuestion: 20,
                  amount: 200,
                  title: "Geçme İhtimalin",
                  color: Colors.grey,
                  value: 100,
                ),
              ),
              Padding(
                padding: context.paddingLeft(20).copyWith(top: 10),
                child: Text(
                  "E-Sınav Testleri",
                  style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: context.paddingLeft(20).copyWith(top: 5, bottom: 10),
                child: Text(
                  "10 Test",
                  style: context.textTheme.bodySmall,
                ),
              ),
              _testCards(context),
              /*  _chartContainer(context), */
              CustomCard(
                borderRadius: BorderRadius.circular(10),
                child: const Column(
                  children: [],
                ),
              ),
            ],
          )),
    );
  }

  Container _testCards(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[350],
      ),
      width: context.width(1),
      height: context.height(0.17),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          // Toplam soru sayısı
          int totalQuestions = 100;

          // Çözülen soru sayısı (örneğin, kullanıcı 20 soruyu çözmüş)
          int solvedQuestions = 30;

          // Çözülmüş ve çözülmemiş soruların sayısı
          int remainingQuestions = totalQuestions - solvedQuestions;

          // Çözülmüş soruları ve geri kalan soruları içeren veri haritası
          Map<String, double> dataMap = {
            "Çözülen": solvedQuestions.toDouble(),
            "Geri kalan": remainingQuestions.toDouble(),
          };
          List<Color> questionColorList = [
            Colors.white,
            Colors.grey
          ]; // Çözülen sorular yeşil, geri kalanlar gri
          List<Color> randomColorList = List.generate(
            totalQuestions,
            (index) => colorList[index % colorList.length],
          );
          return CustomCard(
            margin: context.paddingAll(10),
            color:
                //burda eğer charttaki değer 0 ise colorı kırmızı olarak gösterecez
                randomColorList[index],
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            child: Column(
              children: [
                Padding(
                  padding: context.paddingHorizontal(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: context.paddingAll(10),
                          child: Text(
                            "Test ${index + 1}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                      const Icon(
                        Icons.arrow_circle_right_rounded,
                        size: 25,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                PieChart(
                  centerText:
                      "%${(solvedQuestions / totalQuestions * 100).toInt()}", // Yüzdeyi göster
                  dataMap: dataMap,
                  colorList: questionColorList,
                  chartType: ChartType.ring,
                  ringStrokeWidth: 5,
                  legendOptions: const LegendOptions(
                    showLegends: false,
                  ),
                  chartRadius: context.width(.15),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValueBackground: false,
                    showChartValues: false,
                  ),
                ),
                Container(
                    height: context.height(.02),
                    width: context.width(0.3),
                    color: Colors.white,
                    child: Text(_statusText(context,
                        remainingQuestions)) /*  remainingQuestions <= 30
                      ? Text(
                          "Kaldınız",
                        )
                      : Text(
                          "Geçtiniz",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ), */
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _statusText(BuildContext context, int x) {
    String text = "";
    if (x == 0) {
      text = "Sırada ki Test";
    } else if (x <= 20) {
      text = "Kaldınız";
    } else {
      text = "Geçtiniz";
    }
    return text;
  }

  Padding _chartContainer(BuildContext context) {
    return Padding(
      padding: context.paddingNormal,
      child: CustomCard(
        child: Padding(
          padding: context.paddingAll(20),
          child: Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("İstatistikler"),
                  LineProgressIndicator(
                    amount: 50,
                    value: 100,
                    title: "Mevcut Soru Sayısı",
                    color: Colors.purple,
                    solvedQuestion: 20,
                  ),
                  LineProgressIndicator(
                    amount: 50,
                    value: 100,
                    title: "Mevcut Konu Sayısı",
                    color: Colors.purple,
                    solvedQuestion: 20,
                  ),
                ],
              ),
              PieChart(
                centerText: "%50",
                dataMap: const {
                  "Yanlış": 50,
                  "Doğru": 50,
                },
                chartType: ChartType.ring,
                ringStrokeWidth: 10,
                legendOptions: const LegendOptions(
                  showLegends: false,
                ),
                chartRadius: context.width(.2),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValueBackground: false,
                  showChartValues: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:taxi/extencions/general.dart';
import 'package:taxi/screens/test/show_test_tabs.dart';
import 'package:taxi/widgets/appBar_widget.dart';
import 'package:taxi/widgets/card_widget.dart';
import 'package:taxi/widgets/line_chart_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: HomeAppBar(context),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(15.w),
                child: Image.asset("assets/icons/car.png"),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 15.w,
                ),
                child: const LineProgressIndicator(
                  solvedQuestion: 20,
                  amount: 200,
                  title: "Geçme İhtimalin",
                  color: Colors.grey,
                  value: 100,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.w, top: 10.h),
                child: Text(
                  "E-Sınav Testleri",
                  style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 15.w,
                    ),
                    child: Text(
                      "10 Test",
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 15.w,
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllTestTabs(),
                          ),
                        );
                      },
                      child: Text(
                        "Tümünü Gör",
                        style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              _testRowCards(),
              _mainRowCards(context),
              _mainListiles(context),
              /*   _chartContainer(context), */
            ],
          ),
        ));
  }

  Container _testRowCards() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[350],
      ),
      height: 150.w,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
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
          // Toplam soru sayısı
          int totalQuestions = 100;

          // Çözülen soru sayısı (örneğin, kullanıcı 20 soruyu çözmüş)
          int solvedQuestions = 20;

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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomCard(
                margin: const EdgeInsets.all(
                  10,
                ).copyWith(bottom: 0),
                color:
                    //burda eğer charttaki değer 0 ise colorı kırmızı olarak gösterecez
                    randomColorList[index],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
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
                          Icon(
                            Icons.arrow_circle_right_rounded,
                            size: 25.w,
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
                      ringStrokeWidth: 5.w,
                      legendOptions: const LegendOptions(
                        showLegends: false,
                      ),
                      chartRadius: 55.w,
                      centerTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValueBackground: false,
                        showChartValues: false,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 25.w,
                width: 116.5.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
                child: Text(
                  _statusText(context, remainingQuestions),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: remainingQuestions == 0
                        ? Colors.grey
                        : remainingQuestions <= 20
                            ? Colors.red
                            : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Padding _mainRowCards(BuildContext context) {
    return Padding(
      padding: context.paddingAll(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomCard(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: context.paddingAll(10),
                child: Row(
                  children: [
                    Icon(
                      Icons.align_vertical_bottom_sharp,
                      color: Colors.red.shade700,
                    ),
                    SizedBox(width: context.width(0.02)),
                    const Text("İstatistikler")
                  ],
                ),
              ),
            ),
            CustomCard(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: context.paddingAll(10),
                child: Row(
                  children: [
                    Icon(
                      Icons.question_mark_rounded,
                      color: Colors.red.shade700,
                    ),
                    SizedBox(width: context.width(0.02)),
                    const Text("Merak edilenler")
                  ],
                ),
              ),
            ),
            CustomCard(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: context.paddingAll(10),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark_border_rounded,
                      color: Colors.red.shade700,
                    ),
                    SizedBox(width: context.width(0.02)),
                    const Text("Kaydedilenler")
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Column _mainListiles(BuildContext context) {
    return Column(
      children: [
        _mainScreenListTileMethod(
          context,
          "İstatistikler",
          "Geçme ihtimalin ve testlerin",
          Icons.menu_book_sharp,
          Colors.blue,
        ),
        _mainScreenListTileMethod(
          context,
          "Trafik İşaretleri",
          "Açıklamalarıyla beraber tüm trafik işaretleri",
          Icons.traffic_rounded,
          Colors.red,
        ),
        _mainScreenListTileMethod(
          context,
          "Konu Testleri",
          "Geçme ihtimalin ve testlerin",
          Icons.assignment_turned_in_rounded,
          Colors.green,
        ),
        _mainScreenListTileMethod(
          context,
          "Yanlışlar Testi",
          "Geçme ihtimalin ve testlerin",
          Icons.error_rounded,
          Colors.brown,
        ),
      ],
    );
  }

  ListTile _mainScreenListTileMethod(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      onTap: () {},
      leading: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          onPressed: () {},
          color: color,
          icon: Icon(
            icon,
            size: context.width(0.08),
          ),
        ),
      ),
      subtitle: Text(
        subtitle,
        style:
            TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.grey.shade500,
        size: context.width(0.05),
      ),
    );
  }

  String _statusText(BuildContext context, int x) {
    String text = "";
    if (x == 0) {
      text = "Sonra ki";
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

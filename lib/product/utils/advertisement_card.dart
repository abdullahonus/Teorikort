import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi/product/widgets/card_widget.dart';

class AdvertisementWidget extends StatelessWidget {
  const AdvertisementWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderRadius: BorderRadius.all(Radius.circular(15.w)),
      color: Colors.grey[300],
      child: SizedBox(
        height: 150.w,
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 23, 27, 74),
                borderRadius: BorderRadius.all(
                  Radius.circular(15.w),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Text(
                      "Premium'a Yükseltin!",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.w,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.w),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: const Text(
                          "₺19,99",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.done,
                              color: Colors.green,
                              size: 15.w,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              "Sınırsız Test",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.w,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.done,
                              color: Colors.green,
                              size: 15.w,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              "Tüm Reklamları Kaldır",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.w,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.done,
                              color: Colors.green,
                              size: 15.w,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              "İnternetsiz Kullan",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.w,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.done,
                              color: Colors.green,
                              size: 15.w,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              "Tek Seferlik Öde",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.w,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15.w),
                  bottomRight: Radius.circular(15.w),
                ),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700), // Parlak turuncu
                    Color.fromARGB(255, 255, 98, 0), // Orta turuncu
                    Color.fromARGB(255, 255, 102, 0), // Metalik turuncu
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: Center(
                  child: Padding(
                padding: EdgeInsets.all(8.w),
                child: const Text(
                  "%67 İNDİRİM",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )),
            )
          ],
        ),
      ),
    );
  }
}

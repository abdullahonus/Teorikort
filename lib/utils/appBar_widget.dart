import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi/extencions/general.dart';

class HomeAppBar extends AppBar {
  HomeAppBar(BuildContext context,
      {super.key,
      TextEditingController? searchController,
      bool readOnly = false,
      bool autofocus = false,
      Widget? bottomWidget})
      : super(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: false,
          leadingWidth: context.width(0.8),
          toolbarHeight: context.height(0.12),
          leading: Padding(
            padding: context.paddingAll(20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ehliyet sınav soruları",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                Text("Driver Liceance",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 15.0.w),
              child: GestureDetector(
                child: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Image.asset('assets/icons/police.png', scale: 1.5)),
              ),
            )
          ],
        );
}

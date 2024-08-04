import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi/utils/advertisement_card.dart';
import 'package:taxi/widgets/card_widget.dart';
import 'package:taxi/widgets/transparent_appbar_widget.dart';

class AllTestTabs extends StatelessWidget {
  const AllTestTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TransparentAppBar(
        title: const Text("E-Sınav"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 20.0.w),
              child: const Text(
                "10 Test",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10.w),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              //premium olmayan üyelere çıkacak
              const AdvertisementWidget(),
              _failedListTileMethod(),

              _passedListTile(),

              _notSolvedListTile(),

              _premiumListTile(),
              _premiumListTile(), _premiumListTile(), _premiumListTile(),
              _premiumListTile(),
            ],
          ),
        ),
      ),
    );
  }

  CustomCard _premiumListTile() {
    return CustomCard(
      borderRadius: const BorderRadius.all(
        Radius.circular(20),
      ),
      color: Colors.grey.shade200,
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child:
              Icon(Icons.lock_outline_sharp, color: Colors.orange, size: 20.w),
        ),
        trailing: CircleAvatar(
          backgroundColor: Colors.white,
          child:
              Icon(Icons.play_arrow_rounded, color: Colors.orange, size: 30.w),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Test 4",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.w,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "Kilidi Aç!",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.w,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  CustomCard _notSolvedListTile() {
    return CustomCard(
      borderRadius: const BorderRadius.all(
        Radius.circular(20),
      ),
      color: Colors.grey.shade200,
      elevation: 0,
      child: ListTile(
        leading: Icon(Icons.circle_outlined, color: Colors.white, size: 40.w),
        trailing:
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 15.w),
        title: Text(
          "Test 3",
          style: TextStyle(
              color: Colors.black, fontSize: 15.w, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Şimdi Çöz!",
          style: TextStyle(
              color: Colors.grey, fontSize: 12.w, fontWeight: FontWeight.w500),
        ),
        onTap: () {},
      ),
    );
  }

  CustomCard _passedListTile() {
    return CustomCard(
      borderRadius: const BorderRadius.all(
        Radius.circular(20),
      ),
      color: Colors.green.shade100,
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.done, color: Colors.white, size: 20.w),
        ),
        trailing:
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 15.w),
        title: Text(
          "Test 2",
          style: TextStyle(
              color: Colors.black, fontSize: 15.w, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Geçtin!",
          style: TextStyle(
              color: Colors.grey, fontSize: 12.w, fontWeight: FontWeight.w500),
        ),
        onTap: () {},
      ),
    );
  }

  CustomCard _failedListTileMethod() {
    return CustomCard(
      borderRadius: const BorderRadius.all(
        Radius.circular(20),
      ),
      color: Colors.red.shade100,
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.close, color: Colors.white, size: 20.w),
        ),
        trailing:
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 15.w),
        title: Text(
          "Test 1",
          style: TextStyle(
              color: Colors.black, fontSize: 15.w, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Kaldın!",
          style: TextStyle(
              color: Colors.grey, fontSize: 12.w, fontWeight: FontWeight.w500),
        ),
        onTap: () {},
      ),
    );
  }
}

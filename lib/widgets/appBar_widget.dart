import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:taxi/extencions/general.dart';
import 'package:taxi/screens/main_screen/main_screen.dart';
import 'package:taxi/widgets/bottom_sheet_listtile_button_widget.dart';

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
            GestureDetector(
              onTap: () => showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                isDismissible: true,
                isScrollControlled: true,
                constraints: BoxConstraints(maxHeight: 0.9.sh),
                builder: (BuildContext bc) {
                  return DecoratedBox(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      color: Colors.white,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 20.w),
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                              color: Colors.white,
                            ),
                            // margin: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    //Account Screen
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(
                                        top: 16.w, right: 5.w, left: 5.5.w),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CircleAvatar(
                                          child: SvgPicture.asset(
                                            "assets/icons/svg/img_account-profile-empty.svg",
                                            width: 18.w,
                                            height: 18.w,
                                          ),
                                        ),
                                      ),
                                      title: Text("User Name"),
                                      subtitle: Text("User Phone"),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ),
                                BottomSheetListTileButton(
                                  routePage: const MainScreen(),
                                  title: 'Ayarlar',
                                  icon: Container(
                                    margin: const EdgeInsets.only(
                                        top: 15, left: 12),
                                    child: const Icon(
                                      Icons.settings,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30.w),
                        ],
                      ),
                    ),
                  );
                },
              ),
              child: Padding(
                padding: EdgeInsets.only(right: 15.0.w),
                child: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Image.asset('assets/icons/police.png', scale: 1.5)),
              ),
            )
          ],
        );
}

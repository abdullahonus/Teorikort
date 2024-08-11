import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransparentAppBar extends AppBar {
  TransparentAppBar(
      {super.key,
      super.leading = const SizedBox(),
      super.title,
      super.centerTitle = true,
      super.backgroundColor = Colors.transparent,
      super.foregroundColor = Colors.black,
      super.elevation = 0,
      super.actions,
      super.leadingWidth,
      super.toolbarHeight,
      super.systemOverlayStyle = const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      )});
}

import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  Size get mediaQuerySize => MediaQuery.sizeOf(this);
  bool get isKeyboardOpen => MediaQuery.viewInsetsOf(this).bottom > 0;
}

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
}

extension MediaQueryExtension on BuildContext {
  double get h => mediaQuerySize.height;
  double get w => mediaQuerySize.width;
  double height(double val) => h * val;
  double width(double val) => w * val;
}


extension PaddingExtension on BuildContext {
  EdgeInsets get paddingNormal =>
      EdgeInsets.only(top: width(.036), left: width(.036), right: width(.036));
  EdgeInsets paddingAll(double val) => EdgeInsets.all(val);
  EdgeInsets paddingHorizontal(double val) =>
      EdgeInsets.symmetric(horizontal: val);
  EdgeInsets get paddingHorizontalNormal =>
      EdgeInsets.symmetric(horizontal: width(.036));
  EdgeInsets paddingVertical(double val) => EdgeInsets.symmetric(vertical: val);
  EdgeInsets paddingBottom(double val) => EdgeInsets.only(bottom: val);
  EdgeInsets paddingTop(double val) => EdgeInsets.only(top: val);
  EdgeInsets paddingLeft(double val) => EdgeInsets.only(left: val);
  EdgeInsets paddingRight(double val) => EdgeInsets.only(right: val);
}

extension RadiusExtension on BuildContext {
  Radius radius(double val) => Radius.circular(val);
}

extension BorderExtension on BuildContext {
  BorderRadius borderRadiusAll(double val) => BorderRadius.circular(val);
}

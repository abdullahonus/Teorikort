import 'package:flutter/material.dart';

class CustomCard extends Card {
  CustomCard(
      {super.key,
      super.color,
      Color? shadowColor,
      ShapeBorder? shape,
      BorderSide? side,
      BorderRadiusGeometry? borderRadius,
      super.margin,
      super.child,
      double? elevation})
      : super(
          shadowColor: shadowColor ?? Colors.grey.withOpacity(.2),
          shape: shape ??
              RoundedRectangleBorder(
                
                borderRadius: borderRadius ?? BorderRadius.circular(10),
              ),
        );
}

import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? height;
  final Widget? child;

  const CustomElevatedButton(
      {super.key,
      this.text,
      required this.onPressed,
      this.isLoading = false,
      this.backgroundColor,
      this.textColor,
      this.borderColor,
      this.height,
      this.child,
      this.disabledBackgroundColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.blue.shade900,
          disabledBackgroundColor: disabledBackgroundColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor ?? Colors.transparent),
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator.adaptive()
              : child ??
                  Text(
                    text ?? "",
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
        ),
      ),
    );
  }
}

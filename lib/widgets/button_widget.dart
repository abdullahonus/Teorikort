import 'package:flutter/material.dart';

enum ButtonState { normal, loading }

class ButtonStateValue {
  final ButtonState state;

  ButtonStateValue(this.state);
}

class ButtonController extends ValueNotifier<ButtonStateValue> {
  final ButtonState? state;
  ButtonController({this.state})
      : super(ButtonStateValue(state ?? ButtonState.normal));

  void setLoading() {
    value = ButtonStateValue(ButtonState.loading);
  }

  void setNormal() {
    value = ButtonStateValue(ButtonState.normal);
  }
}

class BasicButton extends StatefulWidget {
  final ButtonStyle? buttonStyle;
  final double height;
  final double? elevation;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonController controller;
  BasicButton(
      {super.key,
      required this.onPressed,
      required this.child,
      this.height = 56,
      this.elevation,
      this.backgroundColor,
      this.borderColor,
      this.borderRadius,
      ButtonController? controller,
      ButtonStyle? buttonStyle})
      : buttonStyle = buttonStyle ??
            ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: borderColor ?? Colors.black),
                  borderRadius: borderRadius ?? BorderRadius.circular(16)),
              backgroundColor: backgroundColor ?? Colors.white,
              elevation: elevation,
            ),
        controller = controller ?? ButtonController();

  @override
  State<BasicButton> createState() => _BasicButtonState();
}

class _BasicButtonState extends State<BasicButton> {
  late bool _loading;
  @override
  void initState() {
    super.initState();
    _loading = widget.controller.value.state == ButtonState.loading;
    widget.controller.addListener(() {
      setState(() {
        _loading = widget.controller.value.state == ButtonState.loading;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: ElevatedButton(
        onPressed: _loading ? null : widget.onPressed,
        style: widget.buttonStyle,
        child: _loading
            ? const CircularProgressIndicator.adaptive()
            : widget.child,
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
}

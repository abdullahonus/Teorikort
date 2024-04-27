import 'package:flutter/material.dart';

class TextFormFieldComponent extends StatefulWidget {
  Color? cursorColor;
  TextEditingController controller;
  TextInputType? textInputType;
  bool? obsecureText;
  BoxBorder? boxBorder;
  InputDecoration? inputDecoration;
  EdgeInsetsGeometry? padding;
  EdgeInsetsGeometry? margin;
  FocusNode? focusNode;
  void Function()? onEditingComplete;
  IconData? prefixIcon;
  Color? focusColor;
  String labelText;
  Widget? suffixIcon;
  double borderRadius;
  Color? fillColor;
  String? Function(String?)? validator;
  Color? unfocusBorderColor;
  bool? readOnly;

  TextFormFieldComponent({
    Key? key,
    this.cursorColor = Colors.black,
    required this.controller,
    this.textInputType,
    this.obsecureText,
    this.boxBorder,
    this.inputDecoration,
    this.padding,
    this.margin,
    this.focusNode,
    this.onEditingComplete,
    this.prefixIcon,
    this.focusColor,
    required this.labelText,
    this.suffixIcon,
    this.borderRadius = 10,
    this.fillColor,
    this.validator,
    this.unfocusBorderColor,
    this.readOnly,
  }) : super(key: key);

  @override
  State<TextFormFieldComponent> createState() => _TextFormFieldComponentState();
}

class _TextFormFieldComponentState extends State<TextFormFieldComponent> {
  bool isObsecureText = false;
  String validateText = '';
  @override
  void initState() {
    widget.obsecureText ?? false ? isObsecureText = true : false;
    super.initState();
  }

  @override
  void dispose() {
    // widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Container(
        margin: widget.margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                border: widget.boxBorder,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: TextFormField(
                readOnly: widget.readOnly ?? false,
                validator: (val) {
                  setState(() {
                    validateText = widget.validator!(val) ?? '';
                  });
                  print(validateText);
                },
                style: const TextStyle(color: Colors.black),
                onEditingComplete: widget.onEditingComplete,
                focusNode: widget.focusNode,
                cursorColor: widget.cursorColor,
                controller: widget.controller,
                keyboardType: widget.textInputType,
                obscureText: isObsecureText,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(color: Colors.grey),
                  labelText: widget.labelText,
                  fillColor: Colors.black,
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: widget.focusColor ?? Colors.black38),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            widget.unfocusBorderColor ?? Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: Colors.grey,
                        )
                      : null,
                  suffixIcon: widget.obsecureText ?? false
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              isObsecureText = !isObsecureText;
                            });
                          },
                          child: Icon(
                            isObsecureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            validateText.isNotEmpty
                ? Container(
                    child: Text(
                      validateText,
                      style: TextStyle(color: Colors.red, fontSize: 15),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}

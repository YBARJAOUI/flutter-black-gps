import 'package:blackgps/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final double width;
  final double height;
  final String placeholder;
  final TextEditingController controller;
  final bool? isPassword;
  final VoidCallback? onPressed;
  final FocusNode? focusNode;

  const CustomTextField({
    Key? key,
    required this.width,
    required this.height,
    required this.placeholder,
    required this.controller,
    this.onPressed,
    this.isPassword,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: TextField(
        focusNode: focusNode,
        onTap: onPressed ?? () {},
        obscureText: this.isPassword ?? false,
        controller: controller,
        textAlign: TextAlign.start,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
              color: CustomColors.greyColor,
              fontWeight: FontWeight.w400,
              fontSize: 14),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: CustomColors.greyColor),
            borderRadius: BorderRadius.circular(6.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: CustomColors.greyColor,
            ),
          ),
        ),
      ),
    );
  }
}

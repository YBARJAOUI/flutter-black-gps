import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color colorBackground;
  final Color textColor;
  final String label;
  final double textSize;
  final double? width, height;
  final VoidCallback? onPressedClick;

  const CustomButton({
    Key? key,
    required this.label,
    required this.colorBackground,
    required this.textColor,
    required this.textSize,
    this.onPressedClick,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: OutlinedButton(
        onPressed: onPressedClick ?? () {},
        style: ButtonStyle(
          fixedSize:
              MaterialStateProperty.all<Size>(Size(width ?? 255, height ?? 48)),
          backgroundColor: MaterialStateProperty.all<Color>(colorBackground),
          foregroundColor:
              MaterialStateProperty.all<Color>(Colors.white), // Texte blanc
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: textSize),
        ),
      ),
    );
  }
}

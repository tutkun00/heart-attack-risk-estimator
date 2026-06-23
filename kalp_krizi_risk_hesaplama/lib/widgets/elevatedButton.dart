import 'package:flutter/material.dart';

class BuildButton extends StatelessWidget {
  final Color color;
  final double width;
  final String text;
  final double height;
  final IconData? icon;
  final Color styleColor;
  final VoidCallback onTop;
  final bool column;
  bool active;
  BuildButton({
    super.key,
    required this.color,
    required this.onTop,
    required this.width,
    required this.text,
    required this.height,
    required this.icon,
    required this.styleColor,
    required this.column,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onTop,
      constraints: BoxConstraints(
        minWidth: width,
        minHeight: height,
        maxHeight: height,
        maxWidth: width,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      fillColor: active ? color : const Color.fromARGB(255, 128, 127, 127),

      child: column
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon != null ? Icon(icon, color: styleColor) : SizedBox(),
                SizedBox(height: 10),
                Text(text, style: TextStyle(color: styleColor)),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon != null ? Icon(icon, color: styleColor) : SizedBox(),
                SizedBox(width: 10),
                Text(text, style: TextStyle(color: styleColor)),
              ],
            ),
    );
  }
}

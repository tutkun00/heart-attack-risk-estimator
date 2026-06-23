import 'package:flutter/material.dart';

class Boxtitle extends StatelessWidget {
  String tt1, tt2;
  Boxtitle({super.key, required this.tt1, required this.tt2});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Spacer(flex: 2),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        Spacer(flex: 1),
        Text(
          tt1,

          style: TextStyle(
            color: const Color.fromARGB(255, 189, 188, 188),
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
        ),
        Spacer(flex: 20),
        Text(
          tt2,

          style: TextStyle(
            color: const Color.fromARGB(255, 189, 188, 188),
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
        ),
        Spacer(flex: 3),
      ],
    );
  }
}

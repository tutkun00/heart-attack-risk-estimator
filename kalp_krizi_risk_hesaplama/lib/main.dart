import 'package:flutter/material.dart';
import 'package:kalp_krizi_risk_hesaplama/pages/input_form.dart';
import 'package:kalp_krizi_risk_hesaplama/pages/result_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kalp Krizi Riski Hersaplama',
      home: InputForm(),
    );
  }
}

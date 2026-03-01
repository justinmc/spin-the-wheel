import 'package:flutter/material.dart';
import 'wheel_page.dart';

void main() {
  runApp(const SpinTheWheelApp());
}

class SpinTheWheelApp extends StatelessWidget {
  const SpinTheWheelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spin the Wheel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WheelPage(),
    );
  }
}

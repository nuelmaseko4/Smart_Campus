// lib/main.dart
import 'package:flutter/material.dart';

import 'views/onboard/Onboard.dart';

void main() {
  runApp(const SmartConnectApp());
}

class SmartConnectApp extends StatelessWidget {
  const SmartConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart_connect', // title of the app
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OnboardScreen(), // Calling our view from the views folder
    );
  }
}

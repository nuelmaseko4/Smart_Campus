// lib/main.dart
import 'package:flutter/material.dart';

import 'views/home_screen.dart';
import 'views/onboarding/onboard.dart';

void main() {
  runApp(const SmartConnectApp());
}

class SmartConnectApp extends StatelessWidget {
  const SmartConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart_connect',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OnboardScreen(),
      routes: {'/home': (context) => HomeScreen()},
    );
  }
}

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:uni_connect/views/login/login_screen.dart';

import 'views/onboarding/onboard_screen.dart';
import 'views/options/option_dart.dart';

void main() {
  runApp(const SmartConnectApp());
}

class SmartConnectApp extends StatelessWidget {
  const SmartConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniConnect',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OnboardScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/options': (context) => const OptionDart(),
      },
    );
  }
}

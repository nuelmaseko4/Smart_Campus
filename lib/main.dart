// lib/main.dart
import 'package:flutter/material.dart';
import 'package:uni_connect/views/lecture/lecture_home_page.dart';
import 'package:uni_connect/views/lecture/lecture_signup_screen.dart';
import 'package:uni_connect/views/login/login_screen.dart';
import 'package:uni_connect/views/signup/student_signup_screen.dart';
import 'package:uni_connect/views/students/student_home_page.dart';

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
        '/options': (context) => const OptionDart(),
        '/login': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments;
          final role = arguments is String ? arguments : 'student';
          return LoginScreen(role: role);
        },
        '/student-signup': (context) => const StudentSignUpScreen(),
        '/lecturer-signup': (context) => const LectureSignUpScreen(),
        '/student': (context) => const StudentHomePage(),
        '/lecturer': (context) => const LectureHomePage(),
      },
    );
  }
}

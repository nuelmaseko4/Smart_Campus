// lib/main.dart
import 'package:flutter/material.dart';
import 'package:uni_connect/views/login/login_screen.dart';
import 'package:uni_connect/views/lecture/lecture_signup_screen.dart';
import 'package:uni_connect/views/options/option_dart.dart';
import 'package:uni_connect/views/signup/student_signup_screen.dart';
import 'package:uni_connect/widgets/student_nav_bar.dart';

import 'views/onboarding/onboard_screen.dart';

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
        '/login': (context) {
          final role = ModalRoute.of(context)?.settings.arguments;
          return LoginScreen(role: role is String ? role : 'student');
        },
        '/lecturer-signup': (context) => const LectureSignUpScreen(),
        '/student-signup': (context) => const StudentSignUpScreen(),
        '/options': (context) => const OptionDart(),
        '/student': (context) => const StudentNavBar(),
      },
    );
  }
}

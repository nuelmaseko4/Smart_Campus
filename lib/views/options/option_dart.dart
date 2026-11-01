import 'package:flutter/material.dart';
import 'package:uni_connect/widgets/app_button.dart';

class OptionDart extends StatelessWidget {
  const OptionDart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade800,
              Colors.orange.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Choose your role',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    text: 'Lecturer',
                    icon: Icons.school_outlined,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/lecturer-signup');
                    },
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Student',
                    icon: Icons.people_outline,
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                        '/login',
                        arguments: 'student',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

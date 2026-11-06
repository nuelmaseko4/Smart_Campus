import 'package:flutter/material.dart';
import 'package:uni_connect/widgets/animated_gradient_background.dart';
import 'package:uni_connect/widgets/app_button.dart';
import 'package:uni_connect/widgets/press_scale.dart';
import 'package:uni_connect/widgets/reveal.dart';
import 'package:uni_connect/widgets/role_badge.dart';

class OptionDart extends StatefulWidget {
  const OptionDart({super.key});

  @override
  State<OptionDart> createState() => _OptionDartState();
}

class _OptionDartState extends State<OptionDart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RoleBadge(),
                  const SizedBox(height: 28),
                  Reveal(
                    controller: _entrance,
                    start: 0.20,
                    end: 0.55,
                    child: const Text(
                      'Choose your role',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Reveal(
                    controller: _entrance,
                    start: 0.30,
                    end: 0.65,
                    child: const Text(
                      'Select how you want to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Reveal(
                    controller: _entrance,
                    start: 0.45,
                    end: 0.80,
                    child: PressScale(
                      child: AppButton(
                        text: 'Lecturer',
                        icon: Icons.school_outlined,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/lecturer-signup');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Reveal(
                    controller: _entrance,
                    start: 0.60,
                    end: 1.0,
                    child: PressScale(
                      child: AppButton(
                        text: 'Student',
                        icon: Icons.people_outline,
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(
                            '/login',
                            arguments: 'student',
                          );
                        },
                      ),
                    ),
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
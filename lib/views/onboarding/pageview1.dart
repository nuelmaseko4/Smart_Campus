import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PageView1 extends StatelessWidget {
  const PageView1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple[250],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assests/animations/lottie/onboarding/Man.json',
              width: 280,
              height: 280,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to UniConnect',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              ' an App to connect students with\n their university resources and community.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

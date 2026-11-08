import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PageView4 extends StatelessWidget {
  const PageView4({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple[250],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assests/animations/lottie/onboarding/walking.json',
              width: 280,
              height: 280,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Easily track your class attendance and performance',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Connect with your university seamlessly',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

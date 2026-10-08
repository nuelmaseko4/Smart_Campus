import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PageView2 extends StatelessWidget {
  const PageView2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple[250],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assests/animations/onboarding/Office.json',
              width: 280,
              height: 280,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'A secure way of communication',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect with your university seamlessly',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PageView1 extends StatelessWidget {
  const PageView1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.brown,
      child: Center(
        child: Lottie.asset(
          'assests/animations/onboarding/man.json',
          width: 280,
          height: 280,
          fit: BoxFit.contain,
          repeat: true,
        ),
      ),
    );
  }
}

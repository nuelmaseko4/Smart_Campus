import 'package:flutter/material.dart';

import 'onboard_controls.dart';

import '../onboarding/pageview1.dart';
import '../onboarding/pageview2.dart';
import '../onboarding/pageview3.dart';
import '../onboarding/pageview4.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0; // NEW
  final int _totalPages = 4; // NEW

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void finishOnboarding(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _nextPage() {
    if (_currentPage == _totalPages - 1) {
      finishOnboarding(context);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i), // NEW
            children: [
              PageView1(),
              PageView2(),
              PageView3(),
              PageView4(),
            ], // NEW
          ),
          // NEW: replaces the old Container + SmoothPageIndicator
          Positioned(
            left: 16,
            right: 16,
            bottom: 40,
            child: OnboardControls(
              controller: _pageController,
              currentPage: _currentPage,
              totalPages: _totalPages,
              onSkip: () => finishOnboarding(context),
              onNext: _nextPage,
            ),
          ),
        ],
      ),
    );
  }
}

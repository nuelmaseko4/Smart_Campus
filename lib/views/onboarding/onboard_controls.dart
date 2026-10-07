import "package:flutter/material.dart";
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardControls extends StatelessWidget {
  final PageController controller;
  final int currentPage;
  final int totalPages;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const OnboardControls({
    super.key,
    required this.controller,
    required this.currentPage,
    required this.totalPages,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == totalPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Opacity(
          opacity: isLastPage ? 0 : 1,
          child: TextButton(
            onPressed: isLastPage ? null : onSkip,
            child: const Text('Skip'),
          ),
        ),
        SmoothPageIndicator(
          controller: controller,
          count: totalPages,
          effect: const ExpandingDotsEffect(),
        ),
        TextButton(
          onPressed: onNext,
          child: Text(isLastPage ? 'Done' : 'Next'),
        ),
      ],
    );
  }
}

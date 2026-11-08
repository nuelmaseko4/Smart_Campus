import "package:flutter/material.dart";
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardControls extends StatelessWidget {
  final PageController controller; // the dots can move
  final int currentPage; // which page
  final int totalPages; // knows ther are 4 pages in total
  final VoidCallback onSkip; // the funtions to call when the user clicks the buttons
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
    final orange = Colors.orange.shade900;

    return Row( // skip button
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Opacity(
          opacity: isLastPage ? 0 : 1,
          child: TextButton(
            onPressed: isLastPage ? null : onSkip,
            style: TextButton.styleFrom(foregroundColor: orange),
            child: const Text('Skip'),
          ),
        ),
        SmoothPageIndicator(
          controller: controller,
          count: totalPages,
          effect: ExpandingDotsEffect(
            activeDotColor: orange,
            dotColor: orange.withValues(alpha: 0.35),
          ),
        ),
        TextButton(
          onPressed: onNext,
          style: TextButton.styleFrom(foregroundColor: orange),
          child: Text(isLastPage ? 'Done' : 'Next'),
        ),
      ],
    );
  }
}

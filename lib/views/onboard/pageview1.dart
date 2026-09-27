// lib/views/pageview1.dart
import 'package:flutter/material.dart';

class PageViewScreen extends StatefulWidget {
  const PageViewScreen({super.key});

  @override
  State<PageViewScreen> createState() => _PageViewScreenState();
}

class _PageViewScreenState extends State<PageViewScreen> {
  // 1. Controller to track and control page sliding
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose(); // Always clean up controllers to save memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PageView Walkthrough'),
        backgroundColor: Colors.blue,
      ),
      // 2. PageView allows users to swipe horizontally (or vertically) between screens
      body: PageView(
        controller: _pageController,
        children: [
          // Page 1 Content
          Container(
            color: Colors.blue[50],
            child: const Center(
              child: Text(
                'Welcome to Page 1\nSwipe Left ➔',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Page 2 Content
          Container(
            color: Colors.green[50],
            child: const Center(
              child: Text(
                'Welcome to Page 2\nKeep Swiping!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Page 3 Content
          Container(
            color: Colors.orange[50],
            child: const Center(
              child: Text(
                'Welcome to Page 3\nYou made it!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

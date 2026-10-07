import 'package:flutter/material.dart';

class PageView3 extends StatelessWidget {
  const PageView3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
      child: const Center(
        child: Text(
          'Page 3',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}

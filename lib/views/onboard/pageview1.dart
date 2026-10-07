import 'package:flutter/material.dart';

class PageView1 extends StatelessWidget {
  const PageView1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: const Center(
        child: Text(
          'Page 1',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}

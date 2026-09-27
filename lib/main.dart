// lib/main.dart
import 'package:flutter/material.dart';

import 'views/onboard/pageview1.dart'; // Import your custom view

void main() {
  runApp(const DevHubApp());
}

class DevHubApp extends StatelessWidget {
  const DevHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DevHub App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PageViewScreen(), // Calling our view from the views folder
    );
  }
}

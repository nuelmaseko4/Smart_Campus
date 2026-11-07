import 'package:flutter/material.dart';
import 'package:uni_connect/widgets/app_navigation_bar.dart';

class LectureHomePage extends StatefulWidget {
  const LectureHomePage({super.key});

  @override
  State<LectureHomePage> createState() => _LectureHomePageState();
}

class _LectureHomePageState extends State<LectureHomePage> {
  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.class_outlined), label: 'Classes'),
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
  ];

  static const _pages = [
    _LecturePortalTab(
      title: 'Home',
      message: 'Your teaching overview will appear here.',
      icon: Icons.dashboard_outlined,
    ),
    _LecturePortalTab(
      title: 'Classes',
      message: 'Your classes and timetable will appear here.',
      icon: Icons.class_outlined,
    ),
    _LecturePortalTab(
      title: 'Profile',
      message: 'Your lecturer profile will appear here.',
      icon: Icons.person_outline,
    ),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Portal'),
        backgroundColor: Colors.orange.shade900,
        foregroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: AppNavigationBar(
        destinations: _destinations,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

class _LecturePortalTab extends StatelessWidget {
  const _LecturePortalTab({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.orange.shade900),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

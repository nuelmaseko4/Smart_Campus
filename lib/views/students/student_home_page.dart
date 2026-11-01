import 'package:flutter/material.dart';
import 'package:uni_connect/widgets/app_navigation_bar.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.event), label: 'Activity'),
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
    NavigationDestination(icon: Icon(Icons.history), label: 'History'),
  ];

  static const _pages = [
    _StudentPortalTab(
      title: 'Activity',
      message: 'Your campus activity will appear here.',
      icon: Icons.event,
    ),
    _StudentPortalTab(
      title: 'Profile',
      message: 'Your student profile will appear here.',
      icon: Icons.person_outline,
    ),
    _StudentPortalTab(
      title: 'History',
      message: 'Your attendance and activity history will appear here.',
      icon: Icons.history,
    ),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
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

class _StudentPortalTab extends StatelessWidget {
  const _StudentPortalTab({
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

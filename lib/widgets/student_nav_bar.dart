import 'package:flutter/material.dart';

class StudentNavBar extends StatefulWidget {
  const StudentNavBar({super.key});

  @override
  State<StudentNavBar> createState() => _StudentNavBarState();
}

class _StudentNavBarState extends State<StudentNavBar> {
  int _selectedIndex = 0;

  static const _pages = [
    ('Activity', Icons.event),
    ('Profile', Icons.person_outline),
    ('History', Icons.history),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedPage = _pages[_selectedIndex];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        backgroundColor: Colors.orange.shade900,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selectedPage.$2, size: 64, color: Colors.orange.shade900),
            const SizedBox(height: 12),
            Text(
              selectedPage.$1,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Activity'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}

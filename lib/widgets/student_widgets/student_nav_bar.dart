import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class StudentNavBar extends StatefulWidget {
  const StudentNavBar({super.key});

  @override
  State<StudentNavBar> createState() => _StudentNavBarState();
}

class _StudentNavBarState extends State<StudentNavBar> {
  int _selectedIndex = 0;

  static const _pages = [
    _StudentTab(title: 'Home', icon: Icons.home_outlined),
    _StudentTab(title: 'profile', icon: Icons.search),
    _StudentTab(title: 'Profile', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Student Portal'),
        backgroundColor: Colors.orange.shade900,
        foregroundColor: Colors.white,
      ),
      body: Center(child: _pages[_selectedIndex]),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: GNav(
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            color: Colors.grey.shade700,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.orange.shade900,
            gap: 8,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            tabs: const [
              GButton(icon: Icons.event, text: 'Activity'),
              GButton(icon: Icons.history, text: 'Profile'),
              GButton(icon: Icons.history, text: 'History'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentTab extends StatelessWidget {
  const _StudentTab({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: Colors.orange.shade900),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

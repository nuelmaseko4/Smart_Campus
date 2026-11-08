import 'package:flutter/material.dart';
import 'package:uni_connect/services/login_service.dart';
import 'package:uni_connect/services/student_activities_service.dart';
import 'package:uni_connect/services/student_profile_service.dart';
import 'package:uni_connect/services/timetable_service.dart';
import 'package:uni_connect/views/students/student_activities_page.dart';
import 'package:uni_connect/views/students/student_profile_page.dart';
import 'package:uni_connect/views/students/timetable_page.dart';
import 'package:uni_connect/widgets/app_navigation_bar.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({
    super.key,
    this.activitiesService = const StudentActivitiesService(),
    this.profileService = const StudentProfileService(),
    this.timetableService = const TimetableService(),
    this.loginService = const LoginService(),
  });

  final StudentActivitiesService activitiesService;
  final StudentProfileService profileService;
  final TimetableService timetableService;
  final LoginService loginService;

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.event), label: 'Activity'),
    NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Timetable'),
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
    NavigationDestination(icon: Icon(Icons.history), label: 'History'),
  ];

  int _selectedIndex = 0;

  Widget _selectedPage() {
    switch (_selectedIndex) {
      case 0:
        return StudentActivitiesPage(
          key: const ValueKey('student-activity'),
          service: widget.activitiesService,
          showRoomAvailability: true,
        );
      case 1:
        return TimetablePage(
          key: const ValueKey('student-timetable'),
          service: widget.timetableService,
        );
      case 2:
        return StudentProfilePage(
          key: const ValueKey('student-profile'),
          service: widget.profileService,
          onLogout: _logout,
        );
      case 3:
        return StudentActivitiesPage(
          key: const ValueKey('student-history'),
          service: widget.activitiesService,
          showRoomAvailability: false,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to access your portal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey('confirm-logout'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (shouldLogout != true || !mounted) return;

    try {
      await widget.loginService.logout();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not log out: $error')));
      return;
    }

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/login', (route) => false, arguments: 'student');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
        backgroundColor: Colors.orange.shade900,
        foregroundColor: Colors.white,
      ),
      body: _selectedPage(),
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

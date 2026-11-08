import 'package:flutter/material.dart';
import 'package:uni_connect/services/lecturer_profile_service.dart';
import 'package:uni_connect/services/login_service.dart';
import 'package:uni_connect/services/timetable_service.dart';
import 'package:uni_connect/widgets/app_navigation_bar.dart';

class LectureHomePage extends StatefulWidget {
  const LectureHomePage({
    super.key,
    this.profileService = const LecturerProfileService(),
    this.timetableService = const TimetableService(),
    this.loginService = const LoginService(),
  });

  final LecturerProfileService profileService;
  final TimetableService timetableService;
  final LoginService loginService;

  @override
  State<LectureHomePage> createState() => _LectureHomePageState();
}

class _LectureHomePageState extends State<LectureHomePage> {
  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.class_outlined), label: 'Classes'),
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
  ];

  int _selectedIndex = 0;
  late Future<LecturerProfile> _profile;
  late Future<TimetableSchedule> _timetable;

  @override
  void initState() {
    super.initState();
    _profile = widget.profileService.fetchProfile();
    _timetable = widget.timetableService.fetchSchedule();
  }

  void _reloadProfile() {
    setState(() => _profile = widget.profileService.fetchProfile());
  }

  void _reloadTimetable() {
    setState(() => _timetable = widget.timetableService.fetchSchedule());
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey('confirm-lecturer-logout'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (shouldLogout != true || !mounted) return;
    await widget.loginService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/options', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Dashboard'),
        backgroundColor: Colors.orange.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            key: const ValueKey('lecturer-logout'),
            tooltip: 'Log out',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<LecturerProfile>(
        future: _profile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      size: 52,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Could not load your lecturer dashboard.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _reloadProfile,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            return const Center(
              child: Text('Lecturer profile is unavailable.'),
            );
          }
          return _selectedPage(profile);
        },
      ),
      bottomNavigationBar: AppNavigationBar(
        destinations: _destinations,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  Widget _selectedPage(LecturerProfile profile) {
    switch (_selectedIndex) {
      case 1:
        return _classesPage(profile);
      case 2:
        return _profilePage(profile);
      default:
        return _homePage(profile);
    }
  }

  Widget _homePage(LecturerProfile profile) {
    final upcomingClasses = profile.classes
        .where((entry) => entry.endTime.isAfter(DateTime.now()))
        .take(3)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        Text(
          'Welcome back, ${profile.firstName.isEmpty ? profile.name : profile.firstName}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text('Here is your teaching overview.'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                icon: Icons.school_outlined,
                label: 'Courses',
                value: '${profile.courses.length}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OverviewCard(
                icon: Icons.event_note_outlined,
                label: 'Scheduled classes',
                value: '${profile.classes.length}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _SectionHeading(
          title: 'My courses',
          actionLabel: 'See all',
          onAction: () => setState(() => _selectedIndex = 1),
        ),
        const SizedBox(height: 10),
        if (profile.courses.isEmpty)
          const _EmptySection(message: 'No courses are linked to your account.')
        else
          ...profile.courses.map((course) => _CourseCard(course: course)),
        const SizedBox(height: 24),
        const _SectionHeading(title: 'Upcoming classes'),
        const SizedBox(height: 10),
        if (upcomingClasses.isEmpty)
          const _EmptySection(message: 'No upcoming classes are scheduled.')
        else
          ...upcomingClasses.map((entry) => _ClassCard(entry: entry)),
      ],
    );
  }

  Widget _classesPage(LecturerProfile profile) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        const Text(
          'Classes and timetable',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        FutureBuilder<TimetableSchedule>(
          future: _timetable,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return _EmptySection(
                message: 'Could not load timetable: ${snapshot.error}',
                onRetry: _reloadTimetable,
              );
            }
            final entries = snapshot.data?.entries ?? const <TimetableEntry>[];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${entries.length} scheduled classes'),
                const SizedBox(height: 16),
                if (entries.isEmpty)
                  const _EmptySection(
                    message: 'Your timetable is empty for now.',
                  )
                else
                  ...entries.map((entry) => _ScheduledClassCard(entry: entry)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _profilePage(LecturerProfile profile) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: Colors.orange.shade100,
          child: Icon(
            Icons.person_outline,
            size: 42,
            color: Colors.orange.shade900,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          profile.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _ProfileDetail(label: 'Email', value: profile.email ?? 'Not provided'),
        _ProfileDetail(
          label: 'Department',
          value: profile.department ?? 'Not provided',
        ),
        const SizedBox(height: 16),
        const _SectionHeading(title: 'Courses you teach'),
        const SizedBox(height: 10),
        if (profile.courses.isEmpty)
          const _EmptySection(message: 'No courses are linked to your account.')
        else
          ...profile.courses.map((course) => _CourseCard(course: course)),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.orange.shade900),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final LecturerCourse course;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(Icons.school_outlined, color: Colors.orange.shade900),
        ),
        title: Text(course.name),
        subtitle: Text(course.code),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.entry});

  final LecturerClass entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(Icons.event_outlined, color: Colors.orange.shade900),
        ),
        title: Text(entry.unitName),
        subtitle: Text(
          '${entry.courseCode} · ${entry.courseName}\n'
          '${_formatDate(entry.startTime)} · ${_formatTime(entry.startTime)}'
          ' - ${_formatTime(entry.endTime)}\n'
          '${entry.building} · ${entry.room}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _ScheduledClassCard extends StatelessWidget {
  const _ScheduledClassCard({required this.entry});

  final TimetableEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(Icons.event_outlined, color: Colors.orange.shade900),
        ),
        title: Text(entry.unitName),
        subtitle: Text(
          '${entry.courseCode} · ${entry.courseName}\n'
          '${_formatDate(entry.startTime)} · ${_formatTime(entry.startTime)}'
          ' - ${_formatTime(entry.endTime)}\n'
          '${entry.building} · ${entry.room}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label, style: TextStyle(color: Colors.grey.shade700)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${weekdays[value.weekday - 1]}, ${value.day}/${value.month}';
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

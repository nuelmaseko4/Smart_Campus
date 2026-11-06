import 'package:flutter/material.dart';
import 'package:uni_connect/services/login_service.dart';
import 'package:uni_connect/services/student_activities_service.dart';
import 'package:uni_connect/services/student_profile_service.dart';
import 'package:uni_connect/widgets/app_navigation_bar.dart';
import 'package:uni_connect/views/students/student_profile_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({
    super.key,
    this.activitiesService = const StudentActivitiesService(),
    this.profileService = const StudentProfileService(),
    this.loginService = const LoginService(),
  });

  final StudentActivitiesService activitiesService;
  final StudentProfileService profileService;
  final LoginService loginService;

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.event), label: 'Activity'),
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
        return StudentProfilePage(
          key: const ValueKey('student-profile'),
          service: widget.profileService,
          onLogout: _logout,
        );
      default:
        return StudentActivitiesPage(
          key: const ValueKey('student-history'),
          service: widget.activitiesService,
          showRoomAvailability: false,
        );
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
        title: const Text('Student Portal'),
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

class StudentActivitiesPage extends StatefulWidget {
  const StudentActivitiesPage({
    super.key,
    required this.service,
    required this.showRoomAvailability,
  });

  final StudentActivitiesService service;
  final bool showRoomAvailability;

  @override
  State<StudentActivitiesPage> createState() => _StudentActivitiesPageState();
}

class _StudentActivitiesPageState extends State<StudentActivitiesPage> {
  late DateTime _startTime;
  late DateTime _endTime;
  List<StudentAttendance> _attendance = [];
  List<StudentGateEntry> _gateEntries = [];
  List<AvailableRoom> _availableRooms = [];
  bool _isLoadingHistory = true;
  bool _isSearchingRooms = false;
  bool _hasSearchedRooms = false;
  String? _historyError;
  String? _roomError;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _endTime = _startTime.add(const Duration(hours: 1));
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    try {
      final attendance = await widget.service.fetchAttendance();
      final gateEntries = await widget.service.fetchGateEntries();
      if (!mounted) return;
      setState(() {
        _attendance = attendance;
        _gateEntries = gateEntries;
        _isLoadingHistory = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _historyError = error.toString().replaceFirst('Exception: ', '');
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _searchRooms() async {
    setState(() {
      _isSearchingRooms = true;
      _hasSearchedRooms = false;
      _roomError = null;
      _availableRooms = [];
    });

    try {
      final rooms = await widget.service.findAvailableRooms(
        startTime: _startTime,
        endTime: _endTime,
      );
      if (!mounted) return;
      setState(() {
        _availableRooms = rooms;
        _isSearchingRooms = false;
        _hasSearchedRooms = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _roomError = error.toString().replaceFirst('Exception: ', '');
        _isSearchingRooms = false;
        _hasSearchedRooms = true;
      });
    }
  }

  Future<void> _selectTime({required bool selectingStart}) async {
    final selectedDateTime = selectingStart ? _startTime : _endTime;
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );
    if (time == null || !mounted) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (selectingStart) {
        _startTime = selected;
        if (_endTime.isBefore(selected)) {
          _endTime = selected.add(const Duration(hours: 1));
        }
      } else {
        _endTime = selected;
      }
      _hasSearchedRooms = false;
      _availableRooms = [];
      _roomError = null;
    });
  }

  String _formatDateTime(DateTime value) {
    final date = MaterialLocalizations.of(context).formatMediumDate(value);
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(value));
    return '$date, $time';
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.orange.shade900;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          widget.showRoomAvailability
              ? 'Student activities'
              : 'Activity history',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        _ActivityCard(
          icon: Icons.credit_card,
          title: 'Check attantance',
          message: 'Tap your campus card at the classroom reader. Your attendance will appear below.',
          color: themeColor,
        ),
        const SizedBox(height: 12),
        _ActivityCard(
          icon: Icons.door_front_door_outlined,
          title: 'Campus gate entry',
          message: 'Tap your campus card at the entrance reader to record your entry.',
          color: themeColor,
        ),
        if (widget.showRoomAvailability) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room availability',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Choose the time you want to use a campus room.'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const ValueKey('room-start-time'),
                    onPressed: () => _selectTime(selectingStart: true),
                    icon: const Icon(Icons.schedule),
                    label: Text('From: ${_formatDateTime(_startTime)}'),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('room-end-time'),
                    onPressed: () => _selectTime(selectingStart: false),
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text('Until: ${_formatDateTime(_endTime)}'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    key: const ValueKey('room-availability-search'),
                    onPressed: _isSearchingRooms ? null : _searchRooms,
                    icon: const Icon(Icons.search),
                    label: const Text('Check available rooms'),
                  ),
                  if (_isSearchingRooms)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(),
                    ),
                  if (_roomError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _roomError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  if (_hasSearchedRooms &&
                      !_isSearchingRooms &&
                      _roomError == null &&
                      _availableRooms.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text('No available rooms for the selected time.'),
                    ),
                  ..._availableRooms.map(
                    (room) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.meeting_room_outlined),
                      title: Text(room.name),
                      subtitle: Text(
                        '${room.building} · Capacity ${room.capacity}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent scans',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'Refresh activity',
              onPressed: _isLoadingHistory ? null : _loadHistory,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        if (_isLoadingHistory)
          const Center(child: CircularProgressIndicator())
        else if (_historyError != null)
          Text(
            _historyError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          )
        else ...[
          if (_attendance.isEmpty && _gateEntries.isEmpty)
            const Text('No attendance or gate scans recorded yet.'),
          ..._attendance
              .take(3)
              .map(
                (record) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.fact_check_outlined),
                  title: Text(record.unitName),
                  subtitle: Text(
                    '${record.courseName} · ${_formatDateTime(record.startTime)}',
                  ),
                  trailing: Text(record.status),
                ),
              ),
          ..._gateEntries
              .take(3)
              .map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.door_front_door_outlined),
                  title: Text(entry.accessPoint),
                  subtitle: Text(_formatDateTime(entry.scannedAt)),
                  trailing: const Text('Entry'),
                ),
              ),
        ],
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title),
        subtitle: Text(message),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_connect/models/scan_event.dart';
import 'package:uni_connect/services/student_activities_service.dart';
import 'package:uni_connect/views/students/mock_scans.dart';
import 'package:uni_connect/widgets/scan_status_card.dart';
import 'package:uni_connect/widgets/scan_summary_box.dart';
import 'package:uni_connect/widgets/scan_timeline.dart';
import 'package:uni_connect/widgets/simulate_buttons.dart';

class StudentActivitiesPage extends StatefulWidget {
  const StudentActivitiesPage({
    super.key,
    required this.service, // not used yet, kept so StudentHomePage doesn't change
    required this.showRoomAvailability,
  });

  final StudentActivitiesService service;
  final bool showRoomAvailability;

  @override
  State<StudentActivitiesPage> createState() => _StudentActivitiesPageState();
}

class _StudentActivitiesPageState extends State<StudentActivitiesPage> {
  late List<ScanEvent> _events;
  late DateTime _availabilityStart;
  late DateTime _availabilityEnd;
  List<AvailableRoom>? _availableRooms;
  Object? _roomSearchError;
  bool _searchingRooms = false;
  ScanEvent? _newScan;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _events = buildMockScans();
    final now = DateTime.now();
    _availabilityStart = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    _availabilityEnd = _availabilityStart.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  // _events is kept newest first, so the first match is the latest scan.
  ScanEvent? _latest(ScanType type) {
    for (final event in _events) {
      if (event.type == type) return event;
    }
    return null;
  }

  void _simulateScan(ScanType type) {
    final isGate = type == ScanType.gate;
    final scan = ScanEvent(
      id: 'sim-${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      title: isGate ? 'Main Gate' : 'Data Structures',
      subtitle: isGate ? 'Campus gate' : 'BSc Computer Science',
      time: DateTime.now(),
      status: isGate ? null : 'Present',
    );

    HapticFeedback.mediumImpact();
    setState(() {
      _events = [scan, ..._events];
      _newScan = scan;
    });

    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 8), _clearNewScan);
  }

  void _clearNewScan() {
    _bannerTimer?.cancel();
    if (mounted) setState(() => _newScan = null);
  }

  Future<void> _searchAvailableRooms() async {
    setState(() {
      _searchingRooms = true;
      _roomSearchError = null;
    });
    try {
      final rooms = await widget.service.findAvailableRooms(
        startTime: _availabilityStart,
        endTime: _availabilityEnd,
      );
      if (!mounted) return;
      setState(() {
        _availableRooms = rooms;
        _searchingRooms = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _roomSearchError = error;
        _searchingRooms = false;
      });
    }
  }

  Future<void> _selectAvailabilityDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _availabilityStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;

    setState(() {
      _availabilityStart = DateTime(
        date.year,
        date.month,
        date.day,
        _availabilityStart.hour,
        _availabilityStart.minute,
      );
      _availabilityEnd = DateTime(
        date.year,
        date.month,
        date.day,
        _availabilityEnd.hour,
        _availabilityEnd.minute,
      );
      if (!_availabilityEnd.isAfter(_availabilityStart)) {
        _availabilityEnd = _availabilityStart.add(const Duration(hours: 1));
      }
      _availableRooms = null;
    });
  }

  Future<void> _selectAvailabilityTime({required bool selectStart}) async {
    final current = selectStart ? _availabilityStart : _availabilityEnd;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;

    final selected = DateTime(
      _availabilityStart.year,
      _availabilityStart.month,
      _availabilityStart.day,
      time.hour,
      time.minute,
    );
    if (!selectStart && !selected.isAfter(_availabilityStart)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }

    setState(() {
      if (selectStart) {
        _availabilityStart = selected;
        if (!_availabilityEnd.isAfter(selected)) {
          _availabilityEnd = selected.add(const Duration(hours: 1));
        }
      } else {
        _availabilityEnd = selected;
      }
      _availableRooms = null;
    });
  }

  Widget _roomAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room availability',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              key: const ValueKey('room-availability-date'),
              onPressed: _selectAvailabilityDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(_formatDate(_availabilityStart)),
            ),
            OutlinedButton.icon(
              key: const ValueKey('room-availability-start-time'),
              onPressed: () => _selectAvailabilityTime(selectStart: true),
              icon: const Icon(Icons.schedule),
              label: Text(_formatTime(_availabilityStart)),
            ),
            OutlinedButton.icon(
              key: const ValueKey('room-availability-end-time'),
              onPressed: () => _selectAvailabilityTime(selectStart: false),
              icon: const Icon(Icons.schedule_outlined),
              label: Text(_formatTime(_availabilityEnd)),
            ),
            FilledButton.icon(
              key: const ValueKey('room-availability-search'),
              onPressed: _searchingRooms ? null : _searchAvailableRooms,
              icon: const Icon(Icons.search),
              label: const Text('Find rooms'),
            ),
          ],
        ),
        if (_searchingRooms)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_roomSearchError != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Could not check room availability: $_roomSearchError',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (_availableRooms != null) ...[
          const SizedBox(height: 8),
          Text(
            '${_availableRooms!.length} available from '
            '${_formatTime(_availabilityStart)} to '
            '${_formatTime(_availabilityEnd)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (_availableRooms!.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No rooms are available for this time.'),
            )
          else
            ..._availableRooms!.map(
              (room) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.meeting_room_outlined),
                title: Text(room.name),
                subtitle: Text('${room.building} · Capacity ${room.capacity}'),
              ),
            ),
        ],
      ],
    );
  }

  String _formatDate(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          widget.showRoomAvailability
              ? 'Student activities'
              : 'Activity history',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        if (widget.showRoomAvailability) ...[
          _roomAvailabilitySection(),
          const SizedBox(height: 24),
          ScanStatusCard(newScan: _newScan, onDismiss: _clearNewScan),
          if (kDebugMode) ...[
            const SizedBox(height: 12),
            SimulateButtons(onSimulate: _simulateScan),
          ],
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ScanSummaryBox(
                    type: ScanType.gate,
                    latest: _latest(ScanType.gate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ScanSummaryBox(
                    type: ScanType.attendance,
                    latest: _latest(ScanType.attendance),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        ScanTimeline(
          events: _events,
          limit: widget.showRoomAvailability ? 5 : null,
        ),
      ],
    );
  }
}

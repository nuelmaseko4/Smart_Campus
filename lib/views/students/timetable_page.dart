import 'package:flutter/material.dart';
import 'package:uni_connect/services/timetable_service.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key, this.service = const TimetableService()});

  final TimetableService service;

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  int? _selectedYear;
  int _selectedSemester = 1;
  late Future<TimetableSchedule> _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = widget.service.fetchSchedule(semester: _selectedSemester);
  }

  void _selectYear(int year) {
    setState(() {
      _selectedYear = year;
      _schedule = widget.service.fetchSchedule(
        year: year,
        semester: _selectedSemester,
      );
    });
  }

  void _selectSemester(int semester) {
    setState(() {
      _selectedSemester = semester;
      _schedule = widget.service.fetchSchedule(
        year: _selectedYear,
        semester: semester,
      );
    });
  }

  void _reload() {
    setState(() {
      _schedule = widget.service.fetchSchedule(
        year: _selectedYear,
        semester: _selectedSemester,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Timetable',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FutureBuilder<TimetableSchedule>(
                      future: _schedule,
                      builder: (context, snapshot) => DropdownButton<int>(
                        key: const ValueKey('timetable-year'),
                        value: _selectedYear ?? snapshot.data?.year ?? 1,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.orange,
                        ),
                        onChanged: (year) {
                          if (year != null) _selectYear(year);
                        },
                        items: [1, 2, 3, 4]
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text('Year $year'),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      key: const ValueKey('timetable-semester'),
                      value: _selectedSemester,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.orange,
                      ),
                      onChanged: (semester) {
                        if (semester != null) _selectSemester(semester);
                      },
                      items: [1, 2]
                          .map(
                            (semester) => DropdownMenuItem(
                              value: semester,
                              child: Text('Semester $semester'),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<TimetableSchedule>(
              future: _schedule,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Could not load timetable. ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _reload,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final schedule = snapshot.data;
                if (schedule == null || schedule.entries.isEmpty) {
                  return const Center(child: Text('No classes scheduled.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: schedule.entries.length,
                  itemBuilder: (context, index) =>
                      _buildTimetableCard(schedule.entries[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableCard(TimetableEntry item) {
    final time =
        '${_formatTime(item.startTime)} - ${_formatTime(item.endTime)}';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left side: Day and Time
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    item.dayOfWeek,
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right side: Unit and Room
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.unitName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${item.building} · ${item.room}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

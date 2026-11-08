import 'package:uni_connect/models/scan_event.dart';

/// Sample data for designing the interface. Delete once the backend is connected.
List<ScanEvent> buildMockScans() {
  final now = DateTime.now();
  return [
    ScanEvent(
      id: 'mock-1',
      type: ScanType.attendance,
      title: 'Data Structures',
      subtitle: 'BSc Computer Science',
      time: now.subtract(const Duration(hours: 2)),
      status: 'Present',
    ),
    ScanEvent(
      id: 'mock-2',
      type: ScanType.gate,
      title: 'Main Gate',
      subtitle: 'Campus gate',
      time: now.subtract(const Duration(hours: 3, minutes: 10)),
    ),
    ScanEvent(
      id: 'mock-3',
      type: ScanType.attendance,
      title: 'Database Systems',
      subtitle: 'BSc Computer Science',
      time: now.subtract(const Duration(days: 1, hours: 4)),
      status: 'Late',
    ),
    ScanEvent(
      id: 'mock-4',
      type: ScanType.gate,
      title: 'Main Gate',
      subtitle: 'Campus gate',
      time: now.subtract(const Duration(days: 1, hours: 6)),
    ),
    ScanEvent(
      id: 'mock-5',
      type: ScanType.attendance,
      title: 'Networks',
      subtitle: 'BSc Computer Science',
      time: now.subtract(const Duration(days: 2, hours: 3)),
      status: 'Absent',
    ),
  ];
}
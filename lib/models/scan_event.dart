enum ScanType { gate, attendance }

class ScanEvent {
  const ScanEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    this.status,
  });

  final String id;
  final ScanType type;
  final String title;
  final String subtitle;
  final DateTime time;
  final String? status;
}
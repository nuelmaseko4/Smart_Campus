import 'package:flutter/material.dart';
import 'package:uni_connect/models/scan_event.dart';

class ScanStatusChip extends StatelessWidget {
  const ScanStatusChip({super.key, required this.event});

  final ScanEvent event;

  @override
  Widget build(BuildContext context) {
    final isGate = event.type == ScanType.gate;
    final status = isGate ? 'Recorded' : event.status ?? 'Unknown';
    final color = switch (status.toLowerCase()) {
      'present' || 'recorded' => Colors.green.shade700,
      'late' => Colors.orange.shade800,
      'absent' => Colors.red.shade700,
      _ => Colors.grey.shade700,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

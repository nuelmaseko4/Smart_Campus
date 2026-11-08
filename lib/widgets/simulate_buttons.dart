import 'package:flutter/material.dart';
import 'package:uni_connect/models/scan_event.dart';

/// Debug-only buttons for previewing the scan animation.
class SimulateButtons extends StatelessWidget {
  const SimulateButtons({super.key, required this.onSimulate});

  final void Function(ScanType type) onSimulate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => onSimulate(ScanType.gate),
            icon: const Icon(Icons.door_front_door_outlined),
            label: const Text('Simulate gate'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => onSimulate(ScanType.attendance),
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Simulate class'),
          ),
        ),
      ],
    );
  }
}
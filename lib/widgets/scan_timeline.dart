import 'package:flutter/material.dart';
import 'package:uni_connect/models/scan_event.dart';
import 'package:uni_connect/utils/date_format.dart';
import 'package:uni_connect/widgets/scan_status_chip.dart';

enum _Filter { all, gate, attendance }

class ScanTimeline extends StatefulWidget {
  const ScanTimeline({super.key, required this.events, this.limit});

  final List<ScanEvent> events;
  final int? limit;

  @override
  State<ScanTimeline> createState() => _ScanTimelineState();
}

class _ScanTimelineState extends State<ScanTimeline> {
  _Filter _filter = _Filter.all;

  List<ScanEvent> get _visible {
    final filtered = widget.events.where((e) {
      switch (_filter) {
        case _Filter.all:
          return true;
        case _Filter.gate:
          return e.type == ScanType.gate;
        case _Filter.attendance:
          return e.type == ScanType.attendance;
      }
    }).toList();
    final limit = widget.limit;
    return limit == null ? filtered : filtered.take(limit).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent scans',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            _chip('All', _Filter.all),
            _chip('Gate', _Filter.gate),
            _chip('Class', _Filter.attendance),
          ],
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          _EmptyBox()
        else
          for (int i = 0; i < items.length; i++)
            _TimelineRow(event: items[i], isLast: i == items.length - 1),
      ],
    );
  }

  Widget _chip(String label, _Filter value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      selectedColor: Colors.orange.shade100,
      onSelected: (_) => setState(() => _filter = value),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.nfc, size: 40, color: Colors.orange.shade300),
          const SizedBox(height: 8),
          Text(
            'Your scans will appear here',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.isLast});

  final ScanEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isGate = event.type == ScanType.gate;
    final color = isGate ? Colors.orange.shade800 : Colors.teal.shade600;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    isGate
                        ? Icons.door_front_door_outlined
                        : Icons.fact_check_outlined,
                    color: color,
                    size: 20,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: Colors.grey.shade300),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(event.subtitle),
                  const SizedBox(height: 2),
                  Text(
                    formatDateTime(context, event.time),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Align(
              alignment: Alignment.topRight,
              child: ScanStatusChip(event: event),
            ),
          ),
        ],
      ),
    );
  }
}
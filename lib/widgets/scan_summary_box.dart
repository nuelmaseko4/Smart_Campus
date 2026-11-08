import 'package:flutter/material.dart';
import 'package:uni_connect/models/scan_event.dart';
import 'package:uni_connect/utils/date_format.dart';
import 'scan_status_chip.dart';

class ScanSummaryBox extends StatelessWidget {
  const ScanSummaryBox({super.key, required this.type, required this.latest});

  final ScanType type;
  final ScanEvent? latest;

  bool get _isGate => type == ScanType.gate;
  Color get _color => _isGate ? Colors.orange.shade800 : Colors.teal.shade600;
  IconData get _icon =>
      _isGate ? Icons.door_front_door_outlined : Icons.fact_check_outlined;
  String get _label => _isGate ? 'Gate entry' : 'Class attendance';
  String get _emptyText => _isGate
      ? 'Your gate scans will appear here'
      : 'Your class scans will appear here';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _color.withValues(alpha: 0.12),
                ),
                child: Icon(_icon, color: _color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: latest == null
                ? _empty(context)
                : _filled(context, latest!),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Container(
      key: const ValueKey('empty'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.nfc, color: _color.withValues(alpha: 0.5), size: 28),
          const SizedBox(height: 8),
          Text(
            _emptyText,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _filled(BuildContext context, ScanEvent scan) {
    return Column(
      key: ValueKey(scan.id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          scan.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          scan.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                timeAgo(scan.time),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
            ScanStatusChip(event: scan),
          ],
        ),
      ],
    );
  }
}
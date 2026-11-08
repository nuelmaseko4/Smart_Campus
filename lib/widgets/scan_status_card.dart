import 'package:flutter/material.dart';
import 'package:uni_connect/models/scan_event.dart';
import 'package:uni_connect/utils/date_format.dart';

class ScanStatusCard extends StatefulWidget {
  const ScanStatusCard({
    super.key,
    required this.newScan,
    required this.onDismiss,
  });

  final ScanEvent? newScan;
  final VoidCallback onDismiss;

  @override
  State<ScanStatusCard> createState() => _ScanStatusCardState();
}

class _ScanStatusCardState extends State<ScanStatusCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scan = widget.newScan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade900,
            Colors.orange.shade800,
            Colors.orange.shade400,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade800.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
              child: child,
            ),
          ),
          child: scan == null ? _idle() : _success(context, scan),
        ),
      ),
    );
  }

  Widget _idle() {
    return Row(
      key: const ValueKey('idle'),
      children: [
        SizedBox(width: 84, height: 84, child: _radar()),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                  SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'Ready to scan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tap your campus card at a reader. Your scan will appear here.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _radar() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < 3; i++) _ring((_pulse.value + i / 3) % 1.0),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(Icons.nfc, color: Colors.orange.shade900),
            ),
          ],
        );
      },
    );
  }

  Widget _ring(double v) {
    return Opacity(
      opacity: ((1 - v) * 0.5).clamp(0.0, 1.0),
      child: Container(
        width: 48 + 36 * v,
        height: 48 + 36 * v,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  Widget _success(BuildContext context, ScanEvent scan) {
    final isGate = scan.type == ScanType.gate;

    return Row(
      key: ValueKey(scan.id),
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.elasticOut,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.green.shade600,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isGate ? 'Gate entry recorded' : 'Attendance marked',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                scan.title,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                formatDateTime(context, scan.time),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Dismiss',
          onPressed: widget.onDismiss,
          icon: const Icon(Icons.close, color: Colors.white70),
        ),
      ],
    );
  }
}

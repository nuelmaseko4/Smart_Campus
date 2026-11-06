import 'package:flutter/material.dart';

class RoleBadge extends StatefulWidget {
  const RoleBadge({super.key, this.icon = Icons.account_balance_outlined});

  final IconData icon;

  @override
  State<RoleBadge> createState() => _RoleBadgeState();
}

class _RoleBadgeState extends State<RoleBadge> with TickerProviderStateMixin {
  late final AnimationController _pop;
  late final AnimationController _pulse;
  late final Animation<double> _popScale;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _popScale = _pop.drive(CurveTween(curve: Curves.elasticOut));
    _pulseScale = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pop.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _popScale,
        child: ScaleTransition(
          scale: _pulseScale,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
              border: Border.all(color: Colors.white54, width: 2),
            ),
            child: Icon(widget.icon, color: Colors.white, size: 48),
          ),
        ),
      ),
    );
  }
}
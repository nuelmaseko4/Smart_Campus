import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_loop.value);
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.lerp(Alignment.topLeft, Alignment.topRight, t)!,
              end: Alignment.lerp(
                  Alignment.bottomRight, Alignment.bottomLeft, t)!,
              colors: [
                Colors.orange.shade900,
                Colors.orange.shade800,
                Colors.orange.shade400,
              ],
            ),
          ),
          child: child,
        );
      },
      child: Stack(
        children: [
          _Bubble(loop: _loop, size: 160, x: -0.9, y: -0.8, phase: 0.0),
          _Bubble(loop: _loop, size: 90, x: 0.9, y: -0.4, phase: 1.5),
          _Bubble(loop: _loop, size: 120, x: -0.7, y: 0.7, phase: 3.0),
          _Bubble(loop: _loop, size: 70, x: 0.8, y: 0.85, phase: 4.5),
          widget.child,
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.loop,
    required this.size,
    required this.x,
    required this.y,
    required this.phase,
  });

  final Animation<double> loop;
  final double size;
  final double x;
  final double y;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loop,
      builder: (context, _) {
        final angle = loop.value * 2 * math.pi + phase;
        return Align(
          alignment: Alignment(
            x + 0.06 * math.sin(angle),
            y + 0.05 * math.cos(angle),
          ),
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white10,
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

/// Fades and slides a child up while [controller] runs between [start] and [end].
class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.curve = Curves.easeOutCubic,
  });

  final Animation<double> controller;
  final double start;
  final double end;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation =
        controller.drive(CurveTween(curve: Interval(start, end, curve: curve)));

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }
}
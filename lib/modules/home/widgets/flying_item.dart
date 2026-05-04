import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class FlyingItem extends StatefulWidget {
  final Offset start;
  final Offset end;
  final VoidCallback? onComplete;
  final Widget child;
  const FlyingItem({
    super.key,
    required this.start,
    required this.end,
    this.onComplete,
    required this.child,
  });

  @override
  State<FlyingItem> createState() => _FlyingItemState();
}

class _FlyingItemState extends State<FlyingItem>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, child) {
          final t = controller.value;

          final dx = lerpDouble(widget.start.dx, widget.end.dx, t)!;

          final dy =
              lerpDouble(widget.start.dy, widget.end.dy, t)! - 80 * sin(t * pi);

          final scale = lerpDouble(1.0, 0.2, t)!;

          return Stack(
            children: [
              Positioned(
                left: dx,
                top: dy,
                child: Transform.scale(scale: scale, child: child),
              ),
            ],
          );
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          child: widget.child,
        ),
      ),
    );
  }
}

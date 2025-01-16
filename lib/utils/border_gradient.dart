import 'dart:math';
import 'package:flutter/material.dart';

class BorderGradient extends StatefulWidget {
  final Widget child;
  final List<Color> gradientColors;
  final double borderWidth;
  final double borderRadius;
  final Duration duration;

  const BorderGradient({
    super.key,
    required this.child,
    this.gradientColors = const [
      Colors.blue,
      Colors.purple,
      Colors.pinkAccent,
      Colors.blue,
    ],
    this.borderWidth = 3.0,
    this.borderRadius = 25.0,
    this.duration = const Duration(seconds: 5),
  });

  @override
  State<BorderGradient> createState() => _BorderGradientState();
}

class _BorderGradientState extends State<BorderGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = _animationController.value * 2 * pi;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: SweepGradient(
              transform: GradientRotation(value),
              colors: widget.gradientColors,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
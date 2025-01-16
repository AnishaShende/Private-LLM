import 'dart:math';
import 'package:flutter/material.dart';

class GradientIcon extends StatefulWidget {
  final double size;

  const GradientIcon({super.key, this.size = 24.0});

  @override
  State<GradientIcon> createState() => _GradientIconState();
}

class _GradientIconState extends State<GradientIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: const [
                // Colors.blue,
                // Colors.pinkAccent,
                // Colors.blue,
                Color.fromARGB(228, 249, 100, 100),
                Colors.purple,
                Color.fromARGB(233, 80, 172, 247),
              ],
              transform: GradientRotation(_controller.value * 2 * pi),
            ).createShader(bounds);
          },
          child: Icon(
            Icons.add_circle,
            size: widget.size,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

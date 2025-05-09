import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Offset> _pixels = [];
  final int pixelCount = 100;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addListener(() {
      setState(() {
        _pixels = _pixels.map((p) {
          double dy = p.dy + 1.5;
          if (dy > MediaQuery.of(context).size.height) {
            dy = 0;
          }
          return Offset(p.dx, dy);
        }).toList();
      });
    })..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;

    // Génère les pixels la première fois après que le contexte est prêt
    if (_pixels.isEmpty) {
      _pixels = List.generate(
        pixelCount,
            (_) => Offset(_random.nextDouble() * size.width, _random.nextDouble() * size.height),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _PixelPainter(_pixels),
    );
  }
}

class _PixelPainter extends CustomPainter {
  final List<Offset> pixels;
  final Paint paintDot = Paint();

  _PixelPainter(this.pixels);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in pixels) {
      paintDot.color = Colors.white.withOpacity(0.3 + Random().nextDouble() * 0.7);
      canvas.drawRect(Rect.fromCenter(center: p, width: 2.5, height: 2.5), paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

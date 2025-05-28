import 'dart:math';
import 'package:flutter/material.dart';

class ParabolaBar extends StatefulWidget {
  final double width;
  final double height;
  final Duration duration;
  final Color borderColor;
  final Color glowColor;
  final double borderWidth;
  final double? glowWidth;
  final Widget? child;
  final bool loop;
  final double? value;
  final bool useGradient;
  final List<Color> gradientColors;
  final bool inverted;

  const ParabolaBar({
    Key? key,
    required this.width,
    required this.height,
    this.duration = const Duration(seconds: 10),
    this.borderColor = Colors.white,
    this.glowColor = Colors.orange,
    this.borderWidth = 4,
    this.glowWidth,
    this.child,
    this.loop = false,
    this.value,
    this.useGradient = false,
    this.gradientColors = const [Colors.white],
    this.inverted = false,
  }) : super(key: key);

  @override
  _ParabolaBarState createState() => _ParabolaBarState();
}

class _ParabolaBarState extends State<ParabolaBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    if (widget.value == null) {
      _progress = Tween<double>(begin: 0, end: 1).animate(_controller);
      if (widget.loop) {
        _controller.repeat();
      } else {
        _controller.forward();
      }
    } else {
      _progress = AlwaysStoppedAnimation(widget.value!);
    }
  }

  @override
  void didUpdateWidget(covariant ParabolaBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != null && widget.value != _oldValue) {
      final double newValue = widget.value!;
      final diff = (newValue - _oldValue).abs();
      final newDuration = Duration(milliseconds: (widget.duration.inMilliseconds * diff).toInt());

      _progress = Tween<double>(begin: _oldValue, end: newValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );

      _controller.duration = newDuration;
      _controller.reset();
      _controller.forward();

      _oldValue = newValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowWidth = widget.glowWidth ?? widget.borderWidth + 2;

    return AnimatedBuilder(
      animation: _progress,
      builder: (_, __) {
        return CustomPaint(
          painter: _ParabolaPainter(
            progress: _progress.value,
            borderColor: widget.borderColor,
            glowColor: widget.glowColor,
            borderWidth: widget.borderWidth,
            glowWidth: glowWidth,
            useGradient: widget.useGradient,
            gradientColors: widget.gradientColors,
            inverted: widget.inverted,
          ),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _ParabolaPainter extends CustomPainter {
  final double progress;
  final Color borderColor;
  final Color glowColor;
  final double borderWidth;
  final double glowWidth;
  final bool useGradient;
  final List<Color> gradientColors;
  final bool inverted;

  _ParabolaPainter({
    required this.progress,
    required this.borderColor,
    required this.glowColor,
    required this.borderWidth,
    required this.glowWidth,
    required this.useGradient,
    required this.gradientColors,
    required this.inverted,
  });

  Path _createParabolaPath(Size size) {
    final path = Path();
    final a = 4 * size.height / pow(size.width, 2);
    final startX = -size.width / 2;
    final endX = size.width / 2;
    final step = size.width / 100;

    for (double x = startX; x <= endX; x += step) {
      final px = x + size.width / 2;
      final py = a * x * x;
      final y = inverted ? size.height - py : py;
      if (x == startX) {
        path.moveTo(px, y);
      } else {
        path.lineTo(px, y);
      }
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createParabolaPath(size);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = borderColor;

    canvas.drawPath(path, borderPaint);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowWidth
      ..strokeCap = StrokeCap.round;

    if (useGradient && gradientColors.length > 1) {
      glowPaint.shader = SweepGradient(
        colors: gradientColors,
        startAngle: 0,
        endAngle: 2 * pi,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      glowPaint.color = glowColor;
    }

    final metric = path.computeMetrics().first;
    final totalLength = metric.length;
    final end = totalLength * progress;

    final glowPath = metric.extractPath(0, end);
    canvas.drawPath(glowPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _ParabolaPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.inverted != inverted ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.glowWidth != glowWidth ||
        oldDelegate.useGradient != useGradient ||
        oldDelegate.gradientColors != gradientColors;
  }
}

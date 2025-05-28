import 'dart:math';
import 'package:flutter/material.dart';

class HeartBar extends StatefulWidget {
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

  const HeartBar({
    Key? key,
    required this.width,
    required this.height,
    this.duration = const Duration(seconds: 10),
    this.borderColor = Colors.white,
    this.glowColor = Colors.red,
    this.borderWidth = 4,
    this.glowWidth,
    this.child,
    this.loop = false,
    this.value,
    this.useGradient = false,
    this.gradientColors = const [Colors.white],
  }) : super(key: key);

  @override
  _HeartBarState createState() => _HeartBarState();
}

class _HeartBarState extends State<HeartBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

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
  void didUpdateWidget(covariant HeartBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != null && widget.value != _oldValue) {
      final double newValue = widget.value!;
      final double diff = (newValue - _oldValue).abs();
      final Duration newDuration = Duration(
        milliseconds: (widget.duration.inMilliseconds * diff).toInt(),
      );

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
          painter: _HeartPainter(
            progress: _progress.value,
            borderColor: widget.borderColor,
            glowColor: widget.glowColor,
            borderWidth: widget.borderWidth,
            glowWidth: glowWidth,
            useGradient: widget.useGradient,
            gradientColors: widget.gradientColors,
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

class _HeartPainter extends CustomPainter {
  final double progress;
  final Color borderColor;
  final Color glowColor;
  final double borderWidth;
  final double glowWidth;
  final bool useGradient;
  final List<Color> gradientColors;

  _HeartPainter({
    required this.progress,
    required this.borderColor,
    required this.glowColor,
    required this.borderWidth,
    required this.glowWidth,
    required this.useGradient,
    required this.gradientColors,
  });

  Path _createHeartPath(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final scale = min(width, height) / 32;

    bool isFirst = true;
    for (double t = 0; t <= 2 * pi; t += 0.01) {
      final x = scale * 16 * pow(sin(t), 3);
      final y = -scale * (13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t));
      final dx = x + width / 2;
      final dy = y + height / 2;

      if (isFirst) {
        path.moveTo(dx, dy);
        isFirst = false;
      } else {
        path.lineTo(dx, dy);
      }
    }

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createHeartPath(size);

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

    final metrics = path.computeMetrics().first;
    final length = metrics.length;
    final end = length * progress;

    final glowPath = metrics.extractPath(0, end);
    canvas.drawPath(glowPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _HeartPainter old) {
    return old.progress != progress ||
        old.borderColor != borderColor ||
        old.glowColor != glowColor ||
        old.borderWidth != borderWidth ||
        old.glowWidth != glowWidth ||
        old.useGradient != useGradient ||
        old.gradientColors != gradientColors;
  }
}

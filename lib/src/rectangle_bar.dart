import 'dart:math';
import 'package:flutter/material.dart';

enum BorderCorner { topLeft, topRight, bottomRight, bottomLeft }

class RectangleBar extends StatefulWidget {
  final double width;
  final double height;
  final Duration duration;
  final Color borderColor;
  final Color glowColor;
  final double borderWidth;
  final double? glowWidth;
  final BorderCorner startCorner;
  final double borderRadius;
  final Widget? child;
  final bool loop;
  final double? value;
  final bool useGradient;
  final List<Color> gradientColors;

  const RectangleBar({
    Key? key,
    required this.width,
    required this.height,
    this.duration = const Duration(seconds: 10),
    this.borderColor = Colors.white,
    this.glowColor = Colors.orange,
    this.borderWidth = 4,
    this.glowWidth,
    this.startCorner = BorderCorner.topLeft,
    this.borderRadius = 0,
    this.child,
    this.loop = false,
    this.value, // Optional progress control
    this.useGradient = false,
    this.gradientColors = const [Colors.white],
  }) : super(key: key);

  @override
  _RectangleBarState createState() => _RectangleBarState();
}

class _RectangleBarState extends State<RectangleBar> with SingleTickerProviderStateMixin {
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
        _controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _controller.stop();
          }
        });
        _controller.forward();
      }
    } else {
      _progress = AlwaysStoppedAnimation(widget.value!);
    }
  }

  @override
  void didUpdateWidget(covariant RectangleBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != null && widget.value != _oldValue) {
      final double newValue = widget.value!;
      final double valueDifference = (newValue - _oldValue).abs();
      final Duration valueDuration = Duration(
        milliseconds: (widget.duration.inMilliseconds * valueDifference).toInt(),
      );

      _progress = Tween<double>(begin: _oldValue, end: newValue)
          .animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _controller.duration = valueDuration;
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

  double _cornerToAngle(BorderCorner corner) {
    switch (corner) {
      case BorderCorner.topLeft:
        return 0;
      case BorderCorner.topRight:
        return 90;
      case BorderCorner.bottomRight:
        return 180;
      case BorderCorner.bottomLeft:
        return 270;
    }
  }

  @override
  Widget build(BuildContext context) {
    final startAngle = _cornerToAngle(widget.startCorner);
    final glowWidth = widget.glowWidth ?? widget.borderWidth + 2;

    return AnimatedBuilder(
      animation: _progress,
      builder: (_, __) {
        return CustomPaint(
          painter: _TracingBorderPainter(
            progress: _progress.value,
            borderColor: widget.borderColor,
            glowColor: widget.glowColor,
            borderWidth: widget.borderWidth,
            glowWidth: glowWidth,
            startAngle: startAngle,
            borderRadius: widget.borderRadius,
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

class _TracingBorderPainter extends CustomPainter {
  final double progress;
  final Color borderColor;
  final Color glowColor;
  final double borderWidth;
  final double glowWidth;
  final double startAngle;
  final double borderRadius;
  final bool useGradient;
  final List<Color> gradientColors;

  _TracingBorderPainter({
    required this.progress,
    required this.borderColor,
    required this.glowColor,
    required this.borderWidth,
    required this.glowWidth,
    required this.startAngle,
    required this.borderRadius,
    required this.useGradient,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final borderPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = borderColor;

    canvas.drawPath(borderPath, borderPaint);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowWidth
      ..strokeCap = StrokeCap.round;

    if (useGradient && gradientColors.length > 1) {
      glowPaint.shader = SweepGradient(
        colors: gradientColors,
        startAngle: 0,
        endAngle: 2 * pi,
        transform: GradientRotation((startAngle % 360) * pi / 180),
      ).createShader(rect);
    } else {
      glowPaint.color = glowColor;
    }

    final metric = borderPath.computeMetrics().first;
    final totalLength = metric.length;
    final offset = (startAngle % 360) / 360.0;
    final start = totalLength * offset;
    final end = start + totalLength * progress;

    if (end <= totalLength) {
      final glowPath = metric.extractPath(start, end);
      canvas.drawPath(glowPath, glowPaint);
    } else {
      final part1 = metric.extractPath(start, totalLength);
      final part2 = metric.extractPath(0, end - totalLength);
      canvas.drawPath(part1, glowPaint);
      canvas.drawPath(part2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracingBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.glowWidth != glowWidth ||
        oldDelegate.startAngle != startAngle ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.useGradient != useGradient ||
        oldDelegate.gradientColors != gradientColors;
  }
}

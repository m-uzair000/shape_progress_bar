import 'dart:math';
import 'package:flutter/material.dart';

enum ArrowDirection { right, left, up, down }

class ArrowBar extends StatefulWidget {
  final double width;
  final double height;
  final Duration duration;
  final Color backgroundColor;
  final Color progressColor;
  final double? progress; // null = looping
  final ArrowDirection direction;
  final bool useGradient;
  final List<Color> gradientColors;

  const ArrowBar({
    Key? key,
    required this.width,
    required this.height,
    this.duration = const Duration(seconds: 3),
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.progress,
    this.direction = ArrowDirection.right,
    this.useGradient = false,
    this.gradientColors = const [Colors.blue, Colors.green],
  }) : super(key: key);

  @override
  State<ArrowBar> createState() => _ArrowBarState();
}

class _ArrowBarState extends State<ArrowBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    if (widget.progress == null) {
      _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
        ..addListener(() => setState(() {}));
      _controller.repeat();
    } else {
      _animation = Tween<double>(begin: 0, end: widget.progress!).animate(_controller)
        ..addListener(() => setState(() {}));
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ArrowBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != null && widget.progress != _previousProgress) {
      _animation = Tween<double>(begin: _previousProgress, end: widget.progress!).animate(_controller);
      _controller
        ..reset()
        ..forward();
      _previousProgress = widget.progress!;
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
      size: Size(widget.width, widget.height),
      painter: _RoundedArrowPainter(
        progress: _animation.value,
        backgroundColor: widget.backgroundColor,
        progressColor: widget.progressColor,
        direction: widget.direction,
        useGradient: widget.useGradient,
        gradientColors: widget.gradientColors,
      ),
    );
  }
}

class _RoundedArrowPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final ArrowDirection direction;
  final bool useGradient;
  final List<Color> gradientColors;

  _RoundedArrowPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.direction,
    required this.useGradient,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    if (useGradient && gradientColors.length > 1) {
      progressPaint.shader = LinearGradient(
        colors: gradientColors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      progressPaint.color = progressColor;
    }

    final Path path = _buildRoundedArrowPath(size);

    // Draw full background
    canvas.drawPath(path, backgroundPaint);

    // Draw progress stroke
    final pathMetrics = path.computeMetrics().toList();
    final totalLength = pathMetrics.fold(0.0, (sum, m) => sum + m.length);
    final drawLength = totalLength * progress;

    double drawn = 0.0;
    for (final metric in pathMetrics) {
      final remaining = drawLength - drawn;
      if (remaining <= 0) break;
      final segment = remaining.clamp(0, metric.length).toDouble();
      final subPath = metric.extractPath(0, segment);
      canvas.drawPath(subPath, progressPaint);
      drawn += segment;
    }
  }

  Path _buildRoundedArrowPath(Size size) {
    final Path path = Path();
    final radius = min(size.width, size.height) * 0.15;

    switch (direction) {
      case ArrowDirection.right:
        path.moveTo(0 + radius, size.height / 2);
        path.lineTo(size.width - size.height / 2, size.height / 2);
        path.arcToPoint(
          Offset(size.width - size.height / 2, size.height * 0.3),
          radius: Radius.circular(radius),
          clockwise: false,
        );
        path.lineTo(size.width, size.height / 2);
        path.lineTo(size.width - size.height / 2, size.height * 0.7);
        path.arcToPoint(
          Offset(size.width - size.height / 2, size.height / 2),
          radius: Radius.circular(radius),
          clockwise: false,
        );
        break;

      case ArrowDirection.left:
        path.moveTo(size.width - radius, size.height / 2);
        path.lineTo(size.height / 2, size.height / 2);
        path.arcToPoint(
          Offset(size.height / 2, size.height * 0.3),
          radius: Radius.circular(radius),
          clockwise: false,
        );
        path.lineTo(0, size.height / 2);
        path.lineTo(size.height / 2, size.height * 0.7);
        path.arcToPoint(
          Offset(size.height / 2, size.height / 2),
          radius: Radius.circular(radius),
          clockwise: false,
        );
        break;

      case ArrowDirection.up:
        path.moveTo(size.width / 2, size.height - radius);
        path.lineTo(size.width / 2, size.height * 0.3);
        path.arcToPoint(
          Offset(size.width * 0.3, size.height * 0.3),
          radius: Radius.circular(radius),
          clockwise: false,
        );
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width * 0.7, size.height * 0.3);
        path.arcToPoint(
          Offset(size.width / 2, size.height * 0.3),
          radius: Radius.circular(radius),
          clockwise: false,
        );
        break;

      case ArrowDirection.down:
        path.moveTo(size.width / 2, radius);
        path.lineTo(size.width / 2, size.height * 0.7);
        path.arcToPoint(
          Offset(size.width * 0.3, size.height * 0.7),
          radius: Radius.circular(radius),
          clockwise: false,
        );
        path.lineTo(size.width / 2, size.height);
        path.lineTo(size.width * 0.7, size.height * 0.7);
        path.arcToPoint(
          Offset(size.width / 2, size.height * 0.7),
          radius: Radius.circular(radius),
          clockwise: false,
        );
        break;
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant _RoundedArrowPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.direction != direction ||
        oldDelegate.useGradient != useGradient ||
        oldDelegate.gradientColors != gradientColors;
  }
}

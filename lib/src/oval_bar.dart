import 'dart:math';
import 'package:flutter/material.dart';

class OvalBar extends StatefulWidget {
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

  const OvalBar({
    Key? key,
    required this.width,
    required this.height,
    this.duration = const Duration(seconds: 10),
    this.borderColor = Colors.white,
    this.glowColor = Colors.blue,
    this.borderWidth = 4,
    this.glowWidth,
    this.child,
    this.loop = false,
    this.value,
    this.useGradient = false,
    this.gradientColors = const [Colors.white],
  }) : super(key: key);

  @override
  _OvalBarState createState() => _OvalBarState();
}

class _OvalBarState extends State<OvalBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    if (widget.value == null) {
      _progress = Tween<double>(begin: 0, end: 1).animate(_controller);
      widget.loop ? _controller.repeat() : _controller.forward();
    } else {
      _progress = AlwaysStoppedAnimation(widget.value!);
    }
  }

  @override
  void didUpdateWidget(covariant OvalBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != null && widget.value != _oldValue) {
      final newValue = widget.value!;
      final diff = (newValue - _oldValue).abs();
      final newDuration = Duration(
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
          size: Size(widget.width, widget.height),
          painter: _OvalPainter(
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

class _OvalPainter extends CustomPainter {
  final double progress;
  final Color borderColor;
  final Color glowColor;
  final double borderWidth;
  final double glowWidth;
  final bool useGradient;
  final List<Color> gradientColors;

  _OvalPainter({
    required this.progress,
    required this.borderColor,
    required this.glowColor,
    required this.borderWidth,
    required this.glowWidth,
    required this.useGradient,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2));

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = borderColor;

    canvas.drawRRect(rrect, borderPaint);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowWidth
      ..strokeCap = StrokeCap.round;

    if (useGradient && gradientColors.length > 1) {
      glowPaint.shader = SweepGradient(
        colors: gradientColors,
        startAngle: 0,
        endAngle: 2 * pi,
      ).createShader(rect);
    } else {
      glowPaint.color = glowColor;
    }

    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    final length = metric.length;
    final end = length * progress;

    final glowPath = metric.extractPath(0, end);
    canvas.drawPath(glowPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _OvalPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.glowWidth != glowWidth ||
        oldDelegate.useGradient != useGradient ||
        oldDelegate.gradientColors != gradientColors;
  }
}

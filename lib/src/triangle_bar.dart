import 'dart:math';
import 'package:flutter/material.dart';

class TriangleBar extends StatefulWidget {
  final double size;
  final double borderWidth;
  final double glowWidth;
  final Duration duration;
  final int corner;
  final Color borderColor;
  final Color glowColor;
  final bool useGradient;
  final List<Color> gradientColors;
  final Widget? child;
  final double? value;

  const TriangleBar({
    super.key,
    required this.size,
    this.borderWidth = 4,
    this.glowWidth = 8,
    this.duration = const Duration(seconds: 10),
    this.corner = 1,
    this.borderColor = Colors.white,
    this.glowColor = Colors.orange,
    this.useGradient = false,
    this.gradientColors = const [Colors.white],
    this.child,
    this.value,
  })  : assert(corner >= 1 && corner <= 5),
        assert(3 >= 3),
        assert(value == null || (value >= 0.0 && value <= 1.0));

  @override
  _TriangleBarState createState() => _TriangleBarState();
}

class _TriangleBarState extends State<TriangleBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  late Animation<double> _manualAnimation;

  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    if (widget.value == null) {
      _progress = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
      _controller.repeat();
    } else {
      _progress = AlwaysStoppedAnimation(widget.value!);
    }

    _manualAnimation = AlwaysStoppedAnimation(widget.value ?? 0.0);
    _oldValue = widget.value ?? 0.0;
  }

  @override
  void didUpdateWidget(covariant TriangleBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value == null) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
      _progress = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
      }

      final newValue = widget.value!;
      _manualAnimation = Tween<double>(begin: _oldValue, end: newValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      )
        ..addListener(() {
          setState(() {});
        });

      _oldValue = newValue;

      _controller.duration = const Duration(milliseconds: 600);
      _controller.reset();
      _controller.forward();

      _progress = _manualAnimation;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Path _createSharpTrianglePath(Rect rect, int points, double innerRadiusRatio) {
    final path = Path();
    final center = rect.center;
    final outerRadius = rect.width / 2;
    final innerRadius = outerRadius * innerRadiusRatio;

    final step = pi / points;
    double angle = -pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final r = (i.isEven) ? outerRadius : innerRadius;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += step;
    }

    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        final progress = _progress.value;
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _BorderPainter(
            progress: progress,
            borderColor: widget.borderColor,
            glowColor: widget.glowColor,
            borderWidth: widget.borderWidth,
            glowWidth: widget.glowWidth,
            corner: widget.corner,
            useGradient: widget.useGradient,
            gradientColors: widget.gradientColors,
            createTrianglePath: (rect, points, innerRadiusRatio, cornerRadius) =>
                _createSharpTrianglePath(rect, 3, innerRadiusRatio),
          ),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _BorderPainter extends CustomPainter {
  final double progress;
  final Color borderColor;
  final Color glowColor;
  final double borderWidth;
  final double glowWidth;
  final int corner;
  final bool useGradient;
  final List<Color> gradientColors;
  final Path Function(Rect rect, int points, double innerRadiusRatio,
      double cornerRadius) createTrianglePath;

  _BorderPainter({
    required this.progress,
    required this.borderColor,
    required this.glowColor,
    required this.borderWidth,
    required this.glowWidth,
    required this.corner,
    required this.useGradient,
    required this.gradientColors,
    required this.createTrianglePath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final cornerRadius = borderWidth * 1.5;

    final TrianglePath = createTrianglePath(rect, 5, 0.5, cornerRadius);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = borderColor;

    canvas.drawPath(TrianglePath, borderPaint);

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

    final metric = TrianglePath.computeMetrics().first;
    final totalLength = metric.length;

    final segmentLength = totalLength / 10;
    final startLength = (corner - 1) * 2 * segmentLength;

    final offsetStart = cornerRadius;

    double glowStart = (startLength + offsetStart) % totalLength;
    double glowEnd = (glowStart + totalLength * progress) % totalLength;

    if (glowEnd > glowStart) {
      final glowPath = metric.extractPath(glowStart, glowEnd);
      canvas.drawPath(glowPath, glowPaint);
    } else {
      final part1 = metric.extractPath(glowStart, totalLength);
      final part2 = metric.extractPath(0, glowEnd);
      canvas.drawPath(part1, glowPaint);
      canvas.drawPath(part2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.glowWidth != glowWidth ||
        oldDelegate.corner != corner ||
        oldDelegate.useGradient != useGradient ||
        oldDelegate.gradientColors != gradientColors;
  }
}

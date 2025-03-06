import 'dart:ui';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';

class CircularChartPainter extends CustomPainter {
  final double completionPercentage;
  final double effectivenessPercentage;
  CircularChartPainter({
    required this.completionPercentage,
    required this.effectivenessPercentage,
  });
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 12.0;
    double radius = size.width / 1.5;

    // Define the paints for each section
    Paint backgroundCircle = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Paint section1 = Paint()
      ..color = effectivenessPercentage < 50
          ? Styles.fail!
          : effectivenessPercentage > 79
              ? Styles.success!
              : Styles.warning!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    Paint section2 = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    Paint section3 = Paint()
      ..color = Styles.successTextColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw the background circle
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), radius, backgroundCircle);

    // Draw the colored segments
    double startAngle =
        -90 * (3.14159265359 / 180); // Convert degrees to radians
    double sweepAngle1 = completionPercentage * (3.14159265359 / 180);
    double sweepAngle2 = 0 * (3.14159265359 / 180);
    double sweepAngle3 = 0 * (3.14159265359 / 180);

    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: radius),
      startAngle,
      sweepAngle1,
      false,
      section1,
    );

    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: radius),
      startAngle + sweepAngle1,
      sweepAngle2,
      false,
      section2,
    );

    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: radius),
      startAngle + sweepAngle1 + sweepAngle2,
      sweepAngle3,
      false,
      section3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

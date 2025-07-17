import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class WaterFilledRectangle extends StatefulWidget {
  final WaterRectLayoutType layoutType;
  final double width;
  final double height;
  final double depth;
  final double fillStockPercentage;
  final double fillWithdrawPercentage;
  final double fillFreePercentage; // เพิ่มมาใช้กับสามส่วน
  final Color borderColor;
  final Color stockColor;
  final Color withdrawColor;
  final Color freeColor;
  final TextStyle? textStyle;

  const WaterFilledRectangle({
    Key? key,
    required this.layoutType,
    required this.width,
    required this.height,
    required this.depth,
    required this.fillStockPercentage,
    required this.fillWithdrawPercentage,
    required this.fillFreePercentage,
    this.borderColor = Colors.black,
    this.stockColor = Colors.red,
    this.withdrawColor = Colors.amber,
    this.freeColor = Colors.green,
    this.textStyle,
  }) : super(key: key);

  @override
  _WaterFilledRectangleState createState() => _WaterFilledRectangleState();
}

class _WaterFilledRectangleState extends State<WaterFilledRectangle>
    with SingleTickerProviderStateMixin {
  double _rotationAngle = 10.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.width * 2, widget.height * 2),
              painter: RectanglePainter(
                layoutType: widget.layoutType,
                width: widget.width,
                height: widget.height,
                depth: widget.depth,
                fillStockPercentage: widget.fillStockPercentage,
                fillWithdrawPercentage: widget.fillWithdrawPercentage,
                fillFreePercentage: widget.fillFreePercentage,
                rotationAngle: _rotationAngle,
                borderColor: widget.borderColor,
                stockColor: widget.stockColor.withOpacity(0.5),
                withdrawColor: widget.withdrawColor.withOpacity(0.5),
                freeColor: widget.freeColor.withOpacity(0.5),
                textStyle: widget.textStyle,
                context: context,
              ),
            );
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

class RectanglePainter extends CustomPainter {
  final WaterRectLayoutType layoutType;
  final double width;
  final double height;
  final double depth;
  final double fillStockPercentage;
  final double fillWithdrawPercentage;
  final double fillFreePercentage;
  final double rotationAngle;
  final Color borderColor;
  final Color stockColor;
  final Color withdrawColor;
  final Color freeColor;
  final TextStyle? textStyle;
  final BuildContext context;

  RectanglePainter({
    required this.layoutType,
    required this.width,
    required this.height,
    required this.depth,
    required this.fillStockPercentage,
    required this.fillWithdrawPercentage,
    required this.fillFreePercentage,
    required this.rotationAngle,
    required this.borderColor,
    required this.stockColor,
    required this.withdrawColor,
    required this.freeColor,
    this.textStyle,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Rectangle vertices in 3D
    final vertices = [
      Offset3D(-width, -height, depth),
      Offset3D(width, -height, depth),
      Offset3D(width, height, depth),
      Offset3D(-width, height, depth),
      Offset3D(-width, -height, -depth),
      Offset3D(width, -height, -depth),
      Offset3D(width, height, -depth),
      Offset3D(-width, height, -depth),
    ];

    final rotatedVertices =
        vertices.map((v) => rotateY(v, rotationAngle)).toList();
    final projected = rotatedVertices.map((v) => project3D(v, size)).toList();

    void drawEdge(int i, int j, Color color) {
      paint.color = color;
      canvas.drawLine(projected[i], projected[j], paint);
    }

    // Draw rectangle borders
    for (final face in [
      [0, 1, 2, 3],
      [4, 5, 6, 7],
      [0, 4, 7, 3],
      [1, 5, 6, 2]
    ]) {
      for (int i = 0; i < face.length; i++) {
        drawEdge(face[i], face[(i + 1) % face.length], borderColor);
      }
    }

    // *** Main logic: draw different layouts ***
    switch (layoutType) {
      case WaterRectLayoutType.stockOnly:
        _drawStockSection(canvas, size, paint);
        break;
      case WaterRectLayoutType.withdrawAndStock:
        _drawWithdrawAndStockSection(canvas, size, paint);
        break;
      case WaterRectLayoutType.threeSection:
        _drawThreeSection(canvas, size, paint);
        break;
    }
  }

  // ------------ DRAW LOGICS FOR EACH LAYOUT --------------

  void _drawStockSection(Canvas canvas, Size size, Paint paint) {
    // วาดเหมือน logic เดิมใน else { ... }
    final wateHeight = (height * 2) * fillStockPercentage.clamp(0.0, 1.0);

    final waterVerticesStock = [
      Offset3D(-width, height - wateHeight, depth),
      Offset3D(width, height - wateHeight, depth),
      Offset3D(width, height, depth),
      Offset3D(-width, height, depth),
      Offset3D(-width, height - wateHeight, -depth),
      Offset3D(width, height - wateHeight, -depth),
      Offset3D(width, height, -depth),
      Offset3D(-width, height, -depth),
    ];

    final rotatedWaterVerticesStock =
        waterVerticesStock.map((v) => rotateY(v, rotationAngle)).toList();
    final projectedWaterStock =
        rotatedWaterVerticesStock.map((v) => project3D(v, size)).toList();

    final waterFacesStock = [
      [0, 1, 2, 3],
      [4, 5, 6, 7],
      [0, 1, 5, 4],
      [3, 2, 6, 7],
      [0, 3, 7, 4],
      [1, 2, 6, 5],
    ];
    for (final face in waterFacesStock) {
      final path = Path()
        ..moveTo(
            projectedWaterStock[face[0]].dx, projectedWaterStock[face[0]].dy)
        ..lineTo(
            projectedWaterStock[face[1]].dx, projectedWaterStock[face[1]].dy)
        ..lineTo(
            projectedWaterStock[face[2]].dx, projectedWaterStock[face[2]].dy)
        ..lineTo(
            projectedWaterStock[face[3]].dx, projectedWaterStock[face[3]].dy)
        ..close();

      paint.style = PaintingStyle.fill;
      paint.color = stockColor;
      canvas.drawPath(path, paint);
    }

    final percentageText = "${(fillStockPercentage * 100).toInt()}%";
    final textPainter = TextPainter(
      text: TextSpan(
        text: "คลัง: $percentageText",
        style: Styles.black24(context),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final textX = size.width / 2 - textPainter.width / 2;
    final textY = size.height / 2 + height / 4 - textPainter.height / 2;
    textPainter.paint(canvas, Offset(textX, textY));
  }

  void _drawWithdrawAndStockSection(Canvas canvas, Size size, Paint paint) {
    // ใช้ logic เดิมใน if (isWithdraw) { ... }
    final stockHeight = (height * 2) * fillStockPercentage.clamp(0.0, 1.0);
    final withdrawHeight =
        (height * 2) * fillWithdrawPercentage.clamp(0.0, 1.0);

    // วาด withdraw + วาด stock ซ้อนกัน
    _drawSection(
      canvas,
      size,
      paint,
      color: withdrawColor,
      topY: height - (stockHeight + withdrawHeight),
      bottomY: height - stockHeight,
    );
    _drawSection(
      canvas,
      size,
      paint,
      color: stockColor,
      topY: height - stockHeight,
      bottomY: height,
    );

    // Draw label
    final percentageText = "${(fillStockPercentage * 100).toInt()}%";
    final percentageText2 =
        "${((fillStockPercentage + fillWithdrawPercentage) * 100).toInt()}%";
    final textPainter = TextPainter(
      text: TextSpan(
        text: "คลัง: $percentageText",
        style: Styles.black24(context),
      ),
      textDirection: TextDirection.ltr,
    );
    final textPainter2 = TextPainter(
      text: TextSpan(
        text: "เบิก + คลัง: $percentageText2",
        style: Styles.black24(context),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter2.layout();

    final textX = size.width / 2 - textPainter.width / 2;
    final textY = size.height / 2 + height / 4 - textPainter.height / 2;
    textPainter.paint(canvas, Offset(textX, textY + 20));
    textPainter2.paint(canvas, Offset(textX - 50, textY - 50));
  }

  void _drawThreeSection(Canvas canvas, Size size, Paint paint) {
    // แบ่งสามส่วน: stock, withdraw, free
    final stockHeight = (height * 2) * fillStockPercentage.clamp(0.0, 1.0);
    final withdrawHeight =
        (height * 2) * fillWithdrawPercentage.clamp(0.0, 1.0);
    final freeHeight = (height * 2) * fillFreePercentage.clamp(0.0, 1.0);

    double currentY = height - (stockHeight + withdrawHeight + freeHeight);

    // วาด free (บนสุด)
    _drawSection(
      canvas,
      size,
      paint,
      color: freeColor,
      topY: currentY,
      bottomY: currentY + freeHeight,
    );
    currentY += freeHeight;

    // วาด withdraw (กลาง)
    _drawSection(
      canvas,
      size,
      paint,
      color: withdrawColor,
      topY: currentY,
      bottomY: currentY + withdrawHeight,
    );
    currentY += withdrawHeight;

    // วาด stock (ล่างสุด)
    _drawSection(
      canvas,
      size,
      paint,
      color: stockColor,
      topY: currentY,
      bottomY: currentY + stockHeight,
    );

    // Draw labels
    final textPainter = TextPainter(
      text: TextSpan(
        text:
            "พื้นที่ว่าง: ${(fillFreePercentage * 100).toInt()}%\nเบิก: ${(fillWithdrawPercentage * 100).toInt()}%\nคลัง: ${(fillStockPercentage * 100).toInt()}%",
        style: Styles.black18(context),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    final textX = size.width / 2 - textPainter.width / 2;
    final textY = size.height / 2 - textPainter.height / 2;
    textPainter.paint(canvas, Offset(textX, textY));
  }

  void _drawSection(
    Canvas canvas,
    Size size,
    Paint paint, {
    required Color color,
    required double topY,
    required double bottomY,
  }) {
    // Helper วาดกล่อง section ย่อย
    final sectionVertices = [
      Offset3D(-width, topY, depth),
      Offset3D(width, topY, depth),
      Offset3D(width, bottomY, depth),
      Offset3D(-width, bottomY, depth),
      Offset3D(-width, topY, -depth),
      Offset3D(width, topY, -depth),
      Offset3D(width, bottomY, -depth),
      Offset3D(-width, bottomY, -depth),
    ];

    final rotatedSection =
        sectionVertices.map((v) => rotateY(v, rotationAngle)).toList();
    final projectedSection =
        rotatedSection.map((v) => project3D(v, size)).toList();

    final sectionFaces = [
      [0, 1, 2, 3],
      [4, 5, 6, 7],
      [0, 1, 5, 4],
      [3, 2, 6, 7],
      [0, 3, 7, 4],
      [1, 2, 6, 5],
    ];
    for (final face in sectionFaces) {
      final path = Path()
        ..moveTo(projectedSection[face[0]].dx, projectedSection[face[0]].dy)
        ..lineTo(projectedSection[face[1]].dx, projectedSection[face[1]].dy)
        ..lineTo(projectedSection[face[2]].dx, projectedSection[face[2]].dy)
        ..lineTo(projectedSection[face[3]].dx, projectedSection[face[3]].dy)
        ..close();
      paint.style = PaintingStyle.fill;
      paint.color = color;
      canvas.drawPath(path, paint);
    }
  }

  Offset3D rotateY(Offset3D vertex, double angle) {
    final double cosA = cos(angle);
    final double sinA = sin(angle);
    final double x = vertex.x * cosA - vertex.z * sinA;
    final double z = vertex.x * sinA + vertex.z * cosA;
    return Offset3D(x, vertex.y, z);
  }

  Offset project3D(Offset3D vertex, Size size) {
    final double perspective = 500;
    final double screenX = size.width / 2;
    final double screenY = size.height / 2;
    final scale = perspective / (perspective + vertex.z);
    final x = vertex.x * scale + screenX;
    final y = vertex.y * scale + screenY;
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Offset3D {
  final double x, y, z;

  Offset3D(this.x, this.y, this.z);
}

enum WaterRectLayoutType {
  stockOnly,
  withdrawAndStock,
  threeSection,
}

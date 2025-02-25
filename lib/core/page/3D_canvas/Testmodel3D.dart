import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '3D Rectangle with Partial Water',
      home: RectanglePainterPage(),
    );
  }
}

class RectanglePainterPage extends StatefulWidget {
  const RectanglePainterPage({Key? key}) : super(key: key);

  @override
  State<RectanglePainterPage> createState() => _RectanglePainterPageState();
}

class _RectanglePainterPageState extends State<RectanglePainterPage> {
  double _angle = 0.0; // Rotation angle

  void _rotateRectangle() {
    setState(() {
      _angle += pi / 8; // Increment angle by 22.5 degrees (π/8 radians)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: CustomPaint(
              size: const Size(300, 300),
              painter: RectanglePainter(angle: _angle),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _rotateRectangle,
            child: const Text("Rotate Rectangle"),
          ),
        ),
      ],
    );
  }
}

class RectanglePainter extends CustomPainter {
  final double angle;

  RectanglePainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Dimensions of the rectangle (width, height, depth)
    final double rectWidth = 150;
    final double rectHeight = 100;
    final double rectDepth = 50;

    // Rectangle vertices in 3D
    final vertices = [
      // Front face
      Offset3D(-rectWidth, -rectHeight, rectDepth), // Top-left front
      Offset3D(rectWidth, -rectHeight, rectDepth), // Top-right front
      Offset3D(rectWidth, rectHeight, rectDepth), // Bottom-right front
      Offset3D(-rectWidth, rectHeight, rectDepth), // Bottom-left front
      // Back face
      Offset3D(-rectWidth, -rectHeight, -rectDepth), // Top-left back
      Offset3D(rectWidth, -rectHeight, -rectDepth), // Top-right back
      Offset3D(rectWidth, rectHeight, -rectDepth), // Bottom-right back
      Offset3D(-rectWidth, rectHeight, -rectDepth), // Bottom-left back
    ];

    // Apply rotation to each vertex
    final rotatedVertices = vertices.map((v) => rotateY(v, angle)).toList();

    // Perspective projection
    final projected = rotatedVertices.map((v) => project3D(v, size)).toList();

    // Draw edges
    void drawEdge(int i, int j, Color color) {
      paint.color = color;
      canvas.drawLine(projected[i], projected[j], paint);
    }

    // Draw rectangle borders
    final borderColor = Colors.grey;

    // Front face (border)
    drawEdge(0, 1, borderColor);
    drawEdge(1, 2, borderColor);
    drawEdge(2, 3, borderColor);
    drawEdge(3, 0, borderColor);

    // Back face (border)
    drawEdge(4, 5, borderColor);
    drawEdge(5, 6, borderColor);
    drawEdge(6, 7, borderColor);
    drawEdge(7, 4, borderColor);

    // Connecting edges (border)
    drawEdge(0, 4, borderColor);
    drawEdge(1, 5, borderColor);
    drawEdge(2, 6, borderColor);
    drawEdge(3, 7, borderColor);

    // Draw water (15% of the volume)
    final double waterHeight = (rectHeight * 2) * 0.15;

    // Water vertices (only the bottom 15%)
    final waterVertices = [
      Offset3D(-rectWidth, rectHeight - waterHeight,
          rectDepth), // Front-left water top
      Offset3D(rectWidth, rectHeight - waterHeight,
          rectDepth), // Front-right water top
      Offset3D(rectWidth, rectHeight, rectDepth), // Front-right bottom
      Offset3D(-rectWidth, rectHeight, rectDepth), // Front-left bottom
      Offset3D(-rectWidth, rectHeight - waterHeight,
          -rectDepth), // Back-left water top
      Offset3D(rectWidth, rectHeight - waterHeight,
          -rectDepth), // Back-right water top
      Offset3D(rectWidth, rectHeight, -rectDepth), // Back-right bottom
      Offset3D(-rectWidth, rectHeight, -rectDepth), // Back-left bottom
    ];

    // Apply rotation to water vertices
    final rotatedWaterVertices =
        waterVertices.map((v) => rotateY(v, angle)).toList();
    final projectedWater =
        rotatedWaterVertices.map((v) => project3D(v, size)).toList();

    final waterColor = Colors.blue.withOpacity(0.5);
    final waterFaces = [
      [0, 1, 2, 3], // Front face
      [4, 5, 6, 7], // Back face
      [0, 1, 5, 4], // Top face
      [3, 2, 6, 7], // Bottom face
      [0, 3, 7, 4], // Left face
      [1, 2, 6, 5], // Right face
    ];

    for (final face in waterFaces) {
      final path = Path()
        ..moveTo(projectedWater[face[0]].dx, projectedWater[face[0]].dy)
        ..lineTo(projectedWater[face[1]].dx, projectedWater[face[1]].dy)
        ..lineTo(projectedWater[face[2]].dx, projectedWater[face[2]].dy)
        ..lineTo(projectedWater[face[3]].dx, projectedWater[face[3]].dy)
        ..close();

      paint.style = PaintingStyle.fill;
      paint.color = waterColor;
      canvas.drawPath(path, paint);
    }

    // Draw "15%" text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: "15%",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textX = size.width / 2 - textPainter.width / 2;
    final textY = size.height / 2 + rectHeight / 4 - textPainter.height / 2;

    textPainter.paint(canvas, Offset(textX, textY));
  }

  Offset3D rotateY(Offset3D vertex, double angle) {
    // Rotate around the Y-axis
    final double cosA = cos(angle);
    final double sinA = sin(angle);

    final double x = vertex.x * cosA - vertex.z * sinA;
    final double z = vertex.x * sinA + vertex.z * cosA;

    return Offset3D(x, vertex.y, z);
  }

  Offset project3D(Offset3D vertex, Size size) {
    // Projection constants
    final double perspective = 500;
    final double screenX = size.width / 2;
    final double screenY = size.height / 2;

    // Apply perspective projection
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

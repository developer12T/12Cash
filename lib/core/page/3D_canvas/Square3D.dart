import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '3D Rotating Cube',
      home: const CubePainterPage(),
    );
  }
}

class CubePainterPage extends StatefulWidget {
  const CubePainterPage({Key? key}) : super(key: key);

  @override
  State<CubePainterPage> createState() => _CubePainterPageState();
}

class _CubePainterPageState extends State<CubePainterPage>
    with SingleTickerProviderStateMixin {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("3D Rotating Cube")),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(100, 100),
              painter: CubePainter(angle: _controller.value * 2 * pi),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CubePainter extends CustomPainter {
  final double angle;

  CubePainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Cube vertices in 3D
    final double cubeSize = 100;
    final vertices = [
      // Front face
      Offset3D(-cubeSize, -cubeSize, cubeSize),
      Offset3D(cubeSize, -cubeSize, cubeSize),
      Offset3D(cubeSize, cubeSize, cubeSize),
      Offset3D(-cubeSize, cubeSize, cubeSize),
      // Back face
      Offset3D(-cubeSize, -cubeSize, -cubeSize),
      Offset3D(cubeSize, -cubeSize, -cubeSize),
      Offset3D(cubeSize, cubeSize, -cubeSize),
      Offset3D(-cubeSize, cubeSize, -cubeSize),
    ];

    // Apply rotation to each vertex
    final rotatedVertices = vertices.map((v) => rotateY(v, angle)).toList();

    // Perspective projection
    final projected = rotatedVertices.map((v) => project3D(v, size)).toList();

    // Draw edges
    void drawEdge(int i, int j) {
      canvas.drawLine(projected[i], projected[j], paint);
    }

    // Front face
    drawEdge(0, 1);
    drawEdge(1, 2);
    drawEdge(2, 3);
    drawEdge(3, 0);

    // Back face
    drawEdge(4, 5);
    drawEdge(5, 6);
    drawEdge(6, 7);
    drawEdge(7, 4);

    // Connecting edges
    drawEdge(0, 4);
    drawEdge(1, 5);
    drawEdge(2, 6);
    drawEdge(3, 7);
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

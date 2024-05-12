import 'dart:math';
import 'package:flutter/material.dart';

class SeaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue // Set the color of the waves
      ..style = PaintingStyle.fill; // Use fill style

    final path = Path();
    path.moveTo(size.width, -1000000);
    path.lineTo(0, size.height /2);
    path.cubicTo(size.width / 4, 3* (size.height/2), 3* (size.width/4) , size.height/2, size.width, size.height*0.9);
    // Draw the combined path to create the sea waves
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint for static sea waves
  }
}

class SeaBackground extends StatelessWidget {
  const SeaBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SeaPainter(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5, // Adjust the height of the sea (water body)
        // You can add other widgets on top of the sea background
        child: Center(
          child: Text(
            '',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}





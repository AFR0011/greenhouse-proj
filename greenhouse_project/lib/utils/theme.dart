/// Theme data for the application
library;

import 'package:flutter/material.dart';

final ThemeData theme = ThemeData(
  colorScheme: ColorScheme(
    primary: Colors.green[800]!,
    secondary: Colors.green[400]!,
    surface: Colors.green[200]!,
    // background: Colors.green[200]!,
    background: Colors.white,
    error: Colors.red,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
  appBarTheme: AppBarTheme(
    color: Colors.green[800]!,
    foregroundColor: Colors.black,
    titleTextStyle: const TextStyle(color: Colors.black),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.green[800]!,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.black.withOpacity(0.5),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Colors.black),
    bodyLarge: TextStyle(color: Colors.black),
  ),
);

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Gradient
    final gradient = LinearGradient(
      colors: [Colors.green, Colors.blue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Path for the wave
    final path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.5, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();

    // Draw gradient wave
    canvas.drawPath(path, paint);

    // Draw image pattern wave
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class WavePainter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * .95);
    path.quadraticBezierTo(
        size.width * 0.35, size.height, size.width * 0.55, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.5, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class WavePainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * .95);

    path.quadraticBezierTo(
        size.width, size.height * 1.5, size.width * 1.5, size.height * 0.95);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

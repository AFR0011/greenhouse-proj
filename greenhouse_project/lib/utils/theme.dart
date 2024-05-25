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
    // Add more text styles as needed
  ),
);

// Define the color palette
const Color primaryGreen = Color(0xFF4CAF50);
const Color darkGreen = Color(0xFF388E3C);
const Color lightGreen = Color(0xFFC8E6C9);
const Color black = Color(0xFF000000);
const Color white = Color(0xFFFFFFFF);
const Color gray = Color(0xFF757575);
const Color darkGray = Color(0xFF424242);
const Color lightGray = Color(0xFFBDBDBD);
const Color red = Color.fromARGB(0, 216, 16, 16);

// Light Theme
final ThemeData lightTheme = ThemeData(
  colorScheme: const ColorScheme(
    primary: primaryGreen,
    secondary: white,
    surface: lightGreen,
    background: lightGreen,
    error: red,
    onPrimary: white,
    onSecondary: black,
    onSurface: black,
    onBackground: black,
    onError: white,
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryGreen,
    foregroundColor: white,
    titleTextStyle:
        TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: primaryGreen,
    selectedItemColor: white,
    unselectedItemColor: white.withOpacity(0.5),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: black),
    titleLarge:
        TextStyle(color: black, fontSize: 20, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: black, fontSize: 16),
    bodyMedium: TextStyle(color: black, fontSize: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGreen,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: primaryGreen,
  ),
);

// Dark Theme
final ThemeData darkTheme = ThemeData(
  colorScheme: const ColorScheme(
    primary: primaryGreen,
    secondary: lightGreen,
    surface: black,
    background: black,
    error: red,
    onPrimary: white,
    onSecondary: black,
    onSurface: white,
    onBackground: white,
    onError: white,
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: darkGreen,
    foregroundColor: white,
    titleTextStyle:
        TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: darkGreen,
    selectedItemColor: white,
    unselectedItemColor: white.withOpacity(0.5),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: white),
    bodyLarge: TextStyle(color: white),
    titleLarge:
        TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: white, fontSize: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGreen,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: primaryGreen,
  ),
);



class WavePainter extends CustomPainter {
   final image;

  WavePainter(this.image);

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

    // Image pattern
    if (image != null) {
      final imagePaint = Paint()
        ..shader = ImageShader(
          image,
          TileMode.repeated,
          TileMode.repeated,
          Matrix4.identity().scaled(size.width / image.width, size.height / image.height).storage,
        );

      // Draw image pattern wave
      canvas.drawPath(path, imagePaint);
    }
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
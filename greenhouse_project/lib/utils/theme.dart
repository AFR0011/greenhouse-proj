/// Theme data for the application
library;

import 'package:flutter/material.dart';

final ThemeData theme = ThemeData(
  colorScheme: ColorScheme(
    primary: Colors.green[800]!,
    secondary: Colors.green[800]!,
    surface: Colors.green[800]!,
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

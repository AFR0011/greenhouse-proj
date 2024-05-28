/// Buttons to be used throughout the application
library;

import 'package:flutter/material.dart';
import 'package:greenhouse_project/utils/text_styles.dart';

class GreenElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GreenElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Adjust as needed
          ),
        ),
        child: Text(text, style: buttonTextStyle),
      ),
    );
  }
}

class RedElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const RedElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Adjust as needed
          ),
        ),
        child: Text(text, style: buttonTextStyle),
      ),
    );
  }
}

class WhiteElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const WhiteElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Adjust as needed
          ),
        ),
        child: Text(text, style: lightButtonTextStyle),
      ),
    );
  }
}

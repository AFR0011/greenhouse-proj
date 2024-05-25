import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class BoxLink extends StatefulWidget {
  final String text;
  final String imgPath;
  final BuildContext context;
  final dynamic pageRoute;

  const BoxLink(
      {super.key,
      required this.text,
      required this.imgPath,
      required this.context,
      required this.pageRoute});

  @override
  _BoxLinkState createState() => _BoxLinkState();
}

class _BoxLinkState extends State<BoxLink> {
  late Color containerColor;

  @override
  void initState() {
    super.initState();
    containerColor =
        theme.colorScheme.background; // Initialize with primary color
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData customTheme = theme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: containerColor.withOpacity(0.2),
        border: Border.all(width: 2, color: Colors.white30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
        child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [Colors.white60, Colors.white10],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(width: 2, color: Colors.white10),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => widget.pageRoute));
            },
            onHover: (isHover) {
              setState(() {
                containerColor = isHover
                    ? customTheme.colorScheme.secondary
                    : customTheme.colorScheme.primary;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(2, 10, 2, 2),
                  child: Image.asset(
                    widget.imgPath, // Display the image
                    height: 160,
                    width: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 4, 4),
                  child: Center(
                    child: Text(
                      widget.text,
                      style: subheadingTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

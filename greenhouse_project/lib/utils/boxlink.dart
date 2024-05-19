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
    containerColor = theme.colorScheme.primary; // Initialize with primary color
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData customTheme = theme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: containerColor,
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
                height: 170,
                width: 170,
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
    );
  }
}

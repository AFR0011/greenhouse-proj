import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greenhouse_project/pages/login.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

// ignore: must_be_immutable
class SettingsPage extends StatefulWidget {
  UserCredential? userCredential;

  SettingsPage({super.key, required this.userCredential});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Define custom theme
  final ThemeData customTheme = theme;

  // Sign user out
  Future _signOut() async {
    widget.userCredential = null;
    await FirebaseAuth.instance.signOut().then(
          (value) => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginPage())),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: customTheme,
        home: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Image.asset(
                    "lib/utils/Icons/Left Arrow.png",
                    scale: 3,
                  )),
              title: const Padding(
                padding: EdgeInsets.fromLTRB(70, 0, 0, 0),
                child: Text(
                  "Settings",
                  style: headingTextStyle,
                ),
              )),
          body: Column(
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      "",
                      style: subheadingTextStyle,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 25, 0), child: null),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child:
                    GreenElevatedButton(text: "Sign Out", onPressed: _signOut),
              )
            ],
          ),
        ));
  }
}

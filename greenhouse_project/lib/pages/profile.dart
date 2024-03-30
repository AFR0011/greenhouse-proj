/// TO-DO:
/// * Connect to database and fetch actual user data
/// * Make "edit" button functional
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class ProfilePage extends StatefulWidget {
  final UserCredential userCredential;

  const ProfilePage({super.key, required this.userCredential});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Define custom theme
  final ThemeData customTheme = theme;

  // Controller for input text field
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Define variables for user information
  late String _userName = "";

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  // Retrieve user information from Firebase
  Future<void> _getUserInfo() async {
    String? email = widget.userCredential.user?.email;
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userQuery.docs.isNotEmpty) {
      DocumentSnapshot userSnapshot = userQuery.docs.first;
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      setState(() {
        _userName = userData?['name'] ?? 'Unknown';
      });
    }
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
                  "Profile",
                  style: headingTextStyle,
                ),
              )),
          body: Column(
            children: [
              const Center(child: Text("PROFILE PIC")),
              const Text("Name"),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.green[400],
                      labelText: _userName,
                      border: const OutlineInputBorder(),
                    )),
              ),
              const Text("Email"),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.green[400],
                      labelText: widget.userCredential.user?.email,
                      border: const OutlineInputBorder(),
                    )),
              ),
              const Text("Password"),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.green[400],
                      labelText: '********',
                      border: const OutlineInputBorder(),
                    )),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: GreenElevatedButton(text: "Edit", onPressed: () {}))
            ],
          ),
        ));
  }
}

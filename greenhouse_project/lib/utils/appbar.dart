/// Create the main app bar viewed in the main 5 pages
library;

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:greenhouse_project/pages/profile.dart";
import "package:greenhouse_project/pages/settings.dart";
import "package:greenhouse_project/utils/text_styles.dart";
import "package:greenhouse_project/utils/theme.dart";

import 'package:flutter/material.dart';

AppBar createMainAppBar(BuildContext context, UserCredential userCredential,
    DocumentReference userReference, String title) {
  return AppBar(
    // Hide back button
    flexibleSpace: Container(
      decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                ),
                
            ),
    ),
    automaticallyImplyLeading: false,
    toolbarHeight: 75,
    centerTitle: true,
   title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Pacifico', // use a custom font
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black54,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
    leading: IconButton(
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsPage(
              userCredential: userCredential,
            ),
          ),
        ),
        icon: const Icon(Icons.settings_outlined, size: 50, color: Colors.white60),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePage(
                      userCredential: userCredential,
                      userReference: userReference,
                    ))),
        icon: const Icon(Icons.supervised_user_circle_outlined, size: 50, color: Colors.white60),
      )
      
    ],
    shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30.0),
            ),
          ),
          elevation: 10.0,
  );
}

AppBar createAltAppbar(BuildContext context, String title) {
  return AppBar(
    flexibleSpace: Container(
      decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                ),
                
            ),
    ),
    automaticallyImplyLeading: false,
    toolbarHeight: 75,
    centerTitle: true,
   title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Pacifico', // use a custom font
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black54,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
    
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30.0),
            ),
          ),
          elevation: 10.0,
  );

}

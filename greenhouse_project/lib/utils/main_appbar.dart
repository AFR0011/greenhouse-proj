/// Create the main app bar viewed in the main 5 pages
library;

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:greenhouse_project/pages/profile.dart";
import "package:greenhouse_project/pages/settings.dart";

AppBar createMainAppBar(BuildContext context, UserCredential userCredential,
    DocumentReference userReference) {
  return AppBar(
    // Hide back button
    automaticallyImplyLeading: false,
    toolbarHeight: 75,
    leading: IconButton(
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SettingsPage(
                    userCredential: userCredential,
                  ))),
      icon: const Icon(Icons.settings_outlined, size: 55),
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
        icon: Image.asset("lib/utils/Icons/Profile.png"),
      )
    ],
  );
}

/// Greenhouse page - contains links to the following subpages:
/// - Plants
/// - Programs
/// - Equipment
library;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/firebase_options.dart';
import 'package:greenhouse_project/pages/equipment.dart';
import 'package:greenhouse_project/pages/plants.dart';
import 'package:greenhouse_project/pages/programs.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/greenhouse_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/theme.dart';

// Web VAPID key for Firebase Cloud Messaging
const String webVapidKey =
    "BKWvS-G0BOBMCAmBJVz63de5kFb5R2-OVxrM_ulKgCoqQgVXSY8FqQp7QM5UoC5S9hKs5crmzhVJVyyi_sYDC9I";

/// Main widget for the Greenhouse Page
class GreenhousePage extends StatelessWidget {
  final UserCredential userCredential; // User authentication credentials

  const GreenhousePage({super.key, required this.userCredential});

  @override
  Widget build(BuildContext context) {
    // Provide Cubits for state management
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FooterNavCubit(),
        ),
        BlocProvider(
          create: (context) => NotificationsCubit(userCredential),
        ),
        BlocProvider(
          create: (context) => UserInfoCubit(),
        ),
        BlocProvider(
          create: (context) => ReadingsCubit(),
        ),
      ],
      child: _GreenhousePageContent(userCredential: userCredential),
    );
  }
}

/// Widget for the main content of the Greenhouse Page
class _GreenhousePageContent extends StatefulWidget {
  final UserCredential userCredential; // User authentication credentials

  const _GreenhousePageContent({required this.userCredential});

  @override
  State<_GreenhousePageContent> createState() => _GreenhousePageContentState();
}

/// State class for the Greenhouse Page Content
class _GreenhousePageContentState extends State<_GreenhousePageContent> {
  late String _userRole = ""; // User role
  late DocumentReference _userReference; // Reference to user document

  final ThemeData customTheme = theme; // Custom theme for the page
  final int _selectedIndex = 3; // Index of selected item in the footer nav

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeUserInfo(); // Initialize user information
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FooterNavCubit, int>(
      listener: (context, state) {
        navigateToPage(context, state, _userRole, widget.userCredential,
            userReference: _userReference);
      },
      child: BlocBuilder<UserInfoCubit, HomeState>(
        builder: (context, state) {
          if (state is UserInfoLoading) {
            // Show loading indicator while fetching user info
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UserInfoLoaded) {
            // Display content when user info is loaded
            _userRole = state.userRole;
            _userReference = state.userReference;
            return Theme(data: customTheme, child: _createGreenhousePage());
          } else if (state is UserInfoError) {
            // Show error if there's an issue with user info
            return Center(child: Text('Error: ${state.errorMessage}'));
          } else {
            return const Center(child: Text('Unexpected State'));
          }
        },
      ),
    );
  }

  // Function to navigate to details page
  void _navigateToDetailsPage(Widget pageWidget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => pageWidget,
      ),
    );
  }

  // Function to create a subheading row with a details button
  Widget _buildSubheadingRow(
      String subheading, Widget pageWidget, Color color, IconData icon) {
    return Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 4.0,
        margin: EdgeInsets.only(bottom: 16.0),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30.0,
            ),
          ),
          title: Text(
            subheading,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              _navigateToDetailsPage(pageWidget);
            },
            child: Text('Details'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ));
  }

  /// Creates the main content of the greenhouse page.
  Widget _createGreenhousePage() {
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);

    return Scaffold(
        appBar: createMainAppBar(
            context, widget.userCredential, _userReference, "Greenhouse"),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.lightBlueAccent.shade100.withOpacity(0.6),
                Colors.teal.shade100.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: DecorationImage(
              image: AssetImage('lib/utils/Icons/leaf_pat.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.05),
                BlendMode.dstATop,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubheadingRow(
                    "Plant Status",
                    PlantsPage(
                      userCredential: widget.userCredential,
                      userReference: _userReference,
                    ),
                    Colors.greenAccent,
                    Icons.local_florist,
                  ),
                  _buildSubheadingRow(
                    "Active Programs",
                    ProgramsPage(userCredential: widget.userCredential),
                    Colors.blueAccent,
                    Icons.play_circle_fill,
                  ),
                  _buildSubheadingRow(
                    "Equipment Status",
                    EquipmentPage(userCredential: widget.userCredential),
                    Colors.orangeAccent,
                    Icons.build,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade700,
                  Colors.teal.shade400,
                  Colors.blue.shade300
                ],
                stops: [0.2, 0.5, 0.9],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child:
                    createFooterNav(_selectedIndex, footerNavCubit, _userRole)),
          ),
        ));
  }

  // Initialize user info including FCM token
  Future<void> _initializeUserInfo() async {
    try {
      if (DefaultFirebaseOptions.currentPlatform !=
          DefaultFirebaseOptions.android) {
        context.read<UserInfoCubit>().getUserInfo(widget.userCredential, null);
      } else {
        String? deviceFcmToken =
            await FirebaseMessaging.instance.getToken(vapidKey: webVapidKey);
        if (mounted) {
          context
              .read<UserInfoCubit>()
              .getUserInfo(widget.userCredential, deviceFcmToken);
        }
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }
}

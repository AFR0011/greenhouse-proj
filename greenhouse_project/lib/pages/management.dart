/// Management page - links to subpages: workers and tasks
library;

// Import required packages
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/firebase_options.dart';
import 'package:greenhouse_project/pages/logs.dart';
import 'package:greenhouse_project/pages/tasks.dart';
import 'package:greenhouse_project/pages/employees.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/management_cubit.dart';
import 'package:greenhouse_project/utils/boxlink.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/theme.dart';

// Firebase Web Vapid Key
const String webVapidKey =
    "BKWvS-G0BOBMCAmBJVz63de5kFb5R2-OVxrM_ulKgCoqQgVXSY8FqQp7QM5UoC5S9hKs5crmzhVJVyyi_sYDC9I";

/// Management Page Widget
class ManagementPage extends StatelessWidget {
  final UserCredential userCredential; // User authentication credentials

  const ManagementPage({super.key, required this.userCredential});

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
          create: (context) => ManageEmployeesCubit(userCredential),
        ),
      ],
      child: _ManagementPageContent(userCredential: userCredential),
    );
  }
}

/// Management Page Content Stateful Widget
class _ManagementPageContent extends StatefulWidget {
  final UserCredential userCredential; // User authentication credentials

  const _ManagementPageContent({required this.userCredential});

  @override
  State<_ManagementPageContent> createState() => _ManagementPageState();
}

/// Management Page State
class _ManagementPageState extends State<_ManagementPageContent> {
  late String _userRole = ""; // User role
  late DocumentReference _userReference; // User reference in Firestore

  final ThemeData customTheme = theme; // Custom theme

  final TextEditingController _textController =
      TextEditingController(); // Text controller

  final int _selectedIndex = 0; // Index of footer nav selection

  @override
  void dispose() {
    _textController.dispose(); // Dispose text controller
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeUserInfo(); // Initialize user info
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FooterNavCubit, int>(
      listener: (context, state) {
        // Navigate to page based on footer nav selection
        navigateToPage(context, state, _userRole, widget.userCredential,
            userReference: _userReference);
      },
      child: BlocBuilder<UserInfoCubit, HomeState>(
        builder: (context, state) {
          if (state is UserInfoLoading) {
            return const Center(
              child: CircularProgressIndicator(), // Show loading screen
            );
          } else if (state is UserInfoLoaded) {
            _userRole = state.userRole; // Assign user info
            _userReference = state.userReference;

            return Theme(
                data: customTheme,
                child: _createManagementPage()); // Create management page
          } else if (state is UserInfoError) {
            return Center(
                child: Text('Error: ${state.errorMessage}')); // Show error
          } else {
            return const Center(
              child: Text('Unexpected state'), // Unexpected state
            );
          }
        },
      ),
    );
  }

  /// Create Management Page Widget
  Widget _createManagementPage() {
    final footerNavCubit =
        BlocProvider.of<FooterNavCubit>(context); // Get footer nav cubit
    final pages = [
      // Pages list
      {
        'route': _userRole == "admin"
            ? LogsPage(userCredential: widget.userCredential)
            : TasksPage(
                userCredential: widget.userCredential,
                userReference: _userReference,
              ),
        "title": _userRole == "admin" ? "Logs" : "Tasks",
        "icon": _userRole == "admin"
            ? "lib/utils/Icons/log.png"
            : "lib/utils/Icons/tasks.png",
      },
      {
        'route': EmployeesPage(userCredential: widget.userCredential),
        "title": "Employees",
        "icon": "lib/utils/Icons/worker.png"
      }
    ] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: createMainAppBar(context, widget.userCredential, _userReference,
          "Management"), // Main appbar

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
            image: const AssetImage('lib/utils/Icons/leaf_pat.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.05),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      mainAxisExtent: 250),
                  shrinkWrap: true,
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: BoxLink(
                              text: pages[index]["title"],
                              imgPath: pages[index]["icon"],
                              context: context,
                              pageRoute: pages[index]["route"]),
                        ));
                  }),
            ),
          ]),
        ),
      ),

      bottomNavigationBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade700,
                  Colors.teal.shade400,
                  Colors.blue.shade300
                ],
                stops: const [0.2, 0.5, 0.9],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  // Footer nav bar shadow
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // Changes position of shadow
                ),
              ],
            ),
            child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child: createFooterNav(_selectedIndex, footerNavCubit,
                    _userRole)), // Create footer nav bar
          )),
    );
  }

  /// Initialize User Info
  Future<void> _initializeUserInfo() async {
    try {
      if (DefaultFirebaseOptions.currentPlatform !=
          DefaultFirebaseOptions.android) {
        context.read<UserInfoCubit>().getUserInfo(widget.userCredential,
            null); // Get user info for non-Android platforms
      } else {
        String? deviceFcmToken = await FirebaseMessaging.instance
            .getToken(vapidKey: webVapidKey); // Get FCM token for Android
        if (mounted) {
          context.read<UserInfoCubit>().getUserInfo(widget.userCredential,
              deviceFcmToken); // Get user info with FCM token
        }
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }
}

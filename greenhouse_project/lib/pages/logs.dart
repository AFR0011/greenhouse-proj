/// Logs page - notifications, welcome message, and search
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/firebase_options.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/logs_cubit.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/theme.dart';

// Web VAPID Key for Firebase Cloud Messaging
const String webVapidKey =
    "BKWvS-G0BOBMCAmBJVz63de5kFb5R2-OVxrM_ulKgCoqQgVXSY8FqQp7QM5UoC5S9hKs5crmzhVJVyyi_sYDC9I";

/// Logs Page Widget
class LogsPage extends StatelessWidget {
  final UserCredential userCredential; // User authentication credentials

  const LogsPage({Key? key, required this.userCredential}) : super(key: key);

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
          create: (context) => LogsCubit(),
        ),
      ],
      child: _LogsPageContent(userCredential: userCredential),
    );
  }
}

/// Logs Page Content Widget
class _LogsPageContent extends StatefulWidget {
  final UserCredential userCredential; // User authentication credentials

  const _LogsPageContent({required this.userCredential});

  @override
  State<_LogsPageContent> createState() => _LogsPageContentState();
}

/// State class for Logs Page Content
class _LogsPageContentState extends State<_LogsPageContent> {
  final ThemeData customTheme = theme; // Custom theme for the page

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeUserInfo(); // Initialize user info upon page load
  }

  @override
  Widget build(BuildContext context) {
    // BlocListener for handling footer nav events
    return BlocBuilder<UserInfoCubit, HomeState>(
      builder: (context, state) {
        // Show "loading screen" if processing user info
        if (state is UserInfoLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // Show content once user info is loaded
        else if (state is UserInfoLoaded) {
          // Assign user info to local variables

          // Function call to build page
          return Theme(data: customTheme, child: _createLogsPage());
        }
        // Show error if there is an issues with user info
        else if (state is UserInfoError) {
          return Center(child: Text('Error: ${state.errorMessage}'));
        }
        // If somehow state doesn't match predefined states;
        // never happens; but, anything can happen
        else {
          return const Center(child: Text('Unexpected State'));
        }
      },
    );
  }

  /// Create Logs Page Function
  Widget _createLogsPage() {
    // Page content
    return Scaffold(
      // Main appbar (header)
      appBar: createAltAppbar(context, "Logs"),

      // Call function to build notifications list
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
          child: _buildLogs()),
    );
  }

  /// Build Logs Widget
  Widget _buildLogs() {
    return BlocBuilder<LogsCubit, LogsState>(
      builder: (context, state) {
        // Show "loading screen" if processing notification state
        if (state is LogsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        // Show equipment status once notification state is loaded
        else if (state is LogsLoaded) {
          List<LogsData> logsList = state.logs; // List of notifications
          // Display nothing if no notifications
          if (logsList.isEmpty) {
            return const Center(child: Text("No Logs..."));
          }
          // Display notifications
          else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: logsList.length,
                itemBuilder: (context, index) {
                  LogsData log = logsList[index]; // Notification data
                  // Notification message
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 4.0,
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_alert_outlined),
                      ),
                      title: Text("${log.action} ${log.description} "),
                    ),
                  );
                },
              ),
            );
          }
        }
        // Show error message once an error occurs
        else if (state is LogsError) {
          return Center(child: Text('Error: ${state.error}'));
        }
        // If the state is not any of the predefined states;
        // never happens; but, anything can happen
        else {
          return const Center(child: Text('Unexpected State'));
        }
      },
    );
  }

  /// Initialize User Info Function
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

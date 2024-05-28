/// Logs page - notifications, welcome message, and search
///
/// TODO:
/// - Add delete notification option (individual and all)
///
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/logs_cubit.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/theme.dart';

class LogsPage extends StatelessWidget {
  final UserCredential userCredential; // user auth credentials

  const LogsPage({super.key, required this.userCredential});

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

class _LogsPageContent extends StatefulWidget {
  final UserCredential userCredential; // user auth credentials

  const _LogsPageContent({required this.userCredential});

  @override
  State<_LogsPageContent> createState() => _LogsPageContentState();
}

// Main page content goes here
class _LogsPageContentState extends State<_LogsPageContent> {
  // Custom theme
  final ThemeData customTheme = theme;

  // Text controllers

  // Dispose (destructor)
  @override
  void dispose() {
    super.dispose();
  }

  // InitState - get user info state to check authentication later
  @override
  void initState() {
    context.read<UserInfoCubit>().getUserInfo(widget.userCredential);
    context.read<NotificationsCubit>().initNotifications();
    super.initState();
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

  // Create notifications page function
  Widget _createLogsPage() {
    // Page content
    return Scaffold(
      // Main appbar (header)
      appBar: createAltAppbar(context, "Logs"),

      // Call function to build notificaitons list
      body: _buildLogs(),
    );
  }

  Widget _buildLogs() {
    return BlocBuilder<LogsCubit, LogsState>(
      builder: (context, state) {
        // Show "loading screen" if processing notification state
        if (state is LogsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        // Show equipment status once notification state is loaded
        else if (state is LogsLoaded) {
          List<LogsData> logsList = state.logs; // notifications list
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
                  LogsData log = logsList[index]; // notification data
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
}

/// Home page - notifications, welcome message, and search
///
/// TODO:
/// - Add delete notification option (individual and all)
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/pages/login.dart';
import 'package:greenhouse_project/services/cubit/auth_cubit.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class HomePage extends StatelessWidget {
  final UserCredential userCredential; // user auth credentials

  const HomePage({super.key, required this.userCredential});

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
      ],
      child: _EquipmentPageContent(userCredential: userCredential),
    );
  }
}

class _EquipmentPageContent extends StatefulWidget {
  final UserCredential userCredential; // user auth credentials

  const _EquipmentPageContent({required this.userCredential});

  @override
  State<_EquipmentPageContent> createState() => _EquipmentPageContentState();
}

// Main page content goes here
class _EquipmentPageContentState extends State<_EquipmentPageContent> {
  // User info local variables
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;
  late bool _enabled;

  // Custom theme
  final ThemeData customTheme = theme;

  // Text controllers
  final TextEditingController _searchController = TextEditingController();

  // Index of footer nav selection
  final int _selectedIndex = 2;

  // Dispose (destructor)
  @override
  void dispose() {
    _searchController.dispose();
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
    return BlocListener<FooterNavCubit, int>(
      listener: (context, state) {
        navigateToPage(context, state, _userRole, widget.userCredential,
            userReference: _userReference);
      },
      // BlocBuilder for user info
      child: BlocBuilder<UserInfoCubit, HomeState>(
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
            _userRole = state.userRole;
            _userName = state.userName;
            _userReference = state.userReference;
            _enabled = state.enabled;

            // Get device token for notifications

            // Call function to create home page
            if (_enabled) {
              return Theme(data: customTheme, child: _createHomePage());
            } else {
              return Center(
                  child: Theme(
                      data: customTheme, child: _createHomePageDisabled()));
            }
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
      ),
    );
  }

  // Create greenhouse page function
  Widget _createHomePage() {
    // Get instance of footer nav cubit from main context
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);

    // Page content
    return Scaffold(
      // Main appbar (header)
      appBar: createMainAppBar(context, widget.userCredential, _userReference),

      // Call function to build notificaitons list
      body: _buildNotifications(),

      // Footer nav bar
      bottomNavigationBar:
          createFooterNav(_selectedIndex, footerNavCubit, _userRole),
    );
  }

  Widget _buildNotifications() {
    return Column(
      children: [
        // Welcome message
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Center(
              child:
                  Text("Welcome Back, $_userName!", style: headingTextStyle)),
        ),

        // Notifications subheading
        SizedBox(
          width: MediaQuery.of(context).size.width - 20,
          child: const Text(
            "Notifications",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),

        // BlocBuilder for notifications
        BlocBuilder<NotificationsCubit, HomeState>(
          builder: (context, state) {
            // Show "loading screen" if processing notification state
            if (state is NotificationsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            // Show equipment status once notification state is loaded
            else if (state is NotificationsLoaded) {
              List<NotificationData> notificationsList =
                  state.notifications; // notifications list
              // Display nothing if no notifications
              if (notificationsList.isEmpty) {
                return const Center(child: Text("No Notifications..."));
              }
              // Display notifications
              else {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: notificationsList.length,
                  itemBuilder: (context, index) {
                    NotificationData notification =
                        notificationsList[index]; // notification data
                    // Notification message
                    return ListTile(
                      title: Text(notification.message),
                    );
                  },
                );
              }
            }
            // Show error message once an error occurs
            else if (state is NotificationsError) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }
            // If the state is not any of the predefined states;
            // never happens; but, anything can happen
            else {
              return const Center(child: Text('Unexpected State'));
            }
          },
        ),
      ],
    );
  }

  _createHomePageDisabled() {
    UserInfoCubit userInfoCubit = context.read<UserInfoCubit>();
    AuthCubit authCubit = context.read<AuthCubit>();

    // Page content
    return Scaffold(
      // Main appbar (header)
      appBar: AppBar(),

      // Call function to build notificaitons list
      body: Column(
        children: [
          const Text(
              "Your account has been disabled by the greenhouse administration.\n If you don't work here anymore, please delete your account."),
          Row(
            children: [
              GreenElevatedButton(
                  text: "Delete Account",
                  onPressed: () {
                    userInfoCubit.deleteUserAccount(
                        widget.userCredential, _userReference);
                    showDialog(
                        context: context,
                        builder: (context) => Dialog(
                              child: Column(
                                children: [
                                  const Text("All done!"),
                                  Center(
                                      child: GreenElevatedButton(
                                          text: "OK",
                                          onPressed: () => authCubit
                                              .authLogoutRequest()
                                              .then((value) =>
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const LoginPage())))))
                                ],
                              ),
                            ));
                  })
            ],
          )
        ],
      ),
    );
  }
}

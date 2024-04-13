import 'dart:js_util';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class HomePage extends StatelessWidget {
  final UserCredential userCredential;

  const HomePage({super.key, required this.userCredential});

  @override
  Widget build(BuildContext context) {
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
      child: _HomePageContent(userCredential: userCredential),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  final UserCredential userCredential;

  const _HomePageContent({required this.userCredential});

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  // User info
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;
  // Custom theme
  final ThemeData customTheme = theme;
  // Controllers
  final TextEditingController _textController = TextEditingController();
  // Index of footer nav selection
  final int _selectedIndex = 2;

  // Dispose of controllers for performance
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Get user info state
  @override
  void initState() {
    context.read<UserInfoCubit>().getUserInfo(widget.userCredential);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FooterNavCubit, int>(
      listener: (context, state) {
        navigateToPage(context, state, _userRole, widget.userCredential);
      },
      child: BlocConsumer<UserInfoCubit, HomeState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is UserInfoLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UserInfoLoaded) {
            // Assign user info
            _userRole = state.userRole;
            _userName = state.userName;
            _userReference = state.userReference;

            return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: customTheme,
                home: _buildHomeView());
          } else if (state is UserInfoError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          } else {
            return const Center(child: Text('Unexpected State'));
          }
        },
      ),
    );
  }

  Widget _buildHomeView() {
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);
    return Scaffold(
      appBar: createMainAppBar(context, widget.userCredential, _userReference),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
              child:
                  Text("Welcome Back, $_userName!", style: headingTextStyle)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                icon: Icon(Icons.search, size: 24),
                hintText: "Search...",
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            child: const Text(
              "Notifications",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          // Use BlocBuilder for notifications
          BlocBuilder<NotificationsCubit, HomeState>(
            builder: (context, state) {
              if (state is NotificationsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is NotificationsLoaded) {
                List<NotificationData> notificationsList = state.notifications;
                if (notificationsList.isEmpty) {
                  return const Center(child: Text("No Notifications..."));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: notificationsList.length,
                    itemBuilder: (context, index) {
                      NotificationData notification = notificationsList[index];
                      return ListTile(
                        title: Text(notification.message),
                      );
                    },
                  );
                }
              } else if (state is NotificationsError) {
                return Center(child: Text('Error: ${state.errorMessage}'));
              } else {
                return const Center(child: Text('Unexpected State'));
              }
            },
          ),
        ],
      ),
      bottomNavigationBar:
          createFooterNav(_selectedIndex, footerNavCubit, _userRole),
    );
  }
}

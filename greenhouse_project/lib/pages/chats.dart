/// Chats Page - all chats associated with the user
///
/// TODO:
/// - Display chats properly (with username etc.)
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/pages/chat.dart';
import 'package:greenhouse_project/services/cubit/chats_cubit.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/theme.dart';

class ChatsPage extends StatelessWidget {
  final UserCredential userCredential; //User auth credentials

  const ChatsPage({super.key, required this.userCredential});

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
          create: (context) => ChatsCubit(userCredential),
        )
      ],
      child: _ChatsPageContent(userCredential: userCredential),
    );
  }
}

class _ChatsPageContent extends StatefulWidget {
  final UserCredential
      userCredential; //User auth credentials //User auth credentials

  const _ChatsPageContent({required this.userCredential});

  @override
  State<_ChatsPageContent> createState() => _ChatsPageState();
}

// Main page content goes here
class _ChatsPageState extends State<_ChatsPageContent> {
  // User info local variables
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;

  // Custom theme
  final ThemeData customTheme = theme;

  // Index of footer nav selection
  final int _selectedIndex = 4;

  // Dispose (destructor)
  @override
  void dispose() {
    super.dispose();
  }

  // InitState - get user info state to check authentication later
  @override
  void initState() {
    context.read<UserInfoCubit>().getUserInfo(widget.userCredential);
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
          // Show page content once user info is loaded
          else if (state is UserInfoLoaded) {
            // Store user info in local variables
            _userRole = state.userRole;
            _userName = state.userName;
            _userReference = state.userReference;

            // Call function to create chats page
            return Theme(data: customTheme, child: _createChatsPage());
          }
          // Show error if there is an issues with user info
          else if (state is UserInfoError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          // If somehow state doesn't match predefined states;
          // never happens; but, anything can happen
          else {
            return const Center(
              child: Text('Unexpected state'),
            );
          }
        },
      ),
    );
  }

  // Create chats page function
  Widget _createChatsPage() {
    // Get instance of footer nav cubit from main context
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);

    // Page content
    return Scaffold(
      //Main appbar (header)
      appBar: createMainAppBar(context, widget.userCredential, _userReference),

      // BlocBuilder for chats cubit (all chats)
      body: BlocBuilder<ChatsCubit, ChatsState>(builder: (context, state) {
        // Show "loading screen" if processing chat state
        if (state is ChatsLoading) {
          return const CircularProgressIndicator();
        }
        // Show chat messages once chat state is loaded
        else if (state is ChatsLoaded) {
          List<ChatsData?> chatsList = state.chats; // chats list
          // Display nothing if no chats
          if (chatsList.isEmpty) {
            return const Text("No chats...");
          }
          // Display chats
          else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: chatsList.length,
              itemBuilder: (context, index) {
                ChatsData? chat = chatsList[index]; // chat data
                Map<String, dynamic>? receiverData = chat?.receiverData;
                // Navigate to chat page when chat is pressed
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatPage(
                                  userCredential: widget.userCredential,
                                  chatReference: chat?.reference,
                                )));
                  },
                  // Display chat info
                  child: ListTile(
                    title: Text(
                        "${receiverData?['name']} ${receiverData?['surname']}"),
                  ),
                );
              },
            );
          }
        }
        // Show error message once an error occurs
        else if (state is ChatsError) {
          return const Text("Something went wrong...");
        }
        // If the state is not any of the predefined states;
        // never happen; but, anything can happen
        else {
          return const Text("Something went wrong...");
        }
      }),
      // Footer nav bar
      bottomNavigationBar:
          createFooterNav(_selectedIndex, footerNavCubit, _userRole),
    );
  }
}

/// Display chats properly (with username etc.)
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/chat_cubit.dart';
import 'package:greenhouse_project/services/cubit/chats_cubit.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/theme.dart';

class ChatPage extends StatelessWidget {
  final UserCredential userCredential;
  final DocumentReference? chatReference;

  const ChatPage(
      {super.key, required this.userCredential, required this.chatReference});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NotificationsCubit(userCredential),
        ),
        BlocProvider(
          create: (context) => UserInfoCubit(),
        ),
        BlocProvider(
          create: (context) => ChatsCubit(userCredential),
        ),
        BlocProvider(create: (context) => ChatCubit(chatReference))
      ],
      child: _ChatPageContent(userCredential: userCredential),
    );
  }
}

class _ChatPageContent extends StatefulWidget {
  final UserCredential userCredential;

  const _ChatPageContent({required this.userCredential});

  @override
  State<_ChatPageContent> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPageContent> {
  // User info
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;
  // Custom theme
  final ThemeData customTheme = theme;
  // Text controller for sending messages
  final TextEditingController _textEditingController = TextEditingController();

  // Dispose of controllers for performance
  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  // Init to get user info state
  @override
  void initState() {
    context.read<UserInfoCubit>().getUserInfo(widget.userCredential);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // If footer nav state is updated, handle navigation
    return BlocBuilder<UserInfoCubit, HomeState>(
      builder: (context, state) {
        // Show "loading screen" if processing user info
        if (state is UserInfoLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // Show page content once user info is loaded
        else if (state is UserInfoLoaded) {
          // Assign user info
          _userRole = state.userRole;
          _userName = state.userName;
          _userReference = state.userReference;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: customTheme,
            home: _createChatPage(),
          );
        }
        // Show error if there is an issues with user info
        else if (state is UserInfoError) {
          return Center(child: Text('Error: ${state.errorMessage}'));
        }
        // Should never happen, but you never know
        else {
          return const Center(
            child: Text('Unexpected state'),
          );
        }
      },
    );
  }

  Widget _createChatPage() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const CircularProgressIndicator();
        } else if (state is ChatLoaded) {
          List<MessageData?> messages = state.messages;
          if (messages.isEmpty) {
            return const Text("");
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                MessageData? message = messages[index];
                // Received messages on left
                if (message?.receiver == _userReference) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: ListTile(
                      title: Text("${message?.message}"),
                    ),
                  );
                }
                // Sent messages on right
                else {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: ListTile(
                      title: Text("${message?.message}"),
                    ),
                  );
                }
              },
            );
          }
        } else if (state is ChatError) {
          print(state.error.toString());
          return const Text("Something went wrong...");
        } else {
          return const Text("Something went wrong...");
        }
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
          ), // TO-DO: CHAT PAGE APPBAR
          body: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.send, size: 24),
                        hintText: "Write a message...",
                      ),
                    ),
                  ),
                  Expanded(
                      child:
                          GreenElevatedButton(text: "send", onPressed: () {}))
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

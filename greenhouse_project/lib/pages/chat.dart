/// Chat Page - allows communication between 2 users
///
/// TODO:
/// - Refresh messages for receiver after sending a message
/// - Check cubit usage (lines 129-200?)
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/chat_cubit.dart';
import 'package:greenhouse_project/services/cubit/chats_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/theme.dart';

class ChatPage extends StatelessWidget {
  final UserCredential userCredential; // user auth credentials
  final DocumentReference? chatReference; // Chat database reference

  const ChatPage({
    super.key,
    required this.userCredential,
    required this.chatReference,
  });

  @override
  Widget build(BuildContext context) {
    // Provide Cubits for state management
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
        BlocProvider(
          create: (context) => ChatCubit(chatReference),
        ),
      ],
      child: _ChatPageContent(
        userCredential: userCredential,
        chatReference: chatReference,
      ),
    );
  }
}

class _ChatPageContent extends StatefulWidget {
  final UserCredential userCredential; // user auth credentials
  final DocumentReference? chatReference; //Chat database reference

  const _ChatPageContent(
      {required this.userCredential, required this.chatReference});

  @override
  State<_ChatPageContent> createState() => _ChatPageState();
}

// Main page content goes here
class _ChatPageState extends State<_ChatPageContent> {
  // User info local variables
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;

  // Custom theme
  final ThemeData customTheme = theme;

  // Text controller for sending messages
  final TextEditingController _textEditingController = TextEditingController();

  // Dispose (destructor)
  @override
  void dispose() {
    _textEditingController.dispose();
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
    // BlocBuilder for user info
    return BlocBuilder<UserInfoCubit, HomeState>(
      builder: (context, state) {
        // Show "loading screen" if processing user info
        if (state is UserInfoLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // Initiate page creation once user info is loaded
        // Show content once user info is loaded
        else if (state is UserInfoLoaded) {
          // Store user info in local variables
          _userRole = state.userRole;
          _userName = state.userName;
          _userReference = state.userReference;

          // Call function to create chat page
          return Theme(data: customTheme, child: _createChatPage());
        }
        // Show error if there are issues with user info
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
    );
  }

  // Create chat page function
  Widget _createChatPage() {
    // BlocBuilder for chats cubit (all chats)
    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        // Get chat using the database reference, null if somehow no chat matches
        ChatsData? chat = (state is ChatsLoaded)
            ? state.chats.firstWhere(
                (element) => element?.reference == widget.chatReference)
            : null;
        return Scaffold(
          // Appbar (header)
          appBar: AppBar(
              automaticallyImplyLeading: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              // Username of other chat party
              title: Text(
                  "${chat?.receiverData?['name']} ${chat?.receiverData?['surname']}")),

          // BlocBuilder for chat cubit (one chat)
          body: BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              // Show "loading screen" if processing chat state
              if (state is ChatLoading) {
                return const CircularProgressIndicator();
              }
              // Show chat messages once chat state is loaded
              else if (state is ChatLoaded) {
                List<MessageData?> messages = state.messages; // messages list
                // Display nothing if no messages
                if (messages.isEmpty) {
                  return const Center(child: Text("Write your first message!"));
                }
                // Display messages
                else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      MessageData? message = messages[index]; // message data
                      Alignment alignment = message?.receiver == _userReference
                          ? Alignment.centerLeft
                          : Alignment.centerRight; //align based on receiver
                      return ListTile(
                        title: Align(
                            alignment: alignment,
                            child: Text("${message?.message}")),
                      );
                    },
                  );
                }
              }
              // Show error message once an error occurs
              else if (state is ChatError) {
                print(state.error.toString());
                return const Text("Something went wrong...");
              }
              // If the state is not any of the predefined states;
              // never happens; but, anything can happen
              else {
                return const Center(child: Text('Unexpected State'));
              }
            },
          ),

          // Message input box
          bottomNavigationBar: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textEditingController,
                ),
              ),
              Expanded(
                  child: GreenElevatedButton(
                text: "Send",
                // Send message and clear text controller
                onPressed: () {
                  if (_textEditingController.text != "") {
                    context.read<ChatCubit>().sendMessage(
                        _textEditingController.text,
                        chat?.receiverData?['reference'],
                        _userReference,
                        chat!.reference);
                    _textEditingController.text = "";
                  }
                },
              ))
            ],
          ),
        );
      },
    );
  }
}

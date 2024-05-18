/// Chat Page - allows communication between 2 users
///
/// TODO:
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
import 'package:greenhouse_project/utils/input.dart';
import 'package:greenhouse_project/utils/message_bubble.dart';
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
    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        // Get the specific chat directly from the cubit
        ChatsData? chat = (state is ChatsLoaded)
            ? context
                .read<ChatsCubit>()
                .getChatByReference(state.chats, widget.chatReference!)
            : null;

        // Return loading indicator if chat is still loading
        if (chat == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Return the chat page UI once chat data is available
        return _buildChatUI(chat);
      },
    );
  }

// Build chat page UI using the provided chat data
  Widget _buildChatUI(ChatsData chat) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "${chat.receiverData?['name']} ${chat.receiverData?['surname']}",
        ),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          // Handle different states of the chat
          if (state is ChatLoading) {
            return const CircularProgressIndicator();
          } else if (state is ChatLoaded) {
            return _buildChatContent(state.messages);
          } else if (state is ChatError) {
            return const Text("Something went wrong...");
          } else {
            return const Center(child: Text('Unexpected State'));
          }
        },
      ),
    );
  }

  // Build the list of chat messages
  Widget _buildChatContent(List<MessageData?> messages) {
    if (messages.isEmpty) {
      return const Center(child: Text("Write your first message!"));
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                MessageData? message = messages[index];
                bool isSender = message?.receiver != _userReference;
                return Align(
                  alignment:
                      isSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: MessageBubble(
                    message: message?.message ?? "",
                    isSender: isSender,
                    theme: customTheme,
                  ),
                );
              },
            ),
          ),
          Container(
              // ADD INPUT FIELD
              ),
        ],
      );
    }
  }

// Build the message input box
  // Widget _buildMessageInput(ChatsData? chat) {
  //   return Row(
  //     children: [
  //       Expanded(
  //           child: InputTextField(
  //               controller: _textEditingController,
  //               errorText: "",
  //               hintText: "send a message")),
  //       Expanded(
  //         child: GreenElevatedButton(
  //           text: "Send",
  //           onPressed: () {
  //             _sendMessage(chat);
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

// Function to send a message
  void _sendMessage(ChatsData? chat) {
    if (_textEditingController.text.isNotEmpty) {
      context.read<ChatCubit>().sendMessage(
            _textEditingController.text,
            chat?.receiverData?['reference'],
            _userReference,
            chat!.reference,
          );
      _textEditingController.text = "";
    }
  }
}

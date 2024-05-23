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
import 'package:greenhouse_project/services/cubit/chat_users_cubit.dart';
import 'package:greenhouse_project/services/cubit/chats_cubit.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class ChatsPage extends StatelessWidget {
  final UserCredential userCredential; // user auth credentials

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
        ),
        BlocProvider(
          create: (context) => ChatUsersCubit(userCredential),
        )
      ],
      child: _ChatsPageContent(userCredential: userCredential),
    );
  }
}

class _ChatsPageContent extends StatefulWidget {
  final UserCredential userCredential; // user auth credentials

  const _ChatsPageContent({required this.userCredential});

  @override
  State<_ChatsPageContent> createState() => _ChatsPageState();
}

// Main page content goes here
class _ChatsPageState extends State<_ChatsPageContent> {
  // User info local variables
  late String _userRole = "";
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

  Widget _createChatsPage() {
    // Get instance of footer nav cubit from main context
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);

    // Main page content
    return Scaffold(
        appBar: createMainAppBar(
            context, widget.userCredential, _userReference, 'Chats'),
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
            child: _buildChatsList()),
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child:
                    createFooterNav(_selectedIndex, footerNavCubit, _userRole)),
          ),
        ),
        floatingActionButton: GreenElevatedButton(
            text: "New Chat",
            onPressed: () {
              ChatsCubit chatsCubit = context.read<ChatsCubit>();
              ChatUsersCubit chatUsersCubit = context.read<ChatUsersCubit>();
              showDialog(
                  context: context,
                  builder: (context) {
                    return BlocBuilder<ChatUsersCubit, ChatUsersState>(
                      bloc: chatUsersCubit,
                      builder: (context, state) {
                        if (state is ChatUsersLoading) {
                          // Show loading indicator while employees are being fetched
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is ChatUsersLoaded) {
                          final chatUsersList = state.chatUsers;
                          if (chatUsersList.isEmpty) {
                            // Display a message if there are no Employees
                            return const Center(child: Text("No Employees..."));
                          } else {
                            // Display the list of Employees
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(
                                    color: Colors.transparent,
                                    width: 2.0), // Add border color and width
                              ),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16.0),
                                  shrinkWrap: true,
                                  itemCount: chatUsersList.length,
                                  itemBuilder: (context, index) {
                                    final employee = chatUsersList[index];
                                    return ListTile(
                                      leading: Container(
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipOval(
                                          child: Image.memory(
                                            employee!.picture,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                          " ${employee.name + employee.surname}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                      subtitle: Text(employee.role,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.grey,
                                            fontSize: 8.0,
                                          )
                                          ),
                                          onTap: () {
                                            chatsCubit.createChat(employee.reference);
                                          },
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        } else if (state is ChatUsersError) {
                          // Display an error message if chats cannot be loaded
                          return Center(child: Text('Error: ${state.error}'));
                        } else {
                          // Display a generic error message if an unexpected state occurs
                          return const Center(
                              child: Text("Something went wrong..."));
                        }
                      },
                    );
                  });
            }));
  }

  Widget _buildChatsList() {
    // BlocBuilder for chats cubit (all chats)
    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        if (state is ChatsLoading) {
          // Show loading indicator while chats are being fetched
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatsLoaded) {
          final chatsList = state.chats;
          if (chatsList.isEmpty) {
            // Display a message if there are no chats
            return const Center(child: Text("No chats..."));
          } else {
            // Display the list of chats
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              itemCount: chatsList.length,
              itemBuilder: (context, index) {
                final chat = chatsList[index];
                return _buildChatItem(chat);
              },
            );
          }
        } else if (state is ChatsError) {
          // Display an error message if chats cannot be loaded
          return Center(child: Text('Error: ${state.error}'));
        } else {
          // Display a generic error message if an unexpected state occurs
          return const Center(child: Text("Something went wrong..."));
        }
      },
    );
  }

  Widget _buildChatItem(ChatsData? chat) {
    final receiverData = chat?.receiverData;
    // Display chat information
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4.0,
        margin: EdgeInsets.only(bottom: 16.0),
        child: GestureDetector(
          onTap: () {
            // Navigate to the chat page when a chat is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  userCredential: widget.userCredential,
                  chatReference: chat.reference,
                ),
              ),
            );
          },
          child: Container(
            decoration: const BoxDecoration(border: Border.symmetric()),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ClipOval(
                        child: Image.memory(
                      chat!.receiverPicture,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(left: 5),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                              text:
                                  "${receiverData?['name']} ${receiverData?['surname']}",
                              style: bodyTextStyle,
                              children: <TextSpan>[
                                TextSpan(
                                  text: "     (" + receiverData!['role'] + ")",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.grey,
                                    fontSize: 14.0,
                                  ),
                                )
                              ]),
                        ))),
              ],
            ),
          ),
        ));
    //it's up
  }
}

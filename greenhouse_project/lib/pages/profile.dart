/// TO-DO:
/// * Connect to database and fetch actual user data
/// * Make "edit" button functional
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/profile_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class ProfilePage extends StatelessWidget {
  final UserCredential userCredential;
  final DocumentReference userReference;

  const ProfilePage(
      {super.key, required this.userCredential, required this.userReference});

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
          create: (context) => ProfileCubit(userReference),
        ),
      ],
      child: _ProfilePageContent(
        userCredential: userCredential,
        userReference: userReference,
      ),
    );
  }
}

class _ProfilePageContent extends StatefulWidget {
  final UserCredential userCredential;
  final DocumentReference userReference;

  const _ProfilePageContent(
      {super.key, required this.userCredential, required this.userReference});

  @override
  State<_ProfilePageContent> createState() => __ProfilePageContentState();
}

class __ProfilePageContentState extends State<_ProfilePageContent> {
  // User info
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;

  // Custom theme
  final ThemeData customTheme = theme;

  // Controller for input text field
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<UserInfoCubit>().getUserInfo(widget.userCredential);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserInfoCubit, HomeState>(
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
          return Theme(
            data: customTheme,
            child: _createProfilePage(),
          );
        } else {
          return const Center(
            child: Text('Unexpected state'),
          );
        }
      },
    );
  }

  Widget _createProfilePage() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const CircularProgressIndicator();
        } else if (state is ProfileLoaded) {
          _nameController.text = state.userData['name'];
          _emailController.text = state.userData['email'];
          _passwordController.text = '****';

          return Theme(
              data: customTheme,
              child: Scaffold(
                appBar: AppBar(
                    leading: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Image.asset(
                          "lib/utils/Icons/Left Arrow.png",
                          scale: 3,
                        )),
                    title: const Padding(
                      padding: EdgeInsets.fromLTRB(70, 0, 0, 0),
                      child: Text(
                        "Profile",
                        style: headingTextStyle,
                      ),
                    )),
                body: Column(
                  children: [
                    const Center(child: Text("PROFILE PIC")),
                    const Text("Name"),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(state.userData['name']),
                    ),
                    const Text("Email"),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(state.userData['email']),
                    ),
                    state.userData['email'] == widget.userCredential.user?.email
                        ? const Column(
                            children: [
                              Text("Password"),
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('*****'),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: state.userData['role'] == 'worker' &&
                                _userRole == 'manager'
                            ? Row(
                                children: [
                                  GreenElevatedButton(
                                      text: "Tasks", onPressed: () {}),
                                  GreenElevatedButton(
                                      text: "Message", onPressed: () {}),
                                  GreenElevatedButton(
                                      text: "Delete", onPressed: () {})
                                ],
                              )
                            : state.userData['email'] ==
                                    widget.userCredential.user?.email
                                ? GreenElevatedButton(
                                    text: "Edit",
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              child: Column(
                                                children: [
                                                  TextField(
                                                    controller: _nameController,
                                                    decoration:
                                                        InputDecoration(),
                                                  ),
                                                  TextField(
                                                    controller:
                                                        _emailController,
                                                    decoration:
                                                        InputDecoration(),
                                                  ),
                                                  TextField(
                                                    controller:
                                                        _passwordController,
                                                    decoration:
                                                        InputDecoration(),
                                                  ),
                                                  Row(
                                                    children: [
                                                      GreenElevatedButton(
                                                          text: "Submit",
                                                          onPressed: () {
                                                            // TO-DO: Input validation
                                                            // TO-DO: (then) Password confirmation
                                                            // TO-DO: (then) Commit to database
                                                          }),
                                                      GreenElevatedButton(
                                                          text: "Cancel",
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          }),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            );
                                          });
                                    })
                                : GreenElevatedButton(
                                    text: "Message", onPressed: () {}))
                  ],
                ),
              ));
        } else {
          return const Text("Something went wrong...");
        }
      },
    );
  }
}

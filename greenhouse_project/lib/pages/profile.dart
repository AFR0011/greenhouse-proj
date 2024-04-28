/// TO-DO:
/// - Fix BlocProvider issue for UserInfoCubit for Password Confirmation
/// - Pop until profile page after profile update
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/profile_cubit.dart';
import 'package:greenhouse_project/services/cubit/profile_edit_cubit.dart';
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
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _equipmentController.dispose();
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
          _equipmentController.text = state.userData['name'];
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
                                                child: _createEditDialog());
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

  Widget _createEditDialog() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileEditCubit(),
        ),
        BlocProvider(
          create: (context) => UserInfoCubit(),
        ),
      ],
      child: BlocBuilder<ProfileEditCubit, List<bool>>(
        builder: (context, state) {
          return Column(
            children: [
              TextField(
                controller: _equipmentController,
                decoration: InputDecoration(
                    errorText: state[0]
                        ? ""
                        : "Name should be longer than 4 characters."),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                    errorText: state[1] ? "" : "Email format invalid."),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    errorText: state[2]
                        ? ""
                        : "Password should be longer than 8 characters."),
              ),
              Row(
                children: [
                  GreenElevatedButton(
                      text: "Submit",
                      onPressed: () {
                        List<bool> validation = [true, true, true];
                        if (_equipmentController.text.length < 4) {
                          validation[0] = !validation[0];
                        }
                        if (!_emailController.text
                            .contains(RegExp(r'.+@.+\..+'))) {
                          validation[1] = !validation[1];
                        }
                        if (_passwordController.text.length < 8) {
                          validation[2] = !validation[2];
                        }

                        bool isValid = context
                            .read<ProfileEditCubit>()
                            .updateState(validation);

                        if (!isValid) {
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Column(
                                    children: [
                                      const Center(
                                          child: Text("Enter Password")),
                                      TextField(
                                        controller: _passwordConfirmController,
                                      ),
                                      Row(
                                        children: [
                                          GreenElevatedButton(
                                              text: "Confirm",
                                              onPressed: () async {
                                                FirebaseAuth auth =
                                                    FirebaseAuth.instance;
                                                String email = widget
                                                    .userCredential
                                                    .user!
                                                    .email as String;
                                                try {
                                                  UserCredential
                                                      userCredential =
                                                      await auth
                                                          .signInWithEmailAndPassword(
                                                              email: email,
                                                              password:
                                                                  _passwordConfirmController
                                                                      .text);
                                                  context
                                                      .read<UserInfoCubit>()
                                                      .setUserInfo(
                                                          _userReference,
                                                          _equipmentController.text,
                                                          _emailController.text,
                                                          _passwordController
                                                              .text);
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Dialog(
                                                          child: Column(
                                                            children: [
                                                              const Center(
                                                                child: Text(
                                                                    "Profile Updated Succesfully."),
                                                              ),
                                                              Center(
                                                                child:
                                                                    GreenElevatedButton(
                                                                  text: "OK",
                                                                  onPressed: () =>
                                                                      Navigator.popUntil(
                                                                          context,
                                                                          (route) =>
                                                                              false),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      });
                                                } catch (error) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content:
                                                        Text(error.toString()),
                                                  ));
                                                  return;
                                                }
                                              }),
                                          GreenElevatedButton(
                                              text: "Cancel",
                                              onPressed: () {
                                                Navigator.pop(context);
                                              })
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              });
                        }
                        // TO-DO: (then) Password confirmation
                        // TO-DO: (then) Commit to database
                      }),
                  GreenElevatedButton(
                      text: "Cancel",
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}

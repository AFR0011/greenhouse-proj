/// Profile page - user profile information and actions
library;

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/firebase_options.dart';
import 'package:greenhouse_project/services/cubit/chats_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/profile_cubit.dart';
import 'package:greenhouse_project/services/cubit/profile_edit_cubit.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/input.dart';
import 'package:greenhouse_project/utils/theme.dart';

// Web VAPID key for Firebase Cloud Messaging
const String webVapidKey =
    "BKWvS-G0BOBMCAmBJVz63de5kFb5R2-OVxrM_ulKgCoqQgVXSY8FqQp7QM5UoC5S9hKs5crmzhVJVyyi_sYDC9I";

/// Profile page widget
class ProfilePage extends StatelessWidget {
  final UserCredential userCredential; // User authentication credentials
  final DocumentReference userReference; // User database reference

  const ProfilePage({
    Key? key,
    required this.userCredential,
    required this.userReference,
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
          create: (context) => ProfileCubit(userReference),
        ),
        BlocProvider(
          create: (context) => ChatsCubit(userCredential),
        ),
      ],
      child: _ProfilePageContent(
        userCredential: userCredential,
        userReference: userReference,
      ),
    );
  }
}

/// Profile page content widget
class _ProfilePageContent extends StatefulWidget {
  final UserCredential userCredential; // User authentication credentials
  final DocumentReference userReference; // User database reference

  const _ProfilePageContent({
    required this.userCredential,
    required this.userReference,
  });

  @override
  State<_ProfilePageContent> createState() => __ProfilePageContentState();
}

// Main page content state
class __ProfilePageContentState extends State<_ProfilePageContent> {
  late DocumentReference _userReference; // User database reference
  Uint8List? image; // User profile image

  final ThemeData customTheme = theme; // Custom theme

  // Text controllers for input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  @override
  void dispose() {
    // Dispose text controllers
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeUserInfo(); // Initialize user information
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserInfoCubit, HomeState>(
      builder: (context, state) {
        if (state is UserInfoLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is UserInfoLoaded) {
          _userReference = state.userReference; // Assign user reference
          return Theme(data: customTheme, child: _createProfilePage());
        } else if (state is UserInfoError) {
          return Center(child: Text('Error: ${state.errorMessage}'));
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ProfileLoaded) {
          return _buildProfileContent(state.userData);
        } else if (state is ProfileError) {
          return Center(child: Text('Error: ${state.error}'));
        } else {
          return const Center(child: Text('Unexpected State'));
        }
      },
    );
  }

  Widget _buildProfileContent(UserData userData) {
    final ProfileCubit profileCubit = BlocProvider.of<ProfileCubit>(context);

    return Scaffold(
      appBar: createAltAppbar(context, "Profile"),
      body: SingleChildScrollView(
        child: Container(
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
              image: const AssetImage('lib/utils/Icons/leaf_pat.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.1),
                BlendMode.dstATop,
              ),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              GestureDetector(
                child: ClipOval(
                    child: Image.memory(
                  userData.picture,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                )),
                onTap: () {
                  profileCubit.selectImage();
                },
              ),
              const SizedBox(height: 20.0),
              ProfileTextField(
                name: "Name",
                data: userData.name,
                icon: userIcon(),
              ),
              const SizedBox(height: 20.0),
              ProfileTextField(
                name: "Email",
                data: userData.email,
                icon: emailIcon(),
              ),
              const SizedBox(height: 20.0),
              if (userData.email == widget.userCredential.user?.email)
                ProfileTextField(
                  name: "Password",
                  data: "********",
                  icon: passwordIcon(),
                ),
              const SizedBox(height: 20.0),
              _buildActionButtons(userData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(UserData userData) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: userData.email == widget.userCredential.user?.email
          ? WhiteElevatedButton(
              text: "Edit",
              onPressed: () {
                _createEditDialog(userData);
              },
            )
          : WhiteElevatedButton(
              text: "Message",
              onPressed: () => context
                  .read<ChatsCubit>()
                  .createChat(context, userData.reference)),
    );
  }

  void _createEditDialog(UserData userData) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailController.text = userData.email;
      _nameController.text = userData.name;
      _passwordController.text = "";
    });
    final UserInfoCubit userInfoCubit = BlocProvider.of<UserInfoCubit>(context);
    final ScaffoldMessengerState scaffoldMessenger =
        ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: Colors.transparent,
              width: 2.0,
            ),
          ),
          title: const Text("Edit profile"),
          content: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              width: MediaQuery.of(context).size.width * .6,
              child: BlocProvider(
                create: (context) => ProfileEditCubit(),
                child: BlocBuilder<ProfileEditCubit, List<bool>>(
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputTextField(
                          controller: _nameController,
                          errorText: state[0]
                              ? null
                              : "Name should be longer than 4 characters.",
                          labelText: "Name",
                        ),
                        InputTextField(
                          controller: _emailController,
                          errorText: state[1] ? null : "Email format invalid.",
                          labelText: "Email",
                        ),
                        InputTextField(
                          controller: _passwordController,
                          errorText: state[2]
                              ? null
                              : "Password should be longer than 8 characters.",
                          labelText: "Password",
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GreenElevatedButton(
                                text: "Submit",
                                onPressed: () {
                                  List<bool> validation = [true, true, true];
                                  if (_nameController.text.length < 4) {
                                    validation[0] = !validation[0];
                                  }
                                  if (!_emailController.text
                                      .contains(RegExp(r'.+@.+\..+'))) {
                                    validation[1] = !validation[1];
                                  }
                                  if (_passwordController.text.length < 8 &&
                                      _passwordController.text.isNotEmpty) {
                                    validation[2] = !validation[2];
                                  }

                                  bool isValid = context
                                      .read<ProfileEditCubit>()
                                      .updateState(validation);

                                  if (isValid) {
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            side: BorderSide(
                                              color: Colors.transparent,
                                              width: 2.0,
                                            ),
                                          ),
                                          title: const Text("Enter password"),
                                          content: SingleChildScrollView(
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                  maxWidth: 400),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .6,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  InputTextField(
                                                    controller:
                                                        _passwordConfirmController,
                                                    errorText: state[2]
                                                        ? null
                                                        : "Password should be longer than 8 characters.",
                                                    labelText: "Password",
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            GreenElevatedButton(
                                                          text: "Confirm",
                                                          onPressed: () =>
                                                              _updateProfile(
                                                                  userInfoCubit,
                                                                  scaffoldMessenger),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child:
                                                            WhiteElevatedButton(
                                                          text: "Cancel",
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            _createEditDialog(
                                                                userData);
                                                          },
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: WhiteElevatedButton(
                                text: "Cancel",
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateProfile(UserInfoCubit userInfoCubit,
      ScaffoldMessengerState scaffoldMessenger) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String email = widget.userCredential.user!.email as String;
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordConfirmController.text,
      );

      await userInfoCubit.setUserInfo(
          _userReference,
          _nameController.text,
          _emailController.text,
          _passwordController.text.isNotEmpty
              ? _passwordController.text
              : _passwordConfirmController.text,
          _passwordConfirmController.text);
      _passwordConfirmController.text = "";
      _passwordController.text = "";
      _showConfirmation();
    } catch (error) {
      Navigator.pop(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: customTheme.colorScheme.error,
        ),
      );
      return;
    }
  }

  void _showConfirmation() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully!")),
    );
  }

  Future<void> _initializeUserInfo() async {
    try {
      if (DefaultFirebaseOptions.currentPlatform !=
          DefaultFirebaseOptions.android) {
        context.read<UserInfoCubit>().getUserInfo(widget.userCredential, null);
      } else {
        String? deviceFcmToken =
            await FirebaseMessaging.instance.getToken(vapidKey: webVapidKey);
        if (mounted) {
          context
              .read<UserInfoCubit>()
              .getUserInfo(widget.userCredential, deviceFcmToken);
        }
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }
}

Widget userIcon() {
  return const Icon(Icons.account_circle_outlined);
}

Widget emailIcon() {
  return const Icon(Icons.mail_outline_outlined);
}

Widget passwordIcon() {
  return const Icon(Icons.password_outlined);
}

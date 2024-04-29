/// Profile page - user profile information and actions
///
/// TODO:
/// - Error snackbar shows outside of dialogs
///   (either show a dialog for errors or fix this)
/// - Add profile picture
///
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
  final UserCredential userCredential; // user auth credentials
  final DocumentReference userReference; // user database reference

  const ProfilePage(
      {super.key, required this.userCredential, required this.userReference});

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
      ],
      child: _ProfilePageContent(
        userCredential: userCredential,
        userReference: userReference,
      ),
    );
  }
}

class _ProfilePageContent extends StatefulWidget {
  final UserCredential userCredential; // user auth credentials
  final DocumentReference userReference; // user database reference

  const _ProfilePageContent(
      {super.key, required this.userCredential, required this.userReference});

  @override
  State<_ProfilePageContent> createState() => __ProfilePageContentState();
}

// Main page content
class __ProfilePageContentState extends State<_ProfilePageContent> {
  // User info local variables
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;

  // Custom theme
  final ThemeData customTheme = theme;

  // Text controllers for input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  // Dispose (destructor)
  @override
  void dispose() {
    _emailController.dispose();
    _equipmentController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
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
        // Show content once user info is loaded
        else if (state is UserInfoLoaded) {
          // Assign user info to local variables
          _userRole = state.userRole;
          _userName = state.userName;
          _userReference = state.userReference;

          // Call function to create profile page
          return Theme(data: customTheme, child: _createProfilePage());
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
    );
  }

  // Function to create profile page
  Widget _createProfilePage() {
    // BlocBuilder for profile state
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // Show "loading screen" if processing profile state
        if (state is ProfileLoading) {
          return const CircularProgressIndicator();
        }
        // Show profile once profile state is loaded
        else if (state is ProfileLoaded) {
          // Store profile info in controllers
          _equipmentController.text = state.userData['name'];
          _emailController.text = state.userData['email'];
          _passwordController.text = '';

          // Profile info
          return Scaffold(
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
                // Profile information
                const Center(child: Text("PROFILE PIC")), // Profile picture
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
                            child: Text('*******'),
                          ),
                        ],
                      )
                    : const SizedBox(),

                // Action buttons
                Align(
                    alignment: Alignment.bottomCenter,
                    child: state.userData['role'] == 'worker' &&
                            _userRole == 'manager'
                        ? Row(
                            children: [
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
          );
        }
        // Show error message once an error occurs
        else if (state is ProfileError) {
          return Center(child: Text('Error: ${state.error}'));
        }
        // If the state is not any of the predefined states;
        // never happens; but, anything can happen
        else {
          return const Center(child: Text('Unexpected State'));
        }
      },
    );
  }

  // Function to create profile edit form
  Widget _createEditDialog() {
    // Get instance of cubit from main context
    UserInfoCubit userInfoCubit = BlocProvider.of<UserInfoCubit>(context);

    // Get instance of scaffold messenger from main context
    ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);

    // Provide profile edit cubit
    return BlocProvider(
      create: (context) => ProfileEditCubit(),
      // BlocBuilder for profile edit state
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
                        if (_passwordController.text.length < 8 &&
                            _passwordController.text.isNotEmpty) {
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
                                              onPressed: () => _updateProfile(
                                                  userInfoCubit,
                                                  scaffoldMessenger)),
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

  // Function to submit profile edits
  Future<void> _updateProfile(UserInfoCubit userInfoCubit,
      ScaffoldMessengerState scaffoldMessenger) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String email = widget.userCredential.user!.email as String;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: _passwordConfirmController.text);

      userInfoCubit.setUserInfo(
          _userReference,
          _equipmentController.text,
          _emailController.text,
          _passwordController.text.isNotEmpty
              ? _passwordController.text
              : _passwordConfirmController.text);
      _showConfirmation();
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(error.toString()),
        backgroundColor: customTheme.colorScheme.error,
      ));
      return;
    }
  }

  // Function to show edit confirmation dialog
  void _showConfirmation() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Column(
              children: [
                const Center(
                  child: Text("Profile Updated Succesfully."),
                ),
                Center(
                  child: GreenElevatedButton(
                    text: "OK",
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                    userCredential: widget.userCredential,
                                    userReference: widget.userReference,
                                  )),
                          (route) => false);
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}

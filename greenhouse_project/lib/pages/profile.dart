/// Profile page - user profile information and actions
///
/// TODO:
/// - Error snackbar shows outside of dialogs
///   (either show a dialog for errors or fix this)
/// - Add profile picture (https://stackoverflow.com/questions/78159230/instance-of-clientexception-type-clientexception-is-not-a-subtype-of-type)
/// - Revert controller text after "cancel" on edit dialogue
///
library;

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/profile_cubit.dart';
import 'package:greenhouse_project/services/cubit/profile_edit_cubit.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/input.dart';
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

  const _ProfilePageContent({
    required this.userCredential,
    required this.userReference,
  });

  @override
  State<_ProfilePageContent> createState() => __ProfilePageContentState();
}

// Main page content
class __ProfilePageContentState extends State<_ProfilePageContent> {
  // User info local variables
  late String _userRole = "";
  late DocumentReference _userReference;
  Uint8List? image;

  // Custom theme
  final ThemeData customTheme = theme;

  // Text controllers for input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  // Dispose (destructor)
  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
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
        if (state is ProfileLoading) {
          // Show loading indicator while profile state is loading
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ProfileLoaded) {
          // Once profile state is loaded, display profile information
          return _buildProfileContent(state.userData);
        } else if (state is ProfileError) {
          // Show error message if there's an error loading profile state
          print(state.error);
          return Center(child: Text('Error: ${state.error}'));
        } else {
          // Handle unexpected state (should never happen)
          return const Center(child: Text('Unexpected State'));
        }
      },
    );
  }

// Function to build profile content based on user data
  Widget _buildProfileContent(UserData userData) {
    // Assign user data to controllers
    _emailController.text = userData.email;
    _nameController.text = userData.name;
    _passwordController.text = "";
    // Get instance of cubit from main content
    ProfileCubit profileCubit = BlocProvider.of<ProfileCubit>(context);

    return Scaffold(
      appBar: createAltAppbar(context, "Profile"),
      body: Container(
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
            // Display user profile picture
        
            // Display user name
            const SizedBox(height: 20.0),
            ProfileTextField(name: "Name", data: userData.name, icon: userIcon(),),
            // _buildProfileField("Name", userData.name),
            // Display user email
            // _buildProfileField("Email", userData.email),
            const SizedBox(height: 20.0),
            ProfileTextField(name: "Email", data: userData.email, icon: emailIcon(),),
            // Display password (if user is viewing their own profile)
            const SizedBox(height: 20.0),
            if (userData.email == widget.userCredential.user?.email)
              ProfileTextField(name: "Password", data: "********", icon: passwordIcon(),),
              // _buildProfileField("Password", "*******"),
            // Action buttons based on user role and authorization
            const SizedBox(height: 20.0),
            _buildActionButtons(userData),
          ],
        ),
      ),
    );
  }

// Function to build a profile information field
  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(value),
        ),
      ],
    );
  }

// Function to build action buttons based on user role and authorization
  Widget _buildActionButtons(UserData userData) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: userData.role == 'worker' && _userRole == 'manager'
          ? Row(
              children: [
                WhiteElevatedButton(text: "Message", onPressed: () {}),
                RedElevatedButton(text: "Delete", onPressed: () {}),
              ],
            )
          : userData.email == widget.userCredential.user?.email
              ? WhiteElevatedButton(
                  text: "Edit",
                  onPressed: () {
                    _createEditDialog();
                  },
                )
              : WhiteElevatedButton(text: "Message", onPressed: () {}),
    );
  }

  // Function to create profile edit form
   void _createEditDialog() {
    // Get instance of cubit from main context
    UserInfoCubit userInfoCubit = BlocProvider.of<UserInfoCubit>(context);

    // Get instance of scaffold messenger from main context
    ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);

    // Provide profile edit cubit
                        showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                        color: Colors.transparent,
                        width: 2.0), // Add border color and width
                          ),
                          title: const Text("Edit profil"),
                          content: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        width: MediaQuery.of(context).size.width*.6,
                            child:  BlocProvider(
            create: (context) => ProfileEditCubit(),
            // BlocBuilder for profile edit state
            child: BlocBuilder<ProfileEditCubit, List<bool>>(
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min, // Set column to minimum size
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              InputTextField(
                  controller: _nameController,
                  errorText: state[0]
                      ? ""
                      : "Name should be longer than 4 characters.",
                  labelText: "Name"),
              InputTextField(
                  controller: _emailController,
                  errorText: state[1] ? "" : "Email format invalid.",
                  labelText: "Email"),
              InputTextField(
                  controller: _passwordController,
                  errorText: state[2]
                      ? ""
                      : "Password should be longer than 8 characters.",
                  labelText: "Password"),
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
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                          color: Colors.transparent,
                                          width: 2.0), // Add border color and width
                                    ),
                                    title: const Text("Enter password"),
                                    content: Container(
                                      constraints: const BoxConstraints(maxWidth: 400),
                                      width: MediaQuery.of(context).size.width*.6,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min, // Set column to minimum size
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          InputTextField(
                                            controller: _passwordConfirmController,
                                            errorText: state[2]
                                                ? ""
                                                : "Password should be longer than 8 characters.",
                                            labelText: "Password"),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GreenElevatedButton(
                                                    text: "Confirm",
                                                    onPressed: () => _updateProfile(
                                                        userInfoCubit,
                                                        scaffoldMessenger)),
                                              ),
                                              Expanded(
                                                child: WhiteElevatedButton(
                                                    text: "Cancel",
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _createEditDialog();
                                                    }),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          }
                        }),
                  ),
                  Expanded(
                    child: WhiteElevatedButton(
                        text: "Cancel",
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                ],
              )
            ],
          );
        },
      ),
    )),
                        );
                      },
                    );
  }

  // Function to submit profile edits
  Future<void> _updateProfile(UserInfoCubit userInfoCubit,
      ScaffoldMessengerState scaffoldMessenger) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String email = widget.userCredential.user!.email as String;
    try {
      await auth.signInWithEmailAndPassword(
          email: email,
          password: _passwordConfirmController.text); // attempt to login

      userInfoCubit.setUserInfo(
          _userReference,
          _nameController.text,
          _emailController.text,
          _passwordController.text.isNotEmpty
              ? _passwordController.text
              : _passwordConfirmController.text);
      _passwordConfirmController.text = "";
      // _passwordController.text = "";
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
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
        content:
            Text("Profile updated successfully!")));
  }
}


Widget userIcon(){
      
      return const Icon(Icons.account_circle_outlined) ;

    }
Widget emailIcon(){
      
      return const Icon(Icons.mail_outline_outlined) ;

    }
Widget passwordIcon(){
      
      return const Icon(Icons.password_outlined) ;

    }
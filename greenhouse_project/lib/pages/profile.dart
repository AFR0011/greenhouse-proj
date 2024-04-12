/// TO-DO:
/// * Connect to database and fetch actual user data
/// * Make "edit" button functional
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class ProfilePage extends StatelessWidget {
  final UserCredential userCredential;

  const ProfilePage({super.key, required this.userCredential});

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

      ],
      child: _ProfilePageContent(userCredential: userCredential),
    );
  }
}
class _ProfilePageContent extends StatefulWidget {
  final UserCredential userCredential;

  const _ProfilePageContent ({super.key, required this.userCredential});

  @override
  State<_ProfilePageContent> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePageContent> {
  // Define custom theme
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

  // Define variables for user information

  @override
  void initState() {
    context.read<UserInfoCubit>().getUserInfo(widget.userCredential);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserInfoCubit, HomeState>(
      listener: (context, state){},
      builder: (context, state){
        if (state is UserInfoLoading){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        else if (state is UserInfoLoaded){
          return MaterialApp(
              theme: customTheme,
              home: Scaffold(
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
                      child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.green[400],
                            labelText: state.userName,
                            border: const OutlineInputBorder(),
                          )),
                    ),
                    const Text("Email"),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.green[400],
                            labelText: widget.userCredential.user?.email,
                            border: const OutlineInputBorder(),
                          )),
                    ),
                    const Text("Password"),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.green[400],
                            labelText: '********',
                            border: const OutlineInputBorder(),
                          )),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: GreenElevatedButton(text: "Edit", onPressed: () {}))
                  ],
                ),
              ));
        }
        else if (state is UserInfoError) {
          return Center(child: Text('Error: ${state.errorMessage}'));
        }
        // Should never happen; but, you never know
        else {
          return const Center(
            child: Text('Unexpected state'),
          );
        }
      },

    );

  }
}

/// Login page - login to the app
///
/// TODO:
/// - Handle animation with Cubits
/// - Convert state management stuff
/// - Review cubit usage; builder and listener usage might be unnecessary
library;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/auth_cubit.dart';
import 'package:greenhouse_project/utils/theme.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Firebase authentication init
  FirebaseAuth auth = FirebaseAuth.instance;

  // Show/hide password
  bool _isSecurePassword = true;

  // Dispose of controllers for better performance
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Initialize state for animation
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    passwordController.text = "123456";
    emailController.text = "admin2@admin.com";

    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: WavePainter1(),
              child: Transform(
                transform: Matrix4.rotationZ(3),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('lib/utils/Icons/leaf_pat.jpg'),
                        fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: WavePainter(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
              ),
            ),
          ),
          BlocConsumer<AuthCubit, AuthState>(
            builder: (context, state) {
              // Show "loading screen" if auth request is being processed
              if (state is AuthLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              context.read<AuthCubit>().checkLoggedIn();
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('lib/utils/Icons/logo.png'),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            width: MediaQuery.of(context).size.width * .6,
                            child: TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: theme.colorScheme.secondary
                                    .withOpacity(0.5),
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            width: MediaQuery.of(context).size.width * .6,
                            child: TextField(
                              controller: passwordController,
                              obscureText: _isSecurePassword,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white70.withOpacity(0.5),
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                suffixIcon: togglePassword(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AuthCubit>().authLoginRequest(
                                  emailController.text.trim(),
                                  passwordController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                            ),
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            listener: (context, state) {
              // If authentication is successful, navigate to home page
              if (state is AuthSuccess) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomePage(userCredential: state.userCredential)),
                    (route) => false);
                // If authentication is unsuccessful, display error message
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ]),
      ),
    );
  }

  Widget togglePassword() {
    return IconButton(
        onPressed: () {
          setState(() {
            _isSecurePassword = !_isSecurePassword;
          });
        },
        icon: _isSecurePassword
            ? Icon(Icons.visibility)
            : Icon(Icons.visibility_off),
        color: Colors.grey);
  }
}

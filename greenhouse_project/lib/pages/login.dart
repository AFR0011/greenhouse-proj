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
import 'package:greenhouse_project/utils/bakground.dart';
import 'package:greenhouse_project/utils/input.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
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
    passwordController.text = "12345678";
    emailController.text = "admin@admin.com";

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: WavePainter1(),
              child: Container(
                height: 300,
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
                height: 300,
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
            return Stack(children: [
              // Background
              // Content
              Padding(
                padding: const EdgeInsets.all(25.0),
                child:SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                    
                      const Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Text(
                          "Greenhouse Control System",
                          style: headingTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: theme.colorScheme.secondary,
                          labelText: 'Email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextField(
                        controller: passwordController,
                        obscureText:  _isSecurePassword,
                        decoration:  InputDecoration(
                          filled: true,
                          fillColor: Colors.white70,
                          labelText: 'Password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          suffixIcon: togglePassword(),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthCubit>().authLoginRequest(
                              emailController.text.trim(), passwordController.text);
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
            ]);
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
     ] ),
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


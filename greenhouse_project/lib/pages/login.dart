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
import 'package:greenhouse_project/utils/text_styles.dart';
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
  bool _isSecurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        builder: (context, state) {
          // Show "loading screen" if auth request is being processed
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Stack(children: [
            // Background
            SeaBackground(),
            // Content
            Padding(
              padding: const EdgeInsets.all(25.0),
              child:SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("lib/utils/Icons/Logo.png", width: 90, height: 90),
                  
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
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white70,
                        labelText: 'Email',
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
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
    );
  }
  Widget togglePassword(){
      
      return IconButton(onPressed: (){
        setState(() {
      _isSecurePassword = !_isSecurePassword;
      });
      }, icon: _isSecurePassword ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
      color: Colors.grey ); 

    }
}

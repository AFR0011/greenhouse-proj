/// Settings page - program settings and preferences
///
/// TODO:
/// - Add brightness mode toggle
/// - Add notification preferences
/// - Delegate signout function to AuthCubit
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/pages/login.dart';
import 'package:greenhouse_project/services/cubit/auth_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

// ignore: must_be_immutable
class SettingsPage extends StatelessWidget {
  final UserCredential userCredential;

  const SettingsPage({super.key, required this.userCredential});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
        BlocProvider(
          create: (context) => UserInfoCubit(),
        ),
        BlocProvider(create: (context) => NotificationsCubit(userCredential))
      ],
      child: SettingsPageContent(
        userCredential: userCredential,
      ),
    );
  }
}

class SettingsPageContent extends StatefulWidget {
  UserCredential? userCredential;

  SettingsPageContent({super.key, required this.userCredential});

  @override
  State<SettingsPageContent> createState() => _SettingsPageContentState();
}

class _SettingsPageContentState extends State<SettingsPageContent> {
  // Define custom theme
  final ThemeData customTheme = theme;

  @override
  void initState() {
    context.read<UserInfoCubit>().getUserInfo(widget.userCredential!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
        listener: (context, state) async {
          widget.userCredential = null;
          if (state is! AuthSuccess) {
            Navigator.popUntil(context, (route) => false);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));
          }
        },
        child: Theme(
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
                      "Settings",
                      style: headingTextStyle,
                    ),
                  )),
              body: Column(
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          "",
                          style: subheadingTextStyle,
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                          child: null),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GreenElevatedButton(
                        text: "Sign Out",
                        onPressed: () =>
                            context.read<AuthCubit>().authLogoutRequest()),
                  )
                ],
              ),
            )));
  }
}

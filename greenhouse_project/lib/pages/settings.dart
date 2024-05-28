/// Settings page - program settings and preferences
///
/// TODO:
/// - Add brightness mode toggle
/// - Add notification preferences
/// - Delegate signout function to AuthCubit
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/firebase_options.dart';
import 'package:greenhouse_project/pages/login.dart';
import 'package:greenhouse_project/services/cubit/auth_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

const String webVapidKey =
    "BKWvS-G0BOBMCAmBJVz63de5kFb5R2-OVxrM_ulKgCoqQgVXSY8FqQp7QM5UoC5S9hKs5crmzhVJVyyi_sYDC9I";

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

// ignore: must_be_immutable
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
    super.initState();
    _initializeUserInfo();
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
              appBar: createAltAppbar(context, "Settings"),
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
                    image: const AssetImage('lib/utils/Icons/setting_bg.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.1),
                      BlendMode.dstATop,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Notifications switch
                          const Text(
                            "Notifications",
                            style: subheadingTextStyle,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: LiteRollingSwitch(
                              value: true,
                              textOn: "On",
                              textOff: "Off",
                              colorOn: Colors.greenAccent,
                              colorOff: Colors.redAccent,
                              iconOn: Icons.done,
                              iconOff: Icons.alarm_off,
                              textSize: 18.0,
                              width: 130,
                              onTap: () {},
                              onSwipe: () {},
                              onDoubleTap: () {},
                              onChanged: (bool position) {
                                // context
                                //     .read<NotificationsCubit>()
                                //     .toggleNotifications(position);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Dark mode switch
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Dark Mode",
                            style: subheadingTextStyle,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: LiteRollingSwitch(
                              value: true,
                              textOn: "On",
                              textOnColor: Colors.white,
                              textOff: "Off",
                              textOffColor: Colors.black,
                              colorOn: Colors.black,
                              colorOff: Colors.grey.shade400,
                              iconOn: Icons.dark_mode,
                              iconOff: Icons.light_mode_outlined,
                              textSize: 18.0,
                              width: 130,
                              onTap: () {},
                              onSwipe: () {},
                              onDoubleTap: () {},
                              onChanged: (bool position) {
                                // Set theme to "dark" for "true"
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //Sign Out Button
              floatingActionButton: GreenElevatedButton(
                  text: "Sign Out",
                  onPressed: () =>
                      context.read<AuthCubit>().authLogoutRequest()),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            )));
  }

  Future<void> _initializeUserInfo() async {
    try {
      if (DefaultFirebaseOptions.currentPlatform !=
          DefaultFirebaseOptions.android) {
        context.read<UserInfoCubit>().getUserInfo(widget.userCredential!, null);
      } else {
        String? deviceFcmToken =
            await FirebaseMessaging.instance.getToken(vapidKey: webVapidKey);
        if (mounted) {
          context
              .read<UserInfoCubit>()
              .getUserInfo(widget.userCredential!, deviceFcmToken);
        }
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }
}

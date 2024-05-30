/// Equipment page - view and modify equipment status
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/firebase_options.dart';
import 'package:greenhouse_project/services/cubit/equipment_status_cubit.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/input.dart';
import 'package:greenhouse_project/utils/theme.dart';

const String webVapidKey =
    "BKWvS-G0BOBMCAmBJVz63de5kFb5R2-OVxrM_ulKgCoqQgVXSY8FqQp7QM5UoC5S9hKs5crmzhVJVyyi_sYDC9I";

class EquipmentPage extends StatelessWidget {
  final UserCredential userCredential; // user auth credentials

  const EquipmentPage({super.key, required this.userCredential});

  @override
  Widget build(BuildContext context) {
    // Provide Cubits for state management
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserInfoCubit(),
        ),
        BlocProvider(
          create: (context) => FooterNavCubit(),
        ),
        BlocProvider(
          create: (context) => NotificationsCubit(userCredential),
        ),
        BlocProvider(
          create: (context) => EquipmentStatusCubit(),
        ),
      ],
      child: _EquipmentPageContent(userCredential: userCredential),
    );
  }
}

class _EquipmentPageContent extends StatefulWidget {
  final UserCredential userCredential; // user auth credentials

  const _EquipmentPageContent({required this.userCredential});

  @override
  State<_EquipmentPageContent> createState() => _EquipmentPageContentState();
}

// Main page content goes here
class _EquipmentPageContentState extends State<_EquipmentPageContent> {
  late DocumentReference _userReference;
  // Custom theme
  final ThemeData customTheme = theme;

  // Dispose (destructor)
  @override
  void dispose() {
    super.dispose();
  }

  // InitState - get user info state to check authentication later
  @override
  void initState() {
    super.initState();
    _initializeUserInfo();
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
        // Initiate page creation once user info is loaded
        // Show content once user info is loaded
        else if (state is UserInfoLoaded) {
          _userReference = state.userReference;
          // Call function to create equipment page
          return Theme(data: customTheme, child: _createEquipmentPage());
        }
        // Show error if there are issues with user info
        else if (state is UserInfoError) {
          return Center(child: Text('Error: ${state.errorMessage}'));
        }
        // If somehow state doesn't match predefined states;
        // never happens; but, anything can happen
        else {
          return const Center(child: Text('Unexpected State'));
        }
      },
    );
  }

  // Create equipment page function
  Widget _createEquipmentPage() {
    return Scaffold(
      appBar: createAltAppbar(context, "Equipments"),
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
            image: const AssetImage('lib/utils/Icons/pattern.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.2),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // BlocBuilder for Equipment Status
              BlocBuilder<EquipmentStatusCubit, EquipmentStatusState>(
                builder: (context, state) {
                  // Show "loading screen" if processing equipment state
                  if (state is StatusLoading) {
                    return const Center(child: CircularProgressIndicator());
                    // Show equipment status once equipment status state is loaded
                  } else if (state is StatusLoaded) {
                    List<EquipmentStatus> equipmentList =
                        state.status; //equipment list
                    // Display nothing if no equipment
                    if (equipmentList.isEmpty) {
                      return const Center(child: Text("No Equipments..."));
                    }
                    // Display equipment
                    else {
                      final imgpath = [
                        {'path': "lib/utils/Icons/pump.png"},
                        {'path': "lib/utils/Icons/idea.png"},
                        {'path': "lib/utils/Icons/fan.png"},
                      ] as List<Map<String, dynamic>>;
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      (MediaQuery.of(context).size.width < 650)
                                          ? 2
                                          : 4),
                          shrinkWrap: false,
                          itemCount: equipmentList.length,
                          itemBuilder: (context, index) {
                            EquipmentStatus equipment =
                                equipmentList[index]; //equipment data
                            // Display equipment info
                            return ToggleButtonContainer(
                              context: context,
                              equipment: equipment,
                              userReference: _userReference,
                              imgPath: imgpath[index]['path'],
                            );
                          },
                        ),
                      );
                    }
                  }
                  // Show error message once an error occurs
                  else if (state is StatusError) {
                    return Center(child: Text('Error: ${state.error}'));
                  }
                  // If the state is not any of the predefined states;
                  // never happens; but, anything can happen
                  else {
                    return const Center(child: Text('Unexpected State'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
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

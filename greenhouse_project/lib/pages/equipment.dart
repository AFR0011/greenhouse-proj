/// Equipment page - view and modify equipment status
/// TODO:
/// - Change equipment status references to equipment
///
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/equipment_status_cubit.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/greenhouse_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class EquipmentStatusPage extends StatelessWidget {
  final UserCredential userCredential; //User auth credentials

  const EquipmentStatusPage({super.key, required this.userCredential});

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
          create: (context) => EquipmentCubit(),
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
  final UserCredential userCredential; // User auth credentials

  const _EquipmentPageContent({required this.userCredential});

  @override
  State<_EquipmentPageContent> createState() => _EquipmentPageContentState();
}

// Main page content goes here
class _EquipmentPageContentState extends State<_EquipmentPageContent> {
  // User info local variables
  late String _userRole = "";
  late String _userName = "";
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
        // Initiate page creation once user info is loaded
        else if (state is UserInfoLoaded) {
          // Store user info in local variables
          _userRole = state.userRole;
          _userName = state.userName;
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
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text("Equipment Status", style: headingTextStyle),
              ),
            ),
            // Use BlocBuilder for Equipment Status
            //STOPPED HERE!!!
            BlocBuilder<EquipmentStatusCubit, EquipmentStatusState>(
              builder: (context, state) {
                if (state is StatusLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is StatusLoaded) {
                  List<EquipmentStatus> equipmentList = state.status;
                  if (equipmentList.isEmpty) {
                    return const Center(child: Text("No Equipments..."));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: equipmentList.length,
                      itemBuilder: (context, index) {
                        EquipmentStatus equipment = equipmentList[index];
                        return ListTile(
                          title: Text(equipment.type),
                          subtitle: Text(equipment.status.toString()),
                          trailing: Switch(
                              value: equipment.status,
                              onChanged: (value) {
                                context
                                    .read<EquipmentStatusCubit>()
                                    .switchStatus(
                                        equipment.reference, equipment.status);
                              }),
                        );
                      },
                    );
                  }
                } else if (state is StatusError) {
                  return Center(child: Text('Error: ${state.error}'));
                } else {
                  return const Center(child: Text('Unexpected State'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
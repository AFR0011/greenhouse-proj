import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/equipment_status_cubit.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/greenhouse_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class EquipmentStatusPage extends StatelessWidget {
  final UserCredential userCredential;

  const EquipmentStatusPage({super.key, required this.userCredential});

  @override
  Widget build(BuildContext context) {
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
  final UserCredential userCredential;

  const _EquipmentPageContent({required this.userCredential});

  @override
  State<_EquipmentPageContent> createState() => _EquipmentPageContentState();
}

class _EquipmentPageContentState extends State<_EquipmentPageContent> {
  // User info
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;
  // Custom theme
  final ThemeData customTheme = theme;
  // Controllers
  final TextEditingController _textController = TextEditingController();
  // Index of footer nav selection
  final int _selectedIndex = 2;

  // Dispose of controllers for performance
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Get user info state
  @override
  void initState() {
    context.read<UserInfoCubit>().getUserInfo(widget.userCredential);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FooterNavCubit, int>(
      listener: (context, state) {
        navigateToPage(context, state, _userRole, widget.userCredential);
      },
      child: BlocConsumer<UserInfoCubit, HomeState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is UserInfoLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UserInfoLoaded) {
            // Assign user info
            _userRole = state.userRole;
            _userName = state.userName;
            _userReference = state.userReference;

            return Theme(data: customTheme, child: _buildEquipmentStausPage());
          } else if (state is UserInfoError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          } else {
            return const Center(child: Text('Unexpected State'));
          }
        },
      ),
    );
  }

  Widget _buildEquipmentStausPage() {
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);
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
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text("Equipment Status", style: headingTextStyle),
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, size: 24),
                  hintText: "Search...",
                ),
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
                            onChanged: (value){
                              context
                              .read<EquipmentStatusCubit>()
                              .switchStatus(equipment.reference, equipment.status);
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

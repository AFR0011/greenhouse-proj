/// TO-DO:
/// Replace ListView builders with BlocBuilders for
/// programs, equipment, and sensors
///
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/greenhouse_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class GreenhousePage extends StatelessWidget {
  final UserCredential userCredential;

  const GreenhousePage({super.key, required this.userCredential});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FooterNavCubit(),
        ),
        BlocProvider(
          create: (context) => NotificationsCubit(userCredential),
        ),
        BlocProvider(
          create: (context) => UserInfoCubit(),
        ),
        BlocProvider(
          create: (context) => ReadingsCubit(),
        ),
        BlocProvider(
          create: (context) => EquipmentCubit(),
        ),
        BlocProvider(
          create: (context) => ProgramsCubit(),
        ),
      ],
      child: _GreenhousePageContent(userCredential: userCredential),
    );
  }
}

class _GreenhousePageContent extends StatefulWidget {
  final UserCredential userCredential;

  const _GreenhousePageContent({required this.userCredential});

  @override
  State<_GreenhousePageContent> createState() => _GreenhousePageContentState();
}

class _GreenhousePageContentState extends State<_GreenhousePageContent> {
  // User info
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;
  // Custom theme
  final ThemeData customTheme = theme;
  // Text controllers
  final TextEditingController _textController = TextEditingController();
  // Index of footer nav selection
  final int _selectedIndex = 3;
  // List of sensors being measured
  final List<String> _sensors = [
    "gas",
    "humidity",
    "lightIntensity",
    "soilMoisture",
    "Temperature"
  ];

  // Dispose of controllers for performance
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Init to get user info state
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
          // Show "loading screen" if processing user info
          if (state is UserInfoLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Show content once user info is loaded
          else if (state is UserInfoLoaded) {
            // Assign user info
            _userRole = state.userRole;
            _userName = state.userName;
            _userReference = state.userReference;

            return MaterialApp(
                theme: customTheme, home: _buildGreenhousePage());
          }
          // Show error if there is an issues with user info
          else if (state is UserInfoError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          // Should never happen; but, you never know
          else {
            return const Center(child: Text('Unexpected State'));
          }
        },
      ),
    );
  }

  Widget _buildGreenhousePage() {
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);
    return Scaffold(
      appBar: createMainAppBar(context, widget.userCredential, _userReference),
      body: SingleChildScrollView(
        child: Column(children: [
          const Center(
              child: Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text("Greenhouse", style: headingTextStyle),
          )),
          // Search text field
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                  icon: Icon(Icons.search, size: 24), hintText: "Search..."),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Plant Status",
                    style: subheadingTextStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                  child: GreenElevatedButton(
                      text: "Details",
                      onPressed: () {
                        // TO-DO: Navigate to plant/sensor status page
                      }),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _sensors.map((sensor) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 400,
                      child: ChartClass(sensor: sensor)),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 35, 0, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Active Programs",
                    style: subheadingTextStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                  child: GreenElevatedButton(
                      text: "Details",
                      onPressed: () {
                        // TO-DO: Navigate to active programs page
                      }),
                ),
              ],
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: 0,
              itemBuilder: (context, index) {
                return const Text("hi");
              }),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 35, 0, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Equipment Status",
                    style: subheadingTextStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                  child: GreenElevatedButton(
                      text: "Details",
                      onPressed: () {
                        // TO-DO: Navigate to equipments page
                      }),
                ),
              ],
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: 0,
              itemBuilder: (context, index) {
                return const Text("hi");
              }),
        ]),
      ),
      bottomNavigationBar:
          createFooterNav(_selectedIndex, footerNavCubit, _userRole),
    );
  }
}

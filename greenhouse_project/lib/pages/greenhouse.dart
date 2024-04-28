/// Greenhouse page - contains links to the following subpages:
/// - Plants
/// - Programs
/// - Equipment
///
/// TODO:
/// - Remove _sensors list; data already available in readings cubit
/// - Improve code readability for scaffold body (line 153-*)
///
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/pages/equipment.dart';
import 'package:greenhouse_project/pages/plants.dart';
import 'package:greenhouse_project/pages/programs.dart';
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
  final UserCredential userCredential; //User auth credentials

  const GreenhousePage({super.key, required this.userCredential});

  @override
  Widget build(BuildContext context) {
    // Provide Cubits for state management
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
      ],
      child: _GreenhousePageContent(userCredential: userCredential),
    );
  }
}

class _GreenhousePageContent extends StatefulWidget {
  final UserCredential userCredential; //User auth credentials

  const _GreenhousePageContent({required this.userCredential});

  @override
  State<_GreenhousePageContent> createState() => _GreenhousePageContentState();
}

// Main page content goes here
class _GreenhousePageContentState extends State<_GreenhousePageContent> {
  // User info
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;

  // Custom theme
  final ThemeData customTheme = theme;

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
    // BlocListener for handling footer nav events
    return BlocListener<FooterNavCubit, int>(
      listener: (context, state) {
        navigateToPage(context, state, _userRole, widget.userCredential,
            userReference: _userReference);
      },
      // BlocBuilder for user info
      child: BlocBuilder<UserInfoCubit, HomeState>(
        builder: (context, state) {
          // Show "loading screen" if processing user info
          if (state is UserInfoLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Show content once user info is loaded
          else if (state is UserInfoLoaded) {
            // Assign user info to local variables
            _userRole = state.userRole;
            _userName = state.userName;
            _userReference = state.userReference;

            // Call function to create greenhouse page
            return Theme(data: customTheme, child: _createGreenhousePage());
          }
          // Show error if there is an issues with user info
          else if (state is UserInfoError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          // If somehow state doesn't match predefined states;
          // never happens; but, anything can happen
          else {
            return const Center(child: Text('Unexpected State'));
          }
        },
      ),
    );
  }

  // Create greenhouse page function
  Widget _createGreenhousePage() {
    // Get instance of footer nav cubit from main context
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);

    // Page content
    return Scaffold(
      // Main appbar (header)
      appBar: createMainAppBar(context, widget.userCredential, _userReference),

      // Scrollabe column for items
      body: SingleChildScrollView(
        child: Column(children: [
          // Title (Greenhouse)
          const Center(
              child: Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text("Greenhouse", style: headingTextStyle),
          )),

          // Plant status subheading and details button
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PlantsPage(
                                    userCredential: widget.userCredential)));
                      }),
                ),
              ],
            ),
          ),
          // Plant status graphs
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

          // Plant status subheading and details button
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProgramsPage(
                                    userCredential: widget.userCredential)));
                      }),
                ),
              ],
            ),
          ),

          // Plant status subheading and details button
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EquipmentStatusPage(
                                    userCredential: widget.userCredential)));
                      }),
                ),
              ],
            ),
          ),
        ]),
      ),

      // Footer nav bar
      bottomNavigationBar:
          createFooterNav(_selectedIndex, footerNavCubit, _userRole),
    );
  }
}

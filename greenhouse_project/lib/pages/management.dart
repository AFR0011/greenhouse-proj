/// Management page - links to subpages: workers and tasks
///
/// TODO:
/// -
///
library;

//import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/pages/tasks.dart';
import 'package:greenhouse_project/pages/employees.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/management_cubit.dart';
import 'package:greenhouse_project/utils/boxlink.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class ManagementPage extends StatelessWidget {
  final UserCredential userCredential; // user auth credentials

  const ManagementPage({super.key, required this.userCredential});

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
          create: (context) => ManageEmployeesCubit(userCredential),
        ),
      ],
      child: _ManagementPageContent(userCredential: userCredential),
    );
  }
}

class _ManagementPageContent extends StatefulWidget {
  final UserCredential userCredential; // user auth credentials

  const _ManagementPageContent({required this.userCredential});

  @override
  State<_ManagementPageContent> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<_ManagementPageContent> {
  // User info local variables
  late String _userRole = "";
  late DocumentReference _userReference;

  // Custom theme
  final ThemeData customTheme = theme;

  // Text controllers
  final TextEditingController _textController = TextEditingController();

  // Index of footer nav selection
  final int _selectedIndex = 0;

  // Dispose (destructor)
  @override
  void dispose() {
    _textController.dispose();
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
            _userReference = state.userReference;

            // Call function to create management page
            return Theme(data: customTheme, child: _createManagementPage());
          }
          // Show error if there is an issues with user info
          else if (state is UserInfoError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          // If somehow state doesn't match predefined states;
          // never happens; but, anything can happen
          // Show error if there is an issues with user info
          else if (state is UserInfoError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          // If somehow state doesn't match predefined states;
          // never happens; but, anything can happen
          else {
            return const Center(
              child: Text('Unexpected state'),
            );
          }
        },
      ),
    );
  }

  // Main page content
  Widget _createManagementPage() {
    // Get instance of footer nav cubit from main context
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);
    final pages = [
      {'route': MaterialPageRoute(
          builder: (context) => TasksPage(
              userCredential: widget.userCredential,
              userReference: _userReference)), "title": "Tasks", "icon": "lib/utils/Icons/bulb.png"},
      {'route': MaterialPageRoute(
          builder: (context) =>
              EmployeesPage(userCredential: widget.userCredential)),"title": "Employees", "icon": "lib/utils/Icons/bulb.png"}
    ] as List<Map<String, dynamic>>;
    // Page content;
    return Scaffold(
      // Main appbar (header)
      appBar: createMainAppBar(
          context, widget.userCredential, _userReference, "Management"),

      // Scrollable list of items
      // Tasks subsection
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: EdgeInsets.all(24.0),
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    mainAxisExtent: 250),
                shrinkWrap: true,
                itemCount: 2,
                itemBuilder: (context, index) {
                  return BoxLink(
                      text: pages[index]["title"],
                      imgPath: pages[index]["icon"],
                      context: context,
                      userReference: _userReference,
                      userCredential: widget.userCredential,
                      pageRoute: pages[index]["route"]);
                }),
          ),
        ]),
      ),

      // Footer nav bar
      bottomNavigationBar:
          createFooterNav(_selectedIndex, footerNavCubit, _userRole),
    );
  }
}

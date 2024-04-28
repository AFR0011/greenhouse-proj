import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/pages/profile.dart';
import 'package:greenhouse_project/pages/tasks.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/management_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class WorkersPage extends StatelessWidget {
  final UserCredential userCredential; //User auth credentials

  const WorkersPage({super.key, required this.userCredential});

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
        BlocProvider(create: (context) => ManageWorkersCubit(userCredential)),
      ],
      child: _WorkersPageContent(userCredential: userCredential),
    );
  }
}

class _WorkersPageContent extends StatefulWidget {
  final UserCredential userCredential; //User auth credentials

  const _WorkersPageContent({required this.userCredential});

  @override
  State<_WorkersPageContent> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<_WorkersPageContent> {
  // User info
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;
  // Custom theme
  final ThemeData customTheme = theme;
  // Text controllers
  final TextEditingController _textController = TextEditingController();
  // Index of footer nav selection
  final int _selectedIndex = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<UserInfoCubit>().getUserInfo(widget.userCredential);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get instance of footer nav cubit from main context
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);
    // BlocListener for handling footer nav events
    return BlocListener<FooterNavCubit, int>(
      listener: (context, state) {
        navigateToPage(context, state, _userRole, widget.userCredential,
            userReference: _userReference);
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
            return Theme(
              data: customTheme,
              child: _createWorkers(_userRole),
            );
          } else {
            return const Center(
              child: Text('Unexpected state'),
            );
          }
        },
      ),
    );
  }

  Widget _createWorkers(String _userRole) {
    // Get instance of footer nav cubit from main context
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          )),
      body: Column(
        children: [
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            child: const Text(
              "Workers",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          // BlocBuilder for workers
          BlocBuilder<ManageWorkersCubit, ManagementState>(
            builder: (context, state) {
              if (state is ManageWorkersLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ManageWorkersLoaded) {
                List<WorkerData> workerList = state.workers;
                if (workerList.isEmpty) {
                  return const Center(child: Text("No Workers..."));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: workerList.length,
                    itemBuilder: (context, index) {
                      WorkerData worker = workerList[index];
                      return ListTile(
                        title: Text(worker.name),
                        // subtitle: Text(worker.dueDate as String),
                        trailing: GreenElevatedButton(
                          text: 'Details',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                Widget buttonRow = Row(
                                  children: [
                                    GreenElevatedButton(
                                        text: "Tasks",
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TasksPage(
                                                        userCredential: widget
                                                            .userCredential,
                                                        userReference:
                                                            worker.reference,
                                                      )));
                                        }),
                                    GreenElevatedButton(
                                        text: "Show profile",
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfilePage(
                                                          userCredential: widget
                                                              .userCredential,
                                                          userReference: worker
                                                              .reference)));
                                        }),
                                    GreenElevatedButton(
                                        text: "Remove worker",
                                        onPressed: () {
                                          // TO-DO: Display confirmation prompt
                                        }),
                                  ],
                                );
                                return Dialog(
                                    child: Column(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.close)),
                                    Text("Title: ${worker.name}"),
                                    Text("Description: ${worker.surname}"),
                                    Text("Due Date: ${worker.email}"),
                                    Align(
                                        alignment: Alignment.bottomCenter,
                                        child: buttonRow)
                                  ],
                                ));
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              } else if (state is ManageWorkersError) {
                print(state.error.toString());
                return Center(child: Text(state.error.toString()));
              } // If the state is not any of the predefined states;
              // never happen; but, anything can happen
              else {
                return const Center(child: Text('Unexpected State'));
              }
            },
          ),
        ],
      ),
    );
  }
}

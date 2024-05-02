/// Workers page - CRUD for worker accounts
///
/// TODO:
/// - Implement "deleteWorker" function
///
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/pages/profile.dart';
import 'package:greenhouse_project/pages/tasks.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/management_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/theme.dart';

class WorkersPage extends StatelessWidget {
  final UserCredential userCredential; // user auth credentials

  const WorkersPage({super.key, required this.userCredential});

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
        BlocProvider(create: (context) => ManageWorkersCubit(userCredential)),
      ],
      child: _WorkersPageContent(userCredential: userCredential),
    );
  }
}

class _WorkersPageContent extends StatefulWidget {
  final UserCredential userCredential; // user auth credentials

  const _WorkersPageContent({required this.userCredential});

  @override
  State<_WorkersPageContent> createState() => _WorkersPageState();
}

// Main page content
class _WorkersPageState extends State<_WorkersPageContent> {
  // Custom theme
  final ThemeData customTheme = theme;

  // Text Controllers
  final TextEditingController _emailController = TextEditingController();

  // Text controllers
  final TextEditingController _textController = TextEditingController();

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
    return BlocBuilder<UserInfoCubit, HomeState>(
      builder: (context, state) {
        // Show "loading screen" if processing user info state
        if (state is UserInfoLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // Show content once user info is loaded
        else if (state is UserInfoLoaded) {
          // Function call to create workers page
          return Theme(data: customTheme, child: _createWorkersPage());
        } else {
          return const Center(
            child: Text('Unexpected state'),
          );
        }
      },
    );
  }

  // Function to create workers page
  Widget _createWorkersPage() {
    final ManageWorkersCubit manageWorkersCubit =
        BlocProvider.of<ManageWorkersCubit>(context);
    return Scaffold(
      // Appbar (header)
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
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: const Text(
                "Workers",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          // BlocBuilder for manageWorkers state
          BlocBuilder<ManageWorkersCubit, ManagementState>(
            builder: (context, state) {
              // Show "loading screen" if processing manageWorkers state
              if (state is ManageWorkersLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              // Show workers if manageWorkers state is loaded
              else if (state is ManageWorkersLoaded) {
                List<WorkerData> workerList = state.workers; // workers list

                // Display nothing if no workers
                if (workerList.isEmpty) {
                  return const Center(child: Text("No Workers..."));
                }
                // Display workers
                else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: workerList.length,
                    itemBuilder: (context, index) {
                      WorkerData worker = workerList[index]; // worker info
                      return ListTile(
                        title: Text(worker.name),
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
                                    // GreenElevatedButton(
                                    //     text: "Remove worker",
                                    //     onPressed: () {
                                    //       showDialog(
                                    //           context: context,
                                    //           builder: (context) {
                                    //             return Dialog(
                                    //                 child: Column(
                                    //               children: [
                                    //                 Center(
                                    //                   child: Text(
                                    //                       "Are you sure? This action is cannot be undone."),
                                    //                 ),
                                    //                 Center(
                                    //                   child: Row(
                                    //                     children: [
                                    //                       GreenElevatedButton(
                                    //                           text: "Confirm",
                                    //                           onPressed: () =>
                                    //                               manageWorkersCubit
                                    //                                   .deleteWorker(
                                    //                                       worker)),
                                    //                       GreenElevatedButton(
                                    //                           text: "Go Back",
                                    //                           onPressed: () =>
                                    //                               Navigator.pop(
                                    //                                   context)),
                                    //                     ],
                                    //                   ),
                                    //                 ),
                                    //               ],
                                    //             ));
                                    //           });
                                    //     }),
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
              }
              // Show error message once an error occurs
              else if (state is ManageWorkersError) {
                return Center(child: Text(state.error.toString()));
              }
              // If the state is not any of the predefined states;
              // never happens; but, anything can happen
              else {
                return const Center(child: Text('Unexpected State'));
              }
            },
          ),
          GreenElevatedButton(
              text: 'Add worker',
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: Column(
                          //Textfields
                          children: [
                            TextField(
                              controller: _emailController,
                            ),
                            //Submit or Cancel
                            Row(
                              children: [
                                GreenElevatedButton(
                                    text: 'Submit',
                                    onPressed: () async {
                                      await manageWorkersCubit
                                          .createWorker(_emailController.text);
                                          Navigator.pop(context);
                                      _emailController.clear();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "HI THERE, THIS WORKED!!!")));
                                    }),
                                GreenElevatedButton(
                                    text: 'Cancel',
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _emailController.clear();
                                    })
                              ],
                            )
                          ],
                        ),
                      );
                    });
              })
        ],
      ),
    );
  }
}

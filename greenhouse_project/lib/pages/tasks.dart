/// Tasks page - CRUD for worker tasks
///
/// TODO:
/// - Add task creation option
/// - Delete task
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/management_cubit.dart';
import 'package:greenhouse_project/services/cubit/task_cubit.dart';
import 'package:greenhouse_project/services/cubit/task_edit_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/theme.dart';

class TasksPage extends StatelessWidget {
  final UserCredential userCredential; // user auth credentials
  final DocumentReference? userReference;

  const TasksPage(
      {super.key, required this.userCredential, required this.userReference});

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
        BlocProvider(create: (context) => TaskCubit(userReference!)),
        BlocProvider(create: (context) => ManageWorkersCubit(userCredential)),
      ],
      child: _TasksPageContent(userCredential: userCredential),
    );
  }
}

class _TasksPageContent extends StatefulWidget {
  final UserCredential userCredential; // user auth credentials

  const _TasksPageContent({required this.userCredential});

  @override
  State<_TasksPageContent> createState() => _TasksPageState();
}

// Main page content
class _TasksPageState extends State<_TasksPageContent> {
  // User info local variables
  late String _userRole = "";
  late DocumentReference _userReference;

  // Custom theme
  final ThemeData customTheme = theme;

  // Text controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _duedateController = TextEditingController();

  // Index of footer nav selection
  final int _selectedIndex = 0;

  // Dispose (destructor)
  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _duedateController.dispose();
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

            // Function call to create tasks page
            return Theme(data: customTheme, child: _createTasksPage());
          } // Show error if there is an issues with user info
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

  Widget _createTasksPage() {
    // Get instance of footer nav cubit from main context
    final FooterNavCubit footerNavCubit =
        BlocProvider.of<FooterNavCubit>(context);
    final TaskCubit taskCubit = BlocProvider.of<TaskCubit>(context);
    late List<DropdownMenuItem> dropdownItems;
    late List<WorkerData> workers;
    return Scaffold(
      // Appbar (header)
      appBar: _userRole == "worker"
          ? createMainAppBar(context, widget.userCredential, _userReference)
          : AppBar(
              automaticallyImplyLeading: true,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              )),
      // Tasks section
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            child: const Text(
              "Tasks",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          // BlocBuilder for tasks
          BlocBuilder<TaskCubit, TaskState>(
            builder: (context, state) {
              // Show "loading screen" if processing tasks state
              if (state is TaskLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              // Show tasks if tasks state is loaded
              else if (state is TaskLoaded) {
                List<TaskData> taskList = state.tasks; // tasks list

                // Display nothing if no tasks
                if (taskList.isEmpty) {
                  return const Center(child: Text("No Tasks..."));
                }
                // Display tasks
                else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: taskList.length,
                    itemBuilder: (context, index) {
                      TaskData task = taskList[index]; // task info
                      return ListTile(
                        title: Text(task.title),
                        subtitle: Text(task.dueDate.toString()),
                        trailing: GreenElevatedButton(
                          text: 'Details',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                Widget buttonRow = _userRole == "worker"
                                    ? Row(
                                        children: [
                                          GreenElevatedButton(
                                              text: "Contact Manager",
                                              onPressed: () {}),
                                          GreenElevatedButton(
                                              text: "Mark as Complete",
                                              onPressed: () {
                                                context
                                                    .read<TaskCubit>()
                                                    .completeTask(
                                                        task.taskReference);
                                              })
                                        ],
                                      )
                                    : Row(children: [
                                        GreenElevatedButton(
                                            text: "Delete", onPressed: () {}),
                                        GreenElevatedButton(
                                            text: "Edit", onPressed: () {}),
                                        task.status == "waiting"
                                            ? GreenElevatedButton(
                                                text: "Approve",
                                                onPressed: () {})
                                            : const SizedBox(),
                                      ]);
                                return Dialog(
                                    child: Column(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.close)),
                                    Text("Title: ${task.title}"),
                                    Text("Description: ${task.description}"),
                                    Text("Due Date: ${task.dueDate}"),
                                    Text("Status: ${task.status}"),
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
              else if (state is TaskError) {
                return Center(child: Text(state.error.toString()));
              }
              // If the state is not any of the predefined states;
              // never happens; but, anything can happen
              else {
                return const Center(child: Text('Unexpected State'));
              }
            },
          ),

          // Get workers list
          BlocListener<ManageWorkersCubit, ManagementState>(
            listener: (context, state) {
              workers = state is ManageWorkersLoaded ? state.workers : [];
              dropdownItems = workers
                  .map(
                    (e) => DropdownMenuItem(
                        value: e.reference,
                        child: Text("${e.name} ${e.surname}")),
                  )
                  .toList();
            },
            child: GreenElevatedButton(
                text: 'Add Task',
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return BlocProvider(
                          create: (context) => TaskEditCubit(),
                          child: BlocBuilder<TaskEditCubit, List<dynamic>>(
                            builder: (context, state) {
                              return Dialog(
                                  child: Column(
                                children: [
                                  TextField(
                                    controller: _titleController,
                                    decoration: InputDecoration(
                                        errorText: state[0]
                                            ? ""
                                            : "Title should not be empty"),
                                  ),
                                  TextField(
                                    controller: _descController,
                                    decoration: InputDecoration(
                                        errorText: state[1]
                                            ? ""
                                            : "Description should not be empty"),
                                  ),
                                  DropdownButton(
                                      value: state[3],
                                      items: dropdownItems,
                                      onChanged: (selection) {
                                        DocumentReference worker = selection;
                                        context
                                            .read<TaskEditCubit>()
                                            .updateState(
                                                [true, true, state[2], worker]);
                                      }),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        2.5,
                                    child: CupertinoDatePicker(
                                        minimumDate: DateTime.now(),
                                        onDateTimeChanged: (selection) {
                                          context
                                              .read<TaskEditCubit>()
                                              .updateState([
                                            true,
                                            true,
                                            selection,
                                            state[3]
                                          ]);
                                        }),
                                  ),
                                  //Submit & Cancel
                                  Row(
                                    children: [
                                      GreenElevatedButton(
                                          text: 'Submit',
                                          onPressed: () {
                                            List<dynamic> validation = [
                                              true,
                                              true,
                                              state[2],
                                              state[3],
                                            ];
                                            if (_titleController.text.isEmpty) {
                                              validation[0] = false;
                                            }
                                            if (_descController.text.isEmpty) {
                                              validation[1] = false;
                                            }
                                            bool isValid = context
                                                .read<TaskEditCubit>()
                                                .updateState(validation);
                                            if (isValid) {
                                              taskCubit.addTask(
                                                _titleController.text,
                                                _descController.text,
                                                state[2],
                                                state[3],
                                              );
                                              showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                        child: Column(
                                                          children: [
                                                            const Center(
                                                              child: Text(
                                                                  "Task has been created!"),
                                                            ),
                                                            Center(
                                                              child:
                                                                  GreenElevatedButton(
                                                                      text:
                                                                          "OK",
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator.pop(
                                                                            context);
                                                                      }),
                                                            )
                                                          ],
                                                        ),
                                                      ));
                                            }
                                          }),
                                      GreenElevatedButton(
                                          text: 'Cancel',
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _titleController.clear();
                                            _descController.clear();
                                            _duedateController.clear();
                                          })
                                    ],
                                  )
                                ],
                              ));
                            },
                          ),
                        );
                      });
                }),
          ),
        ],
      ),

      // Footer nav bar
      bottomNavigationBar: _userRole == "worker"
          ? createFooterNav(
              _selectedIndex,
              footerNavCubit,
              _userRole,
            )
          : const SizedBox(),
    );
  }
}

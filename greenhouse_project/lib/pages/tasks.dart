import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/task_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/theme.dart';

class TasksPage extends StatelessWidget {
  final UserCredential userCredential;
  final DocumentReference? userReference;

  const TasksPage({super.key, required this.userCredential, required this.userReference});

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
        BlocProvider(create: (context) => TaskCubit(userReference!)),
      ],
      child: _TasksPageContent(userCredential: userCredential),
    );
  }
}

class _TasksPageContent extends StatefulWidget {
  final UserCredential userCredential;

  const _TasksPageContent({required this.userCredential});

  @override
  State<_TasksPageContent> createState() => _TasksPageState();
}

class _TasksPageState extends State<_TasksPageContent> {
  // User info
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;
  // Custom theme
  final ThemeData customTheme = theme;
  // Text Controllers
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
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);
    return BlocListener<FooterNavCubit, int>(
      listener: (context, state) {
        navigateToPage(context, state, _userRole, widget.userCredential, userReference: _userReference);
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
              child: _createTasks(_userRole),
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

  Widget _createTasks(String _userRole) {
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);
    return Scaffold(
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
      body: Column(
        children: [
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            child: const Text(
              "Tasks",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          // Use BlocBuilder for notifications
          BlocBuilder<TaskCubit, TaskState>(
            builder: (context, state) {
              if (state is TaskLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TaskLoaded) {
                List<TaskData> taskList = state.tasks;
                if (taskList.isEmpty) {
                  return const Center(child: Text("No Tasks..."));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: taskList.length,
                    itemBuilder: (context, index) {
                      TaskData task = taskList[index];
                      return ListTile(
                        title: Text(task.title),
                        // subtitle: Text(task.dueDate as String),
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
              } else if (state is TaskError) {
                print(state.error.toString());
                return Center(child: Text(state.error.toString()));
              } else {
                return const Center(child: Text('Unexpected State'));
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: _userRole == "worker"
          ? createFooterNav(_selectedIndex, footerNavCubit, _userRole,)
          : const SizedBox(),
    );
  }
}

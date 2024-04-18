import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/pages/tasks.dart';
import 'package:greenhouse_project/pages/workers.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/management_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class ManagementPage extends StatelessWidget {
  final UserCredential userCredential;

  const ManagementPage({super.key, required this.userCredential});

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
          create: (context) => ManageTasksCubit(userCredential),
        ),
        BlocProvider(
          create: (context) => ManageWorkersCubit(userCredential),
        ),
      ],
      child: _ManagementPageContent(userCredential: userCredential),
    );
  }
}

class _ManagementPageContent extends StatefulWidget {
  final UserCredential userCredential;

  const _ManagementPageContent({required this.userCredential});

  @override
  State<_ManagementPageContent> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<_ManagementPageContent> {
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

  // Dispose of controllers for better performance
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
            return Theme(data: customTheme, child: _buildManagementPage());
          }
          // Show error if there is an issues with user info
          else if (state is UserInfoError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          // Should never happen; but, you never know
          else {
            return const Center(
              child: Text('Unexpected state'),
            );
          }
        },
      ),
    );
  }

  Widget _buildManagementPage() {
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);

    return Scaffold(
      appBar: createMainAppBar(context, widget.userCredential, _userReference),
      body: SingleChildScrollView(
        child: Column(children: [
          const Center(
              child: Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text("Management", style: headingTextStyle),
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
                    "Tasks",
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
                                builder: (context) => TasksPage(
                                    userCredential: widget.userCredential)));
                      }),
                ),
              ],
            ),
          ),
          BlocBuilder<ManageTasksCubit, ManagementState>(
            builder: (context, state) {
              if (state is ManageTasksLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ManageTasksLoaded) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.tasks.length,
                  itemBuilder: (context, index) {
                    TaskData task = state.tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text(task.status),
                    );
                  },
                );
              } else {
                return const Text("Something went wrong...");
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 35, 0, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Workers",
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
                                builder: (context) => WorkersPage(
                                    userCredential: widget.userCredential)));
                      }),
                ),
              ],
            ),
          ),
          BlocBuilder<ManageWorkersCubit, ManagementState>(
            builder: (context, state) {
              if (state is ManageWorkersLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ManageWorkersLoaded) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.workers.length,
                  itemBuilder: (context, index) {
                    WorkerData worker = state.workers[index];
                    return ListTile(
                      title: Text("${worker.name} ${worker.surname}"),
                      subtitle: Text(worker.creationDate.toString()),
                    );
                  },
                );
              } else {
                return const Text("Something went wrong...");
              }
            },
          ),
        ]),
      ),
      bottomNavigationBar:
          createFooterNav(_selectedIndex, footerNavCubit, _userRole),
    );
  }
}

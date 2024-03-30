import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/theme.dart';

class TasksPage extends StatelessWidget {
  final UserCredential userCredential;

  const TasksPage({super.key, required this.userCredential});

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

  // Index of footer nav selection
  final int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);
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
            return MaterialApp(
              theme: customTheme,
              home: Scaffold(
                appBar: createMainAppBar(context, widget.userCredential),
                bottomNavigationBar:
                    createFooterNav(_selectedIndex, footerNavCubit, _userRole),
              ),
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
}

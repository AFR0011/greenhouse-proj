import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/theme.dart';

class ChatsPage extends StatelessWidget {
  final UserCredential userCredential;

  const ChatsPage({super.key, required this.userCredential});

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
      child: _ChatsPageContent(userCredential: userCredential),
    );
  }
}

class _ChatsPageContent extends StatefulWidget {
  final UserCredential userCredential;

  const _ChatsPageContent({required this.userCredential});

  @override
  State<_ChatsPageContent> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<_ChatsPageContent> {
  // User info
  late final String _userRole = "";
  late final String _userName = "";
  late DocumentReference _userReference;
  // Custom theme
  final ThemeData customTheme = theme;
  // Text Controllers
  final TextEditingController _textController = TextEditingController();
  // Index of footer nav selection
  final int _selectedIndex = 4;

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
    //footer nav state
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);

    // If footer nav state is updated, call handle navigation
    return BlocListener<FooterNavCubit, int>(
      listener: (context, state) {
        navigateToPage(context, state, _userRole, widget.userCredential);
      },
      child: BlocBuilder<UserInfoCubit, HomeState>(
        builder: (context, state) {
          // Show "loading screen" if processing user info
          if (state is UserInfoLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Show page content once user info is loaded
          else if (state is UserInfoLoaded) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: customTheme,
              home: Scaffold(
                appBar: createMainAppBar(context, widget.userCredential),
                bottomNavigationBar:
                    createFooterNav(_selectedIndex, footerNavCubit, _userRole),
              ),
            );
          }
          // Should never happen, but you never know
          else {
            return const Center(
              child: Text('Unexpected state'),
            );
          }
        },
      ),
    );
  }
}

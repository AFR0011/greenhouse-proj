import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/inventory_cubit.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/theme.dart';

class InventoryPage extends StatelessWidget {
  final UserCredential userCredential;

  const InventoryPage({super.key, required this.userCredential});

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
          create: (context) => InventoryCubit(),
        ),
      ],
      child: _InventoryPageContent(userCredential: userCredential),
    );
  }
}

class _InventoryPageContent extends StatefulWidget {
  final UserCredential userCredential;

  const _InventoryPageContent({required this.userCredential});

  @override
  State<_InventoryPageContent> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<_InventoryPageContent> {
  // User info
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;
  // Custom theme
  final ThemeData customTheme = theme;
  // Text Controllers
  final TextEditingController _textController = TextEditingController();
  // Index of footer nav selection
  final int _selectedIndex = 1;

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
    // If footer nav is updated, handle navigation
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

            return Theme(data: customTheme, child: _buildInventoryPage());
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

  Widget _buildInventoryPage() {
    // Footer nav state
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);

    return Scaffold(
      appBar: createMainAppBar(context, widget.userCredential, _userReference),
      body: BlocBuilder<InventoryCubit, InventoryState>(
          builder: (context, state) {
        if (state is InventoryLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is InventoryLoaded) {
          List<InventoryData> inventoryList = state.inventory;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: inventoryList.length,
            itemBuilder: (context, index) {
              InventoryData inventory = inventoryList[index];
              return ListTile(
                title: Text(inventory.name),
                subtitle: Text(inventory.timeAdded.toString()),
                trailing: Text(inventory.amount.toString()),
              );
            },
          );
        } else if (state is InventoryError) {
          print(state.error.toString());
          return Text(state.error.toString());
        } else {
          return const Text("Something went wrong...");
        }
      }),
      bottomNavigationBar:
          createFooterNav(_selectedIndex, footerNavCubit, _userRole),
    );
  }
}

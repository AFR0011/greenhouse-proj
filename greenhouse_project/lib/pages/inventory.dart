import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/inventory_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/main_appbar.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';
import 'package:list_utilities/list_utilities.dart';

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
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Index of footer nav selection
  final int _selectedIndex = 1;

  // Dispose of controllers for performance
  @override
  void dispose() {
    _textController.dispose();
    _equipmentController.dispose();
    _descController.dispose();
    _amountController.dispose();
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
        navigateToPage(context, state, _userRole, widget.userCredential,
            userReference: _userReference);
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
      body: SingleChildScrollView(
        child: BlocBuilder<InventoryCubit, InventoryState>(
            builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is InventoryLoaded) {
            List<InventoryData> inventoryList = state.inventory;
            List actualInventory = inventoryList.map((e) {
              if (!e.isPending) return e;
            }).toList();
            actualInventory.removeNull();
            List pendingInventory = inventoryList.map((e) {
              if (e.isPending) return e;
            }).toList();
            pendingInventory.removeNull();

            return _createInventoryList(
                actualInventory, pendingInventory, context);
          } else if (state is InventoryError) {
            print(state.error.toString());
            return Text(state.error.toString());
          } else {
            return const Text("Something went wrong...");
          }
        }),
      ),
      bottomNavigationBar:
          createFooterNav(_selectedIndex, footerNavCubit, _userRole),
    );
  }

  Widget _createInventoryList(
      List actualInventory, List pendingInventory, BuildContext context) {
    return Column(
      children: [
        const Text("Inventory", style: subheadingTextStyle),
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: actualInventory.length,
            itemBuilder: (context, index) {
              InventoryData inventory = actualInventory[index];
              return ListTile(
                title: Text(inventory.name),
                subtitle: Text(inventory.timeAdded.toString()),
                trailing: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        GreenElevatedButton(
                          text: "Edit",
                          onPressed: () {
                            _showEditForm(context, inventory);
                          },
                        ),
                        GreenElevatedButton(
                          text: "Delete",
                          onPressed: () {
                            _showDeleteForm(context, inventory);
                          },
                        ),
                      ],
                    )),
              );
            },
          ),
        ),
        const Text("Pending Updates", style: subheadingTextStyle),
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pendingInventory.length,
            itemBuilder: (context, index) {
              InventoryData inventory = pendingInventory[index];
              return ListTile(
                title: Text(inventory.name),
                subtitle: Text(inventory.timeAdded.toString()),
                trailing: Text(inventory.amount.toString()),
              );
            },
          ),
        ),
        Row(
          children: [
            GreenElevatedButton(
                text: "Add Item",
                onPressed: () {
                  _showAdditionForm(context);
                })
          ],
        )
      ],
    );
  }

  void _showAdditionForm(BuildContext context) {
    InventoryCubit inventoryCubit = BlocProvider.of<InventoryCubit>(context);
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Column(
              children: [
                TextField(
                  controller: _equipmentController,
                ),
                TextField(
                  controller: _descController,
                ),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                Row(
                  children: [
                    GreenElevatedButton(
                        text: "Submit",
                        onPressed: () async {
                          Map<String, dynamic> data = {
                            "amount": num.parse(_amountController.text),
                            "description": _descController.text,
                            "name": _equipmentController.text,
                            "timeAdded": DateTime.now(),
                            "pending": _userRole == 'manager' ? false : true,
                          };
                          await inventoryCubit.addInventory(data);
                          _equipmentController.clear();
                          _descController.clear();
                          _amountController.clear();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Item added succesfully")));
                        }),
                    GreenElevatedButton(
                        text: "Cancel",
                        onPressed: () {
                          _equipmentController.clear();
                          _descController.clear();
                          _amountController.clear();
                          Navigator.pop(context);
                        })
                  ],
                )
              ],
            ),
          );
        });
  }

  void _showEditForm(BuildContext context, InventoryData inventory) {
    InventoryCubit inventoryCubit = BlocProvider.of<InventoryCubit>(context);
    showDialog(
        context: context,
        builder: (context) {
          _equipmentController.text = inventory.name;
          _descController.text = inventory.description;
          _amountController.text = inventory.amount.toString();
          return Dialog(
            child: Column(
              children: [
                TextField(
                  controller: _equipmentController,
                ),
                TextField(
                  controller: _descController,
                ),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                Row(
                  children: [
                    GreenElevatedButton(
                        text: "Submit",
                        onPressed: () async {
                          Map<String, dynamic> data = {
                            "amount": num.parse(_amountController.text),
                            "description": _descController.text,
                            "name": _equipmentController.text,
                            "timeAdded": DateTime.now(),
                            "pending": _userRole == 'manager' ? false : true,
                          };
                          await inventoryCubit.updateInventory(
                              inventory.reference, data);
                          _equipmentController.clear();
                          _descController.clear();
                          _amountController.clear();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Item Edited succesfully")));
                        }),
                    GreenElevatedButton(
                        text: "Cancel",
                        onPressed: () {
                          _equipmentController.clear();
                          _descController.clear();
                          _amountController.clear();
                          Navigator.pop(context);
                        })
                  ],
                )
              ],
            ),
          );
        });
  }

  void _showDeleteForm(BuildContext context, InventoryData inventory) {
    InventoryCubit inventoryCubit = BlocProvider.of<InventoryCubit>(context);
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Column(
              children: [
                Text("Are you Sure!!!"),
                Row(
                  children: [
                    GreenElevatedButton(
                        text: "Submit",
                        onPressed: () async {
                          await inventoryCubit
                              .removeInventory(inventory.reference);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Item Deleted succesfully")));
                        }),
                    GreenElevatedButton(
                        text: "Cancel",
                        onPressed: () {
                          Navigator.pop(context);
                        })
                  ],
                )
              ],
            ),
          );
        });
  }
}

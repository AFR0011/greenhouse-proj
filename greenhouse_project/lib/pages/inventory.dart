/// Inventory page - CRUD for inventory items
///
/// TODO:
/// -
///
library;

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
  final UserCredential userCredential; //User auth credentials

  const InventoryPage({super.key, required this.userCredential});

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
          create: (context) => InventoryCubit(),
        ),
      ],
      child: _InventoryPageContent(userCredential: userCredential),
    );
  }
}

class _InventoryPageContent extends StatefulWidget {
  final UserCredential userCredential; //User auth credentials

  const _InventoryPageContent({required this.userCredential});

  @override
  State<_InventoryPageContent> createState() => _InventoryPageState();
}

// Main page content goes here
class _InventoryPageState extends State<_InventoryPageContent> {
  // User info
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;

  // Custom theme
  final ThemeData customTheme = theme;

  // Text controllers
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Index of footer nav selection
  final int _selectedIndex = 1;

  // Dispose (destructor)
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
    // BlocListener for handling footer nav events
    return BlocListener<FooterNavCubit, int>(
      listener: (context, state) {
        navigateToPage(context, state, _userRole, widget.userCredential,
            userReference: _userReference);
      },

      // BlocBuilder for user info
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
  Widget _buildInventoryPage() {
    // Get instance of footer nav cubit from main context
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);

    // Page content
    return Scaffold(
      // Main appbar (header)
      appBar: createMainAppBar(context, widget.userCredential, _userReference),

      // Scrollable list of items
      body: SingleChildScrollView(
        // BlocBuilder for inventory items
        child: BlocBuilder<InventoryCubit, InventoryState>(
            builder: (context, state) {
          // Show "loading screen" if processing equipment state
          if (state is InventoryLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Show inventory items once inventory state is loaded
          else if (state is InventoryLoaded) {
            // Separate pending and actual inventory items
            List<InventoryData> inventoryList = state.inventory;
            List actualInventory = inventoryList.map((e) {
              if (!e.isPending) return e;
            }).toList();
            actualInventory.removeNull();
            List pendingInventory = inventoryList.map((e) {
              if (e.isPending) return e;
            }).toList();
            pendingInventory.removeNull();

            // Function call to create inventory list
            return _createInventoryList(
                actualInventory, pendingInventory, context);
          }
          // Show error message once an error occurs
          else if (state is InventoryError) {
            print(state.error.toString());
            return Text(state.error.toString());
          }
          // If the state is not any of the predefined states;
          // never happen; but, anything can happen
          else {
            return const Text("Something went wrong...");
          }
        }),
      ),

      // Footer nav bar
      bottomNavigationBar:
          createFooterNav(_selectedIndex, footerNavCubit, _userRole),
    );
  }

  // Create inventory list function
  Widget _createInventoryList(
      List actualInventory, List pendingInventory, BuildContext context) {
    return Column(
      children: [
        // Main inventory items
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

                // Buttons for edit and deleting items
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

        // Pending inventory item updates
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

        // Add item button
        Row(
          children: [
            GreenElevatedButton(
                text: "Add Item",

                // Display addition form
                onPressed: () {
                  _showAdditionForm(context);
                })
          ],
        )
      ],
    );
  }

  // Item addition form function
  void _showAdditionForm(BuildContext context) {
    // Get instance of inventory cubit from main context
    InventoryCubit inventoryCubit = BlocProvider.of<InventoryCubit>(context);

    // Display item addition form
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

                // Submit and cancel buttons
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

  // Item edit form function
  void _showEditForm(BuildContext context, InventoryData inventory) {
    // Get instance of inventory cubit from main context
    InventoryCubit inventoryCubit = BlocProvider.of<InventoryCubit>(context);

    showDialog(
        context: context,
        builder: (context) {
          // Set controller values to current item values
          _equipmentController.text = inventory.name;
          _descController.text = inventory.description;
          _amountController.text = inventory.amount.toString();

          return Dialog(
            child: Column(
              // Textfields
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
                // Submit and Cancel buttons
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

  // Create item deletion form function
  void _showDeleteForm(BuildContext context, InventoryData inventory) {
    InventoryCubit inventoryCubit = BlocProvider.of<InventoryCubit>(context);
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Column(
              children: [
                const Text("Are you Sure?"),
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

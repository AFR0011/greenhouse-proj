/// Inventory page - CRUD for inventory items
///
/// TODO:
/// - Add form validation to delete, edit, and add operations
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/inventory_cubit.dart';
import 'package:greenhouse_project/services/cubit/inventory_edit_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/input.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';
import 'package:list_utilities/list_utilities.dart';

class InventoryPage extends StatelessWidget {
  final UserCredential userCredential; // user auth credentials

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
        BlocProvider(
          create: (context) => InventoryEditCubit(),
        ),
      ],
      child: _InventoryPageContent(userCredential: userCredential),
    );
  }
}

class _InventoryPageContent extends StatefulWidget {
  final UserCredential userCredential; // user auth credentials

  const _InventoryPageContent({required this.userCredential});

  @override
  State<_InventoryPageContent> createState() => _InventoryPageState();
}

// Main page content goes here
class _InventoryPageState extends State<_InventoryPageContent> {
  // User info local variables
  late String _userRole = "";
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

            // Call function to create inventory page
            return Theme(data: customTheme, child: _createInventoryPage());
          }
          // Show error if there is an issues with user info
          else if (state is UserInfoError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
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
  Widget _createInventoryPage() {
    // Get instance of footer nav cubit from main context
    final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);

    // Page content
    return Scaffold(
      // Main appbar (header)
      appBar: createMainAppBar(
          context, widget.userCredential, _userReference, "Inventory"),

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
            return Text(state.error.toString());
          }
          // If the state is not any of the predefined states;
          // never happens; but, anything can happen
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
                    child: WhiteElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                InventoryDetailsDialog(inventory: inventory));
                      },
                      text: "details",
                    )),
              );
            },
          ),
        ),

        // Pending inventory item updates
        const Text("Pending Updates", style: subheadingTextStyle),
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: pendingInventory.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: pendingInventory.length,
                  itemBuilder: (context, index) {
                    InventoryData inventory = pendingInventory[index];
                    return ListTile(
                      title: Text(inventory.name),
                      subtitle: Text(inventory.timeAdded.toString()),
                      trailing: _userRole == 'manager'
                          ? FittedBox(
                              child: Row(
                              children: [
                                GreenElevatedButton(
                                    text: "Approve",
                                    onPressed: () {
                                      context
                                          .read<InventoryCubit>()
                                          .approveItem(inventory.reference,
                                              _userReference);
                                    }),
                                GreenElevatedButton(
                                    text: "Deny",
                                    onPressed: () {
                                      context
                                          .read<InventoryCubit>()
                                          .removeInventory(inventory.reference,
                                              _userReference);
                                    })
                              ],
                            ))
                          : Text(inventory.amount.toString()),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    "No pending updates",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
        ),

        // Add item button
        Center(
          child: GreenElevatedButton(
              text: "Add Item",

              // Display addition form
              onPressed: () {
                _showAdditionForm(context);
              }),
        )
      ],
    );
  }

  // Item addition form function
  void _showAdditionForm(BuildContext context) {
    // Get instance of inventory cubit from main context
    InventoryCubit inventoryCubit = BlocProvider.of<InventoryCubit>(context);
    InventoryEditCubit inventoryEditCubit =
        BlocProvider.of<InventoryEditCubit>(context);

    // Display item addition form
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                        color: Colors.transparent,
                        width: 2.0), // Add border color and width
                  ),
                  title: const Text("Add item"),
            content: SizedBox(
              width: double.maxFinite,
              child: BlocBuilder<InventoryEditCubit, List<bool>>(
                bloc: inventoryEditCubit,
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min, // Set column to minimum size
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputTextField(controller: _equipmentController, errorText: state[0]
                                ? ""
                                : "Name should be longer than 1 characters.", labelText: "Name"),
                      // TextField(
                      //   controller: _equipmentController,
                      //   decoration: InputDecoration(
                      //       errorText: state[0]
                      //           ? ""
                      //           : "Name should be longer than 1 characters."),
                      // ),
                      InputTextField(controller: _descController, errorText: state[1]
                                ? ""
                                : "Description should be longer than 2 characters.", labelText: "Description"),
                      // TextField(
                      //   controller: _descController,
                      //   decoration: InputDecoration(
                      //       errorText: state[1]
                      //           ? ""
                      //           : "Description should be longer than 2 characters."),
                      // ),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          constraints:BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          labelText: "Amount",
                          filled: true,
                          fillColor: theme.colorScheme.secondary,
                            errorText:
                                state[2] ? "" : "Amount should be more than 0.",
                                border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                                ),
                      ),
              
                      // Submit and cancel buttons
                      Row(
                        children: [
                          Expanded(
                            child: GreenElevatedButton(
                                text: "Submit",
                                onPressed: () async {
                                  List<bool> validation = [true, true, true];
                                  if (_equipmentController.text.isEmpty) {
                                    validation[0] = !validation[0];
                                  }
                                  if (_descController.text.isEmpty) {
                                    validation[1] = !validation[1];
                                  }
                                  if (_amountController.text.isEmpty ||
                                      int.parse(_amountController.text) <= 0) {
                                    validation[2] = !validation[2];
                                  }
                                          
                                  bool isValid =
                                      inventoryEditCubit.updateState(validation);
                                  if (!isValid) {
                                  } else {
                                    Map<String, dynamic> data = {
                                      "amount": num.parse(_amountController.text),
                                      "description": _descController.text,
                                      "name": _equipmentController.text,
                                      "timeAdded": DateTime.now(),
                                      "pending":
                                          _userRole == 'manager' ? false : true,
                                    };
                                    await inventoryCubit
                                        .addInventory(data, _userReference)
                                        .then((value) {
                                      Navigator.pop(context);
                                      _equipmentController.clear();
                                      _descController.clear();
                                      _amountController.clear();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text("Item added succesfully")));
                                    });
                                  }
                                }),
                          ),
                          Expanded(
                            child: WhiteElevatedButton(
                                text: "Cancel",
                                onPressed: () {
                                  Navigator.pop(context);
                                  _equipmentController.clear();
                                  _descController.clear();
                                  _amountController.clear();
                                }),
                          )
                        ],
                      )
                    ],
                  );
                },
              ),
            ),
          );
        });
  }

  // Item edit form function
  void _showEditForm(BuildContext context, InventoryData inventory) {
    // Get instance of inventory cubit from main context
    InventoryCubit inventoryCubit = BlocProvider.of<InventoryCubit>(context);
    InventoryEditCubit inventoryEditCubit =
        BlocProvider.of<InventoryEditCubit>(context);

    showDialog(
        context: context,
        builder: (context) {
          // Set controller values to current item values
          _equipmentController.text = inventory.name;
          _descController.text = inventory.description;
          _amountController.text = inventory.amount.toString();

          return Dialog(
            child: BlocBuilder<InventoryEditCubit, List<bool>>(
              bloc: inventoryEditCubit,
              builder: (context, state) {
                return Column(
                  // Textfields
                  children: [
                    TextField(
                      controller: _equipmentController,
                      decoration: InputDecoration(
                          errorText: state[0]
                              ? ""
                              : "Name should be longer than 1 characters."),
                    ),
                    TextField(
                      controller: _descController,
                      decoration: InputDecoration(
                          errorText: state[1]
                              ? ""
                              : "Description should be longer than 2 characters."),
                    ),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                          errorText:
                              state[2] ? "" : "Amount should be more than 0."),
                    ),
                    // Submit and Cancel buttons
                    Row(
                      children: [
                        GreenElevatedButton(
                            text: "Submit",
                            onPressed: () async {
                              List<bool> validation = [true, true, true];
                              if (_equipmentController.text.length < 1) {
                                validation[0] = !validation[0];
                              }
                              if (_descController.text.length < 2) {
                                validation[1] = !validation[1];
                              }
                              if (_amountController.text.isEmpty ||
                                  int.parse(_amountController.text) <= 0) {
                                validation[2] = !validation[2];
                              }

                              bool isValid =
                                  inventoryEditCubit.updateState(validation);
                              if (!isValid) {
                              } else {
                                Map<String, dynamic> data = {
                                  "amount": num.parse(_amountController.text),
                                  "description": _descController.text,
                                  "name": _equipmentController.text,
                                  "timeAdded": DateTime.now(),
                                  "pending":
                                      _userRole == 'manager' ? false : true,
                                };

                                inventoryCubit
                                    .updateInventory(inventory.reference, data,
                                        _userReference)
                                    .then((value) {
                                  Navigator.pop(context);
                                  _equipmentController.clear();
                                  _descController.clear();
                                  _amountController.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Item Edited succesfully")));
                                });
                              }
                            }),
                        WhiteElevatedButton(
                            text: "Cancel",
                            onPressed: () {
                              Navigator.pop(context);
                              _equipmentController.clear();
                              _descController.clear();
                              _amountController.clear();
                            })
                      ],
                    )
                  ],
                );
              },
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
          return SimpleDialog(
              title: const Expanded(
                  child: Text(
                "Are you Sure?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        GreenElevatedButton(
                            text: "Submit",
                            onPressed: () async {
                              inventoryCubit
                                  .removeInventory(
                                      inventory.reference, _userReference)
                                  .then((value) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Item Deleted succesfully")));
                              });
                            }),
                        WhiteElevatedButton(
                            text: "Cancel",
                            onPressed: () {
                              Navigator.pop(context);
                            })
                      ],
                    )
                  ],
                ),
              ]);
        });
  }
}

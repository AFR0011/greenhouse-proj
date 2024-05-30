/// Inventory page - CRUD for inventory items
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/firebase_options.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/inventory_cubit.dart';
import 'package:greenhouse_project/services/cubit/inventory_edit_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/dialogs.dart';
import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/input.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';
import 'package:list_utilities/list_utilities.dart';

const String webVapidKey =
    "BKWvS-G0BOBMCAmBJVz63de5kFb5R2-OVxrM_ulKgCoqQgVXSY8FqQp7QM5UoC5S9hKs5crmzhVJVyyi_sYDC9I";

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
    super.initState();
    _initializeUserInfo();
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlueAccent.shade100.withOpacity(0.6),
              Colors.teal.shade100.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: DecorationImage(
            image: const AssetImage('lib/utils/Icons/leaf_pat.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.05),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: SingleChildScrollView(
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
      ),

      // Footer nav bar
      bottomNavigationBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade700,
                Colors.teal.shade400,
                Colors.blue.shade300
              ],
              stops: const [0.2, 0.5, 0.9],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              child:
                  createFooterNav(_selectedIndex, footerNavCubit, _userRole)),
        ),
      ),
      floatingActionButton: _userRole != "admin"
          ? GreenElevatedButton(
              text: "Add Item",
              // Display addition form
              onPressed: () {
                _showAdditionForm(context);
              })
          : null,
    );
  }

  // Create inventory list function
  Widget _createInventoryList(
      List actualInventory, List pendingInventory, BuildContext mainContext) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Main inventory items
          SizedBox(
              height: MediaQuery.of(context).size.height * .35,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: actualInventory.length,
                  itemBuilder: (context, index) {
                    InventoryData inventory = actualInventory[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 4.0,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.grey[600]!,
                            size: 30,
                          ),
                        ),

                        title: Text(
                          inventory.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(inventory.timeAdded.toString()),

                        // Buttons for edit and deleting items
                        trailing: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: WhiteElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) =>
                                        InventoryDetailsDialog(
                                            inventory: inventory,
                                            userRole: _userRole,
                                            editInventory: () => showEditForm(
                                                mainContext, inventory),
                                            deleteInventory: () =>
                                                showDeleteForm(
                                                    mainContext, inventory)));
                              },
                              text: "Details",
                            )),
                      ),
                    );
                  })),

          // Pending inventory item updates
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: const Text("Pending updates", style: subheadingTextStyle),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .25,
            child: pendingInventory.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: pendingInventory.length,
                    itemBuilder: (context, index) {
                      InventoryData inventory = pendingInventory[index];
                      return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 4.0,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.grey[600]!,
                                size: 30,
                              ),
                            ),
                            title: Text(
                              inventory.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
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
                                                .approveItem(
                                                    inventory.reference,
                                                    _userReference);
                                          }),
                                      RedElevatedButton(
                                          text: "Deny",
                                          onPressed: () {
                                            context
                                                .read<InventoryCubit>()
                                                .removeInventory(
                                                    inventory.reference,
                                                    _userReference);
                                          })
                                    ],
                                  ))
                                : Text(inventory.amount.toString()),
                          ));
                    },
                  )
                : const Center(
                    child: Text(
                      "No pending updates",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          )
        ],
      ),
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
              side: const BorderSide(
                  color: Colors.transparent,
                  width: 2.0), // Add border color and width
            ),
            title: const Text("Add item"),
            content: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                width: MediaQuery.of(context).size.width * .6,
                child: BlocBuilder<InventoryEditCubit, List<bool>>(
                  bloc: inventoryEditCubit,
                  builder: (context, state) {
                    return Column(
                      mainAxisSize:
                          MainAxisSize.min, // Set column to minimum size
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputTextField(
                            controller: _equipmentController,
                            errorText: state[0]
                                ? null
                                : "Name should be longer than 1 characters.",
                            labelText: "Name"),

                        InputTextField(
                            controller: _descController,
                            errorText: state[1]
                                ? null
                                : "Description should be longer than 2 characters.",
                            labelText: "Description"),

                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              labelText: "Amount",
                              filled: true,
                              fillColor: theme.colorScheme.secondary,
                              errorText: state[2]
                                  ? null
                                  : "Amount should be more than 0.",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
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
                                        int.parse(_amountController.text) <=
                                            0) {
                                      validation[2] = !validation[2];
                                    }

                                    bool isValid = inventoryEditCubit
                                        .updateState(validation);
                                    if (!isValid) {
                                    } else {
                                      Map<String, dynamic> data = {
                                        "amount":
                                            num.parse(_amountController.text),
                                        "description": _descController.text,
                                        "name": _equipmentController.text,
                                        "timeAdded": DateTime.now(),
                                        "pending": _userRole == 'manager'
                                            ? false
                                            : true,
                                      };
                                      await inventoryCubit
                                          .addInventory(data, _userReference)
                                          .then((value) {
                                        Navigator.pop(context);
                                        _equipmentController.clear();
                                        _descController.clear();
                                        _amountController.clear();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Item added succesfully!")));
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
            ),
          );
        });
  }

  // Item edit form function
  void showEditForm(BuildContext context, InventoryData inventory) {
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

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: const BorderSide(
                  color: Colors.transparent,
                  width: 2.0), // Add border color and width
            ),
            title: const Text("Edit inventory"),
            content: BlocBuilder<InventoryEditCubit, List<bool>>(
              bloc: inventoryEditCubit,
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    width: MediaQuery.of(context).size.width * .6,
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Set column to minimum size
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Textfields
                      children: [
                        InputTextField(
                            controller: _equipmentController,
                            errorText: state[0]
                                ? null
                                : "Name should be longer than 1 characters.",
                            labelText: "Name"),
                        InputTextField(
                            controller: _descController,
                            errorText: state[1]
                                ? null
                                : "Description should be longer than 2 characters.",
                            labelText: "Description"),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                labelText: "Amount",
                                filled: true,
                                fillColor: theme.colorScheme.secondary,
                                errorText: state[2]
                                    ? null
                                    : "Amount should be more than 0.",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              )),
                        ),
                        // Submit and Cancel buttons
                        Row(
                          children: [
                            Expanded(
                              child: GreenElevatedButton(
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
                                        int.parse(_amountController.text) <=
                                            0) {
                                      validation[2] = !validation[2];
                                    }

                                    bool isValid = inventoryEditCubit
                                        .updateState(validation);
                                    if (!isValid) {
                                    } else {
                                      Map<String, dynamic> data = {
                                        "amount":
                                            num.parse(_amountController.text),
                                        "description": _descController.text,
                                        "name": _equipmentController.text,
                                        "timeAdded": DateTime.now(),
                                        "pending": _userRole == 'manager'
                                            ? false
                                            : true,
                                      };

                                      inventoryCubit
                                          .updateInventory(inventory.reference,
                                              data, _userReference)
                                          .then((value) {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        _equipmentController.clear();
                                        _descController.clear();
                                        _amountController.clear();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Item edited succesfully!")));
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
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  // Create item deletion form function
  void showDeleteForm(BuildContext context, InventoryData inventory) {
    InventoryCubit inventoryCubit = BlocProvider.of<InventoryCubit>(context);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(
                    color: Colors.transparent,
                    width: 2.0), // Add border color and width
              ),
              title: Text("Are you sure?"),
              content: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  width: MediaQuery.of(context).size.width *
                      .6, // Set maximum width
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Set column to minimum size
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RedElevatedButton(
                                text: "Yes",
                                onPressed: () async {
                                  inventoryCubit
                                      .removeInventory(
                                          inventory.reference, _userReference)
                                      .then((value) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Item deleted succesfully!")));
                                  });
                                }),
                          ),
                          Expanded(
                            child: WhiteElevatedButton(
                                text: "No",
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ));
        });
  }

  Future<void> _initializeUserInfo() async {
    try {
      if (DefaultFirebaseOptions.currentPlatform !=
          DefaultFirebaseOptions.android) {
        context.read<UserInfoCubit>().getUserInfo(widget.userCredential, null);
      } else {
        String? deviceFcmToken =
            await FirebaseMessaging.instance.getToken(vapidKey: webVapidKey);
        if (mounted) {
          context
              .read<UserInfoCubit>()
              .getUserInfo(widget.userCredential, deviceFcmToken);
        }
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }
}

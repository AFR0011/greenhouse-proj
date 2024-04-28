import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
//import 'package:greenhouse_project/services/cubit/inventory_cubit.dart';
import 'package:greenhouse_project/services/cubit/programs_cubit.dart';
import 'package:greenhouse_project/services/cubit/program_edit_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
// import 'package:greenhouse_project/utils/footer_nav.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';
// import 'package:list_utilities/list_utilities.dart';

class ProgramsPage extends StatelessWidget {
  final UserCredential userCredential;

  const ProgramsPage({super.key, required this.userCredential});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NotificationsCubit(userCredential),
        ),
        BlocProvider(
          create: (context) => UserInfoCubit(),
        ),
        BlocProvider(
          create: (context) => ProgramsCubit(),
        ),
        BlocProvider(
          create: (context) => ProgramEditCubit(),
        )
      ],
      child: _ProgramsPageContent(userCredential: userCredential),
    );
  }
}

class _ProgramsPageContent extends StatefulWidget {
  final UserCredential userCredential;

  const _ProgramsPageContent({required this.userCredential});

  @override
  State<_ProgramsPageContent> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<_ProgramsPageContent> {
  // User info
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;
  // Custom theme
  final ThemeData customTheme = theme;
  // Text Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  //final TextEditingController _amountController = TextEditingController();

  // Index of footer nav selection
  //final int _selectedIndex = 1;

  // Dispose of controllers for performance
  @override
  void dispose() {
    _limitController.dispose();
    _titleController.dispose();
    //_amountController.dispose();
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
    return BlocConsumer<UserInfoCubit, HomeState>(
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

          return Theme(data: customTheme, child: _buildProgramsPage());
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
    );
  }

  Widget _buildProgramsPage() {
    // Footer nav state
    //final footerNavCubit = BlocProvider.of<FooterNavCubit>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          BlocBuilder<ProgramsCubit, ProgramsState>(builder: (context, state) {
        if (state is ProgramsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ProgramsLoaded) {
          List<ProgramData> programsList = state.programs;
          // List actualInventory = inventoryList.map((e) {
          //   if (!e.isPending) return e;
          // }).toList();
          // actualInventory.removeNull();
          // List pendingInventory = inventoryList.map((e) {
          //   if (e.isPending) return e;
          // }).toList();
          // pendingInventory.removeNull();

          return _createProgramsList(programsList, context);
        } else if (state is ProgramError) {
          print(state.error.toString());
          return Text(state.error.toString());
        } else {
          return const Text("Something went wrong...");
        }
      }),
      // bottomNavigationBar:
      //     createFooterNav(_selectedIndex, footerNavCubit, _userRole),
    );
  }

  Widget _createProgramsList(List programsList, BuildContext context) {
    return Column(
      children: [
        const Text("Programs", style: subheadingTextStyle),
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: programsList.length,
            itemBuilder: (context, index) {
              ProgramData program = programsList[index];
              return ListTile(
                title: Text(program.title),
                subtitle: Text(program.creationDate.toString()),
                trailing: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        GreenElevatedButton(
                          text: "Edit",
                          onPressed: () {
                            _showEditForm(context, program);
                          },
                        ),
                        GreenElevatedButton(
                          text: "Delete",
                          onPressed: () {
                            _showDeleteForm(context, program);
                          },
                        ),
                      ],
                    )),
              );
            },
          ),
        ),
        // const Text("Pending Updates", style: subheadingTextStyle),
        // SizedBox(
        //   height: MediaQuery.of(context).size.height / 3,
        //   child: ListView.builder(
        //     shrinkWrap: true,
        //     itemCount: pendingInventory.length,
        //     itemBuilder: (context, index) {
        //       InventoryData inventory = pendingInventory[index];
        //       return ListTile(
        //         title: Text(inventory.name),
        //         subtitle: Text(inventory.timeAdded.toString()),
        //         trailing: Text(inventory.amount.toString()),
        //       );
        //     },
        //   ),
        // ),
        Row(
          children: [
            GreenElevatedButton(
                text: "Create program",
                onPressed: () {
                  _showAdditionForm(context);
                })
          ],
        )
      ],
    );
  }

  void _showAdditionForm(BuildContext context) {
    ProgramsCubit programsCubit = BlocProvider.of<ProgramsCubit>(context);
    ProgramEditCubit programEditCubit =
        BlocProvider.of<ProgramEditCubit>(context);

    showDialog(
        context: context,
        builder: (context) {
          _limitController.text = '0';
          return Dialog(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                ),

                // TextFormField(
                //   controller: _limitController,
                //   keyboardType: TextInputType.number,
                //   inputFormatters: <TextInputFormatter>[
                //     FilteringTextInputFormatter.digitsOnly
                //   ],
                //   onChanged: (value) {
                //     if (value <)
                //   },
                // ),
                BlocBuilder<ProgramEditCubit, List<String>>(
                  bloc: programEditCubit,
                  builder: (context, state) {
                    List<String> dropdownValues = state;
                    return Column(
                      children: [
                        Slider(
                            value: double.parse(_limitController.text),
                            onChanged: (value) {
                              _limitController.text = value.toString();
                              programEditCubit.updateDropdown(dropdownValues);
                            }),
                        DropdownButton(
                            value: dropdownValues[0] != ""
                                ? dropdownValues[0]
                                : null,
                            items: const [
                              DropdownMenuItem(
                                child: Text('fan'),
                                value: 'fan',
                              ),
                              DropdownMenuItem(
                                child: Text('pump'),
                                value: 'pump',
                              ),
                              DropdownMenuItem(
                                child: Text('light'),
                                value: 'light',
                              ),
                            ],
                            onChanged: (selection) {
                              dropdownValues[0] = selection!;
                              programEditCubit.updateDropdown(dropdownValues);
                            }),
                        DropdownButton(
                            value: dropdownValues[1] != ""
                                ? dropdownValues[1]
                                : null,
                            items: const [
                              DropdownMenuItem(
                                child: Text('off'),
                                value: 'off',
                              ),
                              DropdownMenuItem(
                                child: Text('on'),
                                value: 'on',
                              ),
                            ],
                            onChanged: (selection) {
                              dropdownValues[1] = selection!;
                              programEditCubit.updateDropdown(dropdownValues);
                            }),
                        DropdownButton(
                            value: dropdownValues[2] != ""
                                ? dropdownValues[2]
                                : null,
                            items: const [
                              DropdownMenuItem(
                                child: Text('less than'),
                                value: 'lt',
                              ),
                              DropdownMenuItem(
                                child: Text('greater than'),
                                value: 'gt',
                              ),
                            ],
                            onChanged: (selection) {
                              dropdownValues[2] = selection!;
                              programEditCubit.updateDropdown(dropdownValues);
                            }),
                      ],
                    );
                  },
                ),
                Row(
                  children: [
                    GreenElevatedButton(
                        text: "Submit",
                        onPressed: () async {
                          Map<String, dynamic> data = {
                            //"amount": num.parse(_amountController.text),
                            "description": _limitController.text,
                            "name": _titleController.text,
                            "timeAdded": DateTime.now(),
                            "pending": _userRole == 'manager' ? false : true,
                          };
                          await programsCubit.addProgram(data);
                          _titleController.clear();
                          _limitController.clear();
                          //_amountController.clear();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Item added succesfully")));
                        }),
                    GreenElevatedButton(
                        text: "Cancel",
                        onPressed: () {
                          _titleController.clear();
                          _limitController.clear();
                          //_amountController.clear();
                          Navigator.pop(context);
                        })
                  ],
                )
              ],
            ),
          );
        });
  }

  void _showEditForm(BuildContext context, ProgramData program) {
    ProgramsCubit programsCubit = BlocProvider.of<ProgramsCubit>(context);
    showDialog(
        context: context,
        builder: (context) {
          _titleController.text = program.title;
          _limitController.text = program.creationDate.toString();
          // _amountController.text = inventory.amount.toString();
          return Dialog(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                ),
                TextField(
                  controller: _limitController,
                ),
                TextFormField(
                  //controller: _amountController,
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
                            // "amount": num.parse(_amountController.text),
                            "title": _limitController.text,
                            // "name": _titleController.text,
                            "creationDate": DateTime.now(),
                            "pending": _userRole == 'manager' ? false : true,
                          };
                          await programsCubit.updatePrograms(
                              program.reference, data);
                          _titleController.clear();
                          _limitController.clear();
                          //_amountController.clear();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Program edited succesfully")));
                        }),
                    GreenElevatedButton(
                        text: "Cancel",
                        onPressed: () {
                          _titleController.clear();
                          _limitController.clear();
                          //_amountController.clear();
                          Navigator.pop(context);
                        })
                  ],
                )
              ],
            ),
          );
        });
  }

  void _showDeleteForm(BuildContext context, ProgramData program) {
    ProgramsCubit programsCubit = BlocProvider.of<ProgramsCubit>(context);
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
                          await programsCubit.removeProgram(program.reference);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Program Deleted succesfully")));
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

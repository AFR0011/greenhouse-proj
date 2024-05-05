/// Programs page - CRUD for arduino-side programs
///
/// TODO:
/// - Update code to submit relevant data (line 311-*)
/// - (then) make API call to sync databases
/// - Fix context usage in async gaps
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/programs_cubit.dart';
import 'package:greenhouse_project/services/cubit/program_edit_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class ProgramsPage extends StatelessWidget {
  final UserCredential userCredential; // user auth credentials

  const ProgramsPage({super.key, required this.userCredential});

  @override
  Widget build(BuildContext context) {
    // Provide Cubits for state management
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
      ],
      child: _ProgramsPageContent(userCredential: userCredential),
    );
  }
}

class _ProgramsPageContent extends StatefulWidget {
  final UserCredential userCredential; // user auth credentials

  const _ProgramsPageContent({required this.userCredential});

  @override
  State<_ProgramsPageContent> createState() => _ProgramsPageState();
}

// Main page content
class _ProgramsPageState extends State<_ProgramsPageContent> {
  // User info local variables
  late DocumentReference userReference;
  late String _userRole = "";

  // Custom theme
  final ThemeData customTheme = theme;

  // Text controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();

  // Dispose (destructor)
  @override
  void dispose() {
    _limitController.dispose();
    _titleController.dispose();
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
    // BlocBuilder for user info state
    return BlocBuilder<UserInfoCubit, HomeState>(
      builder: (context, state) {
        // Show "loading screen" if processing user info
        if (state is UserInfoLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } // Show content once user info is loaded
        else if (state is UserInfoLoaded) {
          // Assign user info to local variables
          _userRole = state.userRole;
          state.userReference;

          // Function call to create programs page
          return Theme(data: customTheme, child: _createProgramsPage());
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
    );
  }

  // Function to create programs page
  Widget _createProgramsPage() {
    return Scaffold(
      // Appbar (header)
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // Blocbuilder for programs state
      body:
          BlocBuilder<ProgramsCubit, ProgramsState>(builder: (context, state) {
        // Show "loading screen" if processing programs state
        if (state is ProgramsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // Show programs once programs state is loaded
        else if (state is ProgramsLoaded) {
          List<ProgramData> programsList = state.programs; // programs list
          // Function call to create programs list
          return _createProgramsList(programsList);
        } // Show error if there is an issues with user info
        else if (state is ProgramsError) {
          return Center(child: Text('Error: ${state.error}'));
        }
        // If somehow state doesn't match predefined states;
        // never happens; but, anything can happen
        else {
          return const Center(
            child: Text('Unexpected state'),
          );
        }
      }),
    );
  }

  // Function call to create programs list
  Widget _createProgramsList(List programsList) {
    return Column(
      children: [
        const Text("Programs", style: subheadingTextStyle),
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: programsList.length,
            itemBuilder: (context, index) {
              ProgramData program = programsList[index]; // program info
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
                            _showEditForm(program);
                          },
                        ),
                        GreenElevatedButton(
                          text: "Delete",
                          onPressed: () {
                            _showDeleteForm(program);
                          },
                        ),
                      ],
                    )),
              );
            },
          ),
        ),
        Row(
          children: [
            GreenElevatedButton(
                text: "Create program",
                onPressed: () {
                  _showAdditionForm();
                })
          ],
        )
      ],
    );
  }

  // Function to show program creation form
  void _showAdditionForm() {
    // Get instances of programs cubit from main context
    ProgramsCubit programsCubit = BlocProvider.of<ProgramsCubit>(context);

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
                BlocProvider(
                  create: (context) => ProgramEditCubit(),
                  child: BlocBuilder<ProgramEditCubit, List<String>>(
                    builder: (context, state) {
                      List<String> dropdownValues = state;
                      return Column(
                        children: [
                          Slider(
                              value: double.parse(_limitController.text),
                              onChanged: (value) {
                                _limitController.text = value.toString();
                                context
                                    .read<ProgramEditCubit>()
                                    .updateDropdown(dropdownValues);
                              }),
                          DropdownButton(
                              value: dropdownValues[0] != ""
                                  ? dropdownValues[0]
                                  : null,
                              items: const [
                                DropdownMenuItem(
                                  value: 'fan',
                                  child: Text('fan'),
                                ),
                                DropdownMenuItem(
                                  value: 'pump',
                                  child: Text('pump'),
                                ),
                                DropdownMenuItem(
                                  value: 'light',
                                  child: Text('light'),
                                ),
                              ],
                              onChanged: (selection) {
                                dropdownValues[0] = selection!;
                                context
                                    .read<ProgramEditCubit>()
                                    .updateDropdown(dropdownValues);
                              }),
                          DropdownButton(
                              value: dropdownValues[1] != ""
                                  ? dropdownValues[1]
                                  : null,
                              items: const [
                                DropdownMenuItem(
                                  value: 'off',
                                  child: Text('off'),
                                ),
                                DropdownMenuItem(
                                  value: 'on',
                                  child: Text('on'),
                                ),
                              ],
                              onChanged: (selection) {
                                dropdownValues[1] = selection!;
                                context
                                    .read<ProgramEditCubit>()
                                    .updateDropdown(dropdownValues);
                              }),
                          DropdownButton(
                              value: dropdownValues[2] != ""
                                  ? dropdownValues[2]
                                  : null,
                              items: const [
                                DropdownMenuItem(
                                  value: 'lt',
                                  child: Text('less than'),
                                ),
                                DropdownMenuItem(
                                  value: 'gt',
                                  child: Text('greater than'),
                                ),
                              ],
                              onChanged: (selection) {
                                dropdownValues[2] = selection!;
                                context
                                    .read<ProgramEditCubit>()
                                    .updateDropdown(dropdownValues);
                              }),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    GreenElevatedButton(
                        text: "Submit",
                        onPressed: () async {
                          Map<String, dynamic> data = {
                            "description": _limitController.text,
                            "name": _titleController.text,
                            "timeAdded": DateTime.now(),
                            "pending": _userRole == 'manager' ? false : true,
                          };
                          await programsCubit.addProgram(data, userReference);
                          _titleController.clear();
                          _limitController.clear();
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

  void _showEditForm(ProgramData program) {
    // Get instance of programs cubit from main context
    ProgramsCubit programsCubit = BlocProvider.of<ProgramsCubit>(context);

    showDialog(
        context: context,
        builder: (context) {
          _titleController.text = program.title;
          _limitController.text = program.creationDate.toString();
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
                            "title": _limitController.text,
                            "creationDate": DateTime.now(),
                            "pending": _userRole == 'manager' ? false : true,
                          };
                          await programsCubit.updatePrograms(
                              program.reference, data,userReference);
                          _titleController.clear();
                          _limitController.clear();
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
                          Navigator.pop(context);
                        })
                  ],
                )
              ],
            ),
          );
        });
  }

  void _showDeleteForm(ProgramData program) {
    ProgramsCubit programsCubit = BlocProvider.of<ProgramsCubit>(context);
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
                          await programsCubit.removeProgram(program.reference, userReference);
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

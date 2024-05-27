/// Programs page - CRUD for arduino-side programs
///
/// TODO:
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/programs_cubit.dart';
import 'package:greenhouse_project/services/cubit/program_edit_cubit.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/dialogs.dart';
import 'package:greenhouse_project/utils/input.dart';
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
        BlocProvider(
          create: (context) => ProgramEditCubit(),
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
  late DocumentReference _userReference;
  late String _userRole = "";

  // Custom theme
  final ThemeData customTheme = theme;

  // Text controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Dispose (destructor)
  @override
  void dispose() {
    _descriptionController.dispose();
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
          _userReference = state.userReference;

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
      appBar: createAltAppbar(context, "Programs"),
      // Blocbuilder for programs state
      body: Container(
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
            image: const AssetImage('lib/utils/Icons/pattern.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.2),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: BlocBuilder<ProgramsCubit, ProgramsState>(
            builder: (context, state) {
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
            print(state.error);
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
      ),
      //floating button
      floatingActionButton: GreenElevatedButton(
          text: "Create program",
          onPressed: () {
            _showAdditionForm();
          }),
    );
  }

  // Function call to create programs list
  Widget _createProgramsList(List programsList) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: programsList.length,
                itemBuilder: (context, index) {
                  ProgramData program = programsList[index]; // program info
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 4.0,
                    margin: EdgeInsets.only(bottom: 16.0),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.build_circle_outlined,
                          color: Colors.orange[800]!,
                          size: 30,
                        ),
                      ),
                      title: Text(
                        program.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(program.creationDate.toString()),
                      trailing: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: WhiteElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => ProgramDetailsDialog(
                                      program: program,
                                      editProgram: () => _showEditForm(program),
                                      deleteProgram: () =>
                                          _showDeleteForm(program)));
                            },
                            text: "Details",
                          )),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }

  // Function to show program creation form
  void _showAdditionForm() {
    // Get instances of programs cubit from main context
    ProgramsCubit programsCubit = BlocProvider.of<ProgramsCubit>(context);
    ProgramEditCubit programEditCubit =
        BlocProvider.of<ProgramEditCubit>(context);
    List<bool> validation = [true, true, true, true, true, true];
    showDialog(
        context: context,
        builder: (context) {
          _descriptionController.text;
          List<dynamic> inputValues = [
            _titleController.text,
            _descriptionController.text,
            0,
            null,
            null,
            null
          ];
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: const BorderSide(
                  color: Colors.transparent,
                  width: 2.0), // Add border color and width
            ),
            title: const Text("Create program"),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              width: MediaQuery.of(context).size.width * .6,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Set column to minimum size
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<ProgramEditCubit, List<dynamic>>(
                    bloc: programEditCubit,
                    builder: (context, state) {
                      return Column(
                        children: [
                          InputTextField(
                              controller: _titleController,
                              errorText: validation[0]
                                  ? null
                                  : "Title cannot be be empty!",
                              labelText: "Title"),
                          InputTextField(
                              controller: _descriptionController,
                              errorText: validation[1]
                                  ? null
                                  : "Description cannot be be empty!",
                              labelText: "Description"),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: DropdownButtonFormField(
                                  isExpanded: true,
                                  value: inputValues[5] != ""
                                      ? inputValues[5]
                                      : null,
                                  elevation: 16,
                                  decoration: const InputDecoration(
                                    labelText: 'Condition',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                  ),
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
                                    inputValues[5] = selection;
                                    programEditCubit
                                        .checkValidationAndUpdate(inputValues);
                                  }),
                            ),
                          ),
                          CustomSlider(
                              updateSlider: (double value) {
                                List<dynamic> values = inputValues;
                                values[2] = value;
                                programEditCubit
                                    .checkValidationAndUpdate(values);
                              },
                              currentSliderValue:
                                  inputValues[2].roundToDouble()),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: DropdownButtonFormField(
                                  isExpanded: true,
                                  value: inputValues[3] != ""
                                      ? inputValues[3]
                                      : null,
                                  elevation: 16,
                                  decoration: const InputDecoration(
                                    labelText: 'Equipment',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                  ),
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
                                    inputValues[3] = selection;
                                    programEditCubit
                                        .checkValidationAndUpdate(inputValues);
                                  }),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: DropdownButtonFormField(
                                  isExpanded: true,
                                  value: inputValues[4] != ""
                                      ? inputValues[4]
                                      : null,
                                  elevation: 16,
                                  decoration: const InputDecoration(
                                    labelText: 'Action',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                  ),
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
                                    inputValues[4] = selection;
                                    programEditCubit
                                        .checkValidationAndUpdate(inputValues);
                                  }),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GreenElevatedButton(
                            text: "Submit",
                            onPressed: () {
                              inputValues[0] = _titleController.text;
                              inputValues[1] = _descriptionController.text;
                              validation = programEditCubit
                                  .checkValidationAndUpdate(inputValues);
                              if (validation.contains(null) ||
                                  validation.contains(false)) {
                                return;
                              } else {
                                Map<String, dynamic> data = {
                                  "title": _titleController.text,
                                  "description": _descriptionController.text,
                                  "limit": inputValues[2],
                                  "equipment": inputValues[3],
                                  "action": inputValues[4],
                                  "condition": inputValues[5],
                                  "creationDate": DateTime.now(),
                                  "pending":
                                      _userRole != 'worker' ? false : true,
                                };
                                programsCubit.addProgram(data, _userReference);
                                _titleController.clear();
                                _descriptionController.clear();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Item added succesfully!")));
                              }
                            }),
                      ),
                      Expanded(
                        child: WhiteElevatedButton(
                            text: "Cancel",
                            onPressed: () {
                              _titleController.clear();
                              _descriptionController.clear();
                              //_amountController.clear();
                              Navigator.pop(context);
                            }),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  void _showEditForm(ProgramData program) {
    // Get instance of programs cubit from main context
    ProgramsCubit programsCubit = BlocProvider.of<ProgramsCubit>(context);
    ProgramEditCubit programEditCubit =
        BlocProvider.of<ProgramEditCubit>(context);
    List<bool> validation = [true, true, true, true, true, true];
    showDialog(
        context: context,
        builder: (context) {
          _titleController.text = program.title;
          _descriptionController.text = program.description;
          List<dynamic> inputValues = [
            _titleController.text,
            _descriptionController.text,
            program.limit,
            program.equipment,
            program.action,
            program.condition
          ];
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(
                    color: Colors.transparent,
                    width: 2.0), // Add border color and width
              ),
              title: const Text("Edit program"),
              content: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                width: MediaQuery.of(context).size.width * .6,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Set column to minimum size
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputTextField(
                        controller: _titleController,
                        errorText:
                            validation[0] ? null : "Title cannot be be empty!",
                        labelText: "Title"),
                    InputTextField(
                        controller: _descriptionController,
                        errorText: validation[1]
                            ? null
                            : "Description cannot be be empty!",
                        labelText: "Description"),
                    BlocBuilder<ProgramEditCubit, List<dynamic>>(
                      bloc: programEditCubit,
                      builder: (context, state) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: DropdownButtonFormField(
                                    isExpanded: true,
                                    value: inputValues[5] != ""
                                        ? inputValues[5]
                                        : null,
                                    elevation: 16,
                                    decoration: const InputDecoration(
                                      labelText: 'Condition',
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                    ),
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
                                      inputValues[5] = selection;
                                      programEditCubit.checkValidationAndUpdate(
                                          inputValues);
                                    }),
                              ),
                            ),
                            CustomSlider(
                                updateSlider: (double value) {
                                  List<dynamic> values = inputValues;
                                  values[2] = value;
                                  programEditCubit
                                      .checkValidationAndUpdate(values);
                                },
                                currentSliderValue: inputValues[2]),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: DropdownButtonFormField(
                                    isExpanded: true,
                                    value: inputValues[3] != ""
                                        ? inputValues[3]
                                        : null,
                                    elevation: 16,
                                    decoration: const InputDecoration(
                                      labelText: 'Equipment',
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                    ),
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
                                      inputValues[3] = selection;
                                      programEditCubit.checkValidationAndUpdate(
                                          inputValues);
                                    }),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: DropdownButtonFormField(
                                    isExpanded: true,
                                    value: inputValues[4] != ""
                                        ? inputValues[4]
                                        : null,
                                    elevation: 16,
                                    decoration: const InputDecoration(
                                      labelText: 'Action',
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                    ),
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
                                      inputValues[4] = selection;
                                      programEditCubit.checkValidationAndUpdate(
                                          inputValues);
                                    }),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GreenElevatedButton(
                              text: "Submit",
                              onPressed: () {
                                inputValues[0] = _titleController.text;
                                inputValues[1] = _descriptionController.text;
                                validation = programEditCubit
                                    .checkValidationAndUpdate(inputValues);
                                if (validation.contains(null) ||
                                    validation.contains(false)) {
                                  return;
                                } else {
                                  Map<String, dynamic> data = {
                                    "title": _titleController.text,
                                    "description": _descriptionController.text,
                                    "limit": inputValues[2],
                                    "equipment": inputValues[3],
                                    "action": inputValues[4],
                                    "condition": inputValues[5],
                                    "creationDate": DateTime.now(),
                                    "pending":
                                        _userRole != 'worker' ? false : true,
                                  };
                                  programsCubit.updatePrograms(
                                      program.reference, data, _userReference);
                                  _titleController.clear();
                                  _descriptionController.clear();
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Program edited succesfully!")));
                                }
                              }),
                        ),
                        Expanded(
                          child: WhiteElevatedButton(
                              text: "Cancel",
                              onPressed: () {
                                _titleController.clear();
                                _descriptionController.clear();
                                Navigator.pop(context);
                              }),
                        )
                      ],
                    )
                  ],
                ),
              ));
        });
  }

  void _showDeleteForm(ProgramData program) {
    ProgramsCubit programsCubit = BlocProvider.of<ProgramsCubit>(context);
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
              title: const Text("Are you sure?"),
              content: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                width: MediaQuery.of(context).size.width * .6,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Set column to minimum size
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GreenElevatedButton(
                              text: "Submit",
                              onPressed: () {
                                programsCubit.removeProgram(
                                    program.reference, _userReference);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Program deleted succesfully!")));
                              }),
                        ),
                        Expanded(
                          child: WhiteElevatedButton(
                              text: "Cancel",
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        )
                      ],
                    )
                  ],
                ),
              ));
        });
  }
}

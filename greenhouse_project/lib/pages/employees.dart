/// Employees page - CRUD for employee accounts
///
/// TODO:
/// - Implement "deleteEmployee" function
/// -input validation add employee
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/footer_nav_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/management_cubit.dart';
import 'package:greenhouse_project/services/cubit/employee_edit_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/input.dart';
import 'package:greenhouse_project/utils/theme.dart';

class EmployeesPage extends StatelessWidget {
  final UserCredential userCredential; // user auth credentials

  const EmployeesPage({super.key, required this.userCredential});

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
        BlocProvider(create: (context) => ManageEmployeesCubit(userCredential)),
      ],
      child: _EmployeesPageContent(userCredential: userCredential),
    );
  }
}

class _EmployeesPageContent extends StatefulWidget {
  final UserCredential userCredential; // user auth credentials

  const _EmployeesPageContent({required this.userCredential});

  @override
  State<_EmployeesPageContent> createState() => _EmployeesPageState();
}

// Main page content
class _EmployeesPageState extends State<_EmployeesPageContent> {
  late DocumentReference _userReference;
  // Custom theme
  final ThemeData customTheme = theme;

  // Text Controllers
  final TextEditingController _emailController = TextEditingController();

  // Dispose (destructor)
  @override
  void dispose() {
    _emailController.dispose();
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
    return BlocBuilder<UserInfoCubit, HomeState>(
      builder: (context, state) {
        // Show "loading screen" if processing user info state
        if (state is UserInfoLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // Show content once user info is loaded
        else if (state is UserInfoLoaded) {
          // Function call to create employees page
          _userReference = state.userReference;
          return Theme(data: customTheme, child: _createEmployeesPage());
        } else {
          return const Center(
            child: Text('Unexpected state'),
          );
        }
      },
    );
  }

  // Function to create employees page
  Widget _createEmployeesPage() {
    final ManageEmployeesCubit manageEmployeesCubit =
        BlocProvider.of<ManageEmployeesCubit>(context);

    return Scaffold(
      // Appbar (header)
      appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          )),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: const Text(
                "Employees",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          // BlocBuilder for manageEmployees state
          BlocBuilder<ManageEmployeesCubit, ManagementState>(
            builder: (context, state) {
              // Show "loading screen" if processing manageEmployees state
              if (state is ManageEmployeesLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              // Show employees if manageEmployees state is loaded
              else if (state is ManageEmployeesLoaded) {
                List<EmployeeData> employeeList =
                    state.employees; // employees list

                // Display nothing if no employees
                if (employeeList.isEmpty) {
                  return const Center(child: Text("No Employees..."));
                }
                // Display employees
                else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: employeeList.length,
                    itemBuilder: (context, index) {
                      EmployeeData employee =
                          employeeList[index]; // employee info
                      return ListTile(
                        title: Text(employee.name),
                        subtitle:
                            Text(employee.enabled ? "Active" : "Inactive"),
                        trailing: WhiteElevatedButton(
                          text: 'Details',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return EmployeeDetailsDialog(
                                    employee: employee);
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              }
              // Show error message once an error occurs
              else if (state is ManageEmployeesError) {
                return Center(child: Text(state.error.toString()));
              }
              // If the state is not any of the predefined states;
              // never happens; but, anything can happen
              else {
                return const Center(child: Text('Unexpected State'));
              }
            },
          ),

          GreenElevatedButton(
              text: 'Add employee',
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider(
                              create: (context) => EmployeeEditCubit()),
                          BlocProvider(
                              create: (context) =>
                                  EmployeeDropdownCubit(context)),
                        ],
                        child: BlocBuilder<EmployeeEditCubit, List<dynamic>>(
                          builder: (context, state) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(
                                    color: Colors.transparent,
                                    width: 2.0), // Add border color and width
                              ),
                              title: const Text("Add employee"),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisSize: MainAxisSize
                                      .min, // Set column to minimum size
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  //Textfields
                                  children: [
                                    InputTextField(
                                        controller: _emailController,
                                        errorText: state[0]
                                            ? ""
                                            : "Email format is incorrect",
                                        labelText: "email"),
                                    SizedBox(
                                        width: double.maxFinite,
                                        child: InputDropdown(
                                          items: const {
                                            "worker": "worker",
                                            "manager": "manager"
                                          },
                                          value: state[1] != ''
                                              ? state[1]
                                              : "employee",
                                          onChanged: context
                                              .read<EmployeeDropdownCubit>()
                                              .updateDropdown,
                                        )),
                                    //Submit or Cancel
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GreenElevatedButton(
                                              text: 'Submit',
                                              onPressed: () async {
                                                List<dynamic> validation = [
                                                  true,
                                                  state[1]
                                                ];
                                                if (!_emailController.text
                                                    .contains(
                                                        RegExp(r'.+@.+\..+'))) {
                                                  validation[0] =
                                                      !validation[0];
                                                }

                                                bool isValid = context
                                                    .read<EmployeeEditCubit>()
                                                    .updateState(validation);

                                                if (isValid) {
                                                  await manageEmployeesCubit
                                                      .createEmployee(
                                                          _emailController.text,
                                                          state[1],
                                                          _userReference);
                                                  Navigator.pop(context);
                                                  _emailController.clear();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(const SnackBar(
                                                          content: Text(
                                                              "Account created successfully!")));
                                                }
                                              }),
                                        ),
                                        Expanded(
                                          child: WhiteElevatedButton(
                                              text: 'Cancel',
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _emailController.clear();
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
              })
        ],
      ),
    );
  }
}

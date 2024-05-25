
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/inventory_cubit.dart';
import 'package:greenhouse_project/services/cubit/management_cubit.dart';
import 'package:greenhouse_project/services/cubit/plants_cubit.dart';
import 'package:greenhouse_project/services/cubit/programs_cubit.dart';
import 'package:greenhouse_project/services/cubit/task_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/theme.dart';

class TaskDetailsDialog extends StatelessWidget {
  final TaskData task;
  final String userRole;
  final DocumentReference? managerReference;
  final Function editOrComplete;
  final Function deleteOrContact;

  const TaskDetailsDialog(
      {super.key,
      required this.task,
      required this.userRole,
      required this.managerReference,
      required this.editOrComplete,
      required this.deleteOrContact});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
            color: Colors.transparent,
            width: 2.0), // Add border color and width
      ),
      title: const Text("Task Details"),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        width: MediaQuery.of(context).size.width*.6, // Set maximum width
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set column to minimum size
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Title:", task.title),
            _buildDetailRow("Description:", task.description),
            _buildDetailRow(
                "Due Date:",
                task.dueDate
                    .toString()
                    .substring(0, task.dueDate.toString().length - 7)),
            _buildDetailRow("Status:", task.status),
            const SizedBox(
                height: 20), // Add spacing between details and buttons
            userRole == "worker"
                ? Row(
                    children: [
                      Expanded(
                        child: WhiteElevatedButton(
                            text: "Contact Manager", onPressed: () {}),
                      ),
                      Expanded(
                        child: WhiteElevatedButton(
                            text: "Mark as Complete",
                            onPressed: () {
                              context
                                  .read<TaskCubit>()
                                  .completeTask(task.taskReference);
                            }),
                      )
                    ],
                  )
                : Row(children: [
                    Expanded(
                      child: WhiteElevatedButton(
                          text: userRole == "worker"
                              ? "Mark as Complete"
                              : "Edit",
                          onPressed: () => editOrComplete(task)),
                    ),
                    Expanded(
                      child: RedElevatedButton(
                          text: userRole == "worker"
                              ? "Contact Manager"
                              : "Delete",
                          onPressed: () => deleteOrContact(
                              userRole == "worker" ? managerReference : task)),
                    ),
                    task.status == "waiting"
                        ? Expanded(
                            child: GreenElevatedButton(
                                text: "Approve", onPressed: () {}),
                          )
                        : const SizedBox(),
                  ]),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.center,
              child: WhiteElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                text: "Close",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme
                  .colorScheme.onPrimary, // Optional: Customize label color
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme
                    .colorScheme.onPrimary, // Optional: Customize value color
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeDetailsDialog extends StatelessWidget {
  final EmployeeData employee;
  final Function tasksFunction;
  final Function toggleAccount;
  final Function profileFunction;

  const EmployeeDetailsDialog(
      {super.key,
      required this.employee,
      required this.tasksFunction,
      required this.profileFunction,
      required this.toggleAccount});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
            color: Colors.transparent,
            width: 2.0), // Add border color and width
      ),
      title: const Text("Employee Details"),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        width: MediaQuery.of(context).size.width*.6,// Set maximum width
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set column to minimum size
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Name:", employee.name),
            _buildDetailRow("Surname:", employee.surname),
            _buildDetailRow("Email:", employee.email),
            _buildDetailRow("Role:", employee.role),
            _buildDetailRow(
                "Start Date:",
                employee.creationDate.toString().substring(
                    0, employee.creationDate.toString().length - 12)),
            _buildDetailRow(
                "Status:", employee.enabled ? "Enabled" : "Disabled"),
            const SizedBox(
                height: 20), // Add spacing between details and buttons

            Row(
              children: [
                Expanded(
                  child: WhiteElevatedButton(
                    text: "Tasks",
                    onPressed: () => tasksFunction(employee),
                  ),
                ),
                Expanded(
                  child: WhiteElevatedButton(
                    text: "Show profile",
                    onPressed: () => profileFunction(employee),
                  ),
                ),
                Expanded(
                  child: RedElevatedButton(
                    text:
                        employee.enabled ? "Disable account" : "Enable account",
                    onPressed: () => toggleAccount(),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.center,
              child: WhiteElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                text: "Close",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme
                  .colorScheme.onPrimary, // Optional: Customize label color
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme
                    .colorScheme.onPrimary, // Optional: Customize value color
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryDetailsDialog extends StatelessWidget {
  final InventoryData inventory;
  final Function editInventory;
  final Function deleteInventory;

  const InventoryDetailsDialog(
      {super.key,
      required this.inventory,
      required this.editInventory,
      required this.deleteInventory});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
            color: Colors.transparent,
            width: 2.0), // Add border color and width
      ),
      title: const Text("Inventory Details"),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        width: MediaQuery.of(context).size.width*.6, // Set maximum width
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set column to minimum size
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Name:", inventory.name),
            _buildDetailRow("Description:", inventory.description),
            _buildDetailRow("Amount:", inventory.amount.toString()),
            _buildDetailRow(
                "Time added",
                inventory.timeAdded
                    .toString()
                    .substring(0, inventory.timeAdded.toString().length - 7)),
            const SizedBox(
                height: 20), // Add spacing between details and buttons
            Row(
              children: [
                Expanded(
                  child: WhiteElevatedButton(
                      text: "Edit",
                      onPressed: () {
                        editInventory();
                      }),
                ),
                Expanded(
                  child: RedElevatedButton(
                      text: "Delete",
                      onPressed: () {
                        deleteInventory();
                      }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.center,
              child: WhiteElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                text: "Close",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme
                  .colorScheme.onPrimary, // Optional: Customize label color
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme
                    .colorScheme.onPrimary, // Optional: Customize value color
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlantDetailsDialog extends StatelessWidget {
  final PlantData plant;
  final Function removePlant;

  const PlantDetailsDialog({
    super.key,
    required this.plant,
    required this.removePlant,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
            color: Colors.transparent,
            width: 2.0), // Add border color and width
      ),
      title: const Text("Plant Details"),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        width: MediaQuery.of(context).size.width*.6,// Set maximum width
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set column to minimum size
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Type:", plant.type),
            _buildDetailRow("Subtype:", plant.subtype),
            _buildDetailRow("Bord No:", plant.boardNo.toString()),
            _buildDetailRow(
                "Birthdate",
                plant.birthdate
                    .toString()
                    .substring(0, plant.birthdate.toString().length - 7)),
            const SizedBox(
                height: 20), // Add spacing between details and buttons
            Align(
              alignment: Alignment.center,
              child: Row(
                children: [
                  WhiteElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    text: "Close",
                  ),
                  RedElevatedButton(
                      onPressed: removePlant(), text: "Remove Plant")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme
                  .colorScheme.onPrimary, // Optional: Customize label color
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme
                    .colorScheme.onPrimary, // Optional: Customize value color
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgramDetailsDialog extends StatelessWidget {
  final ProgramData program;
  final Function editProgram;
  final Function deleteProgram;

  const ProgramDetailsDialog(
      {super.key,
      required this.program,
      required this.editProgram,
      required this.deleteProgram});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
            color: Colors.transparent,
            width: 2.0), // Add border color and width
      ),
      title: const Text("Program Details"),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        width: MediaQuery.of(context).size.width*.6, // Set maximum width
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set column to minimum size
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Equipment:", program.equipment),
            _buildDetailRow("Title", program.title),
            _buildDetailRow(
                "Creation date:",
                program.creationDate
                    .toString()
                    .substring(0, program.creationDate.toString().length - 7)),
            const SizedBox(
                height: 20), // Add spacing between details and buttons
            Row(
              children: [
                Expanded(
                  child: WhiteElevatedButton(
                      text: "Edit",
                      onPressed: () {
                        editProgram();
                      }),
                ),
                Expanded(
                  child: RedElevatedButton(
                      text: "Delete",
                      onPressed: () {
                        deleteProgram();
                      }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: WhiteElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                text: "Close",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme
                  .colorScheme.onPrimary, // Optional: Customize label color
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme
                    .colorScheme.onPrimary, // Optional: Customize value color
              ),
            ),
          ),
        ],
      ),
    );
  }
}

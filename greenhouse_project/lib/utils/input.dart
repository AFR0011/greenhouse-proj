/// Buttons to be used throughout the application
/// Todo
/// Review program to add action, limit etc...
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/equipment_status_cubit.dart';
import 'package:greenhouse_project/services/cubit/inventory_cubit.dart';
import 'package:greenhouse_project/services/cubit/management_cubit.dart';
import 'package:greenhouse_project/services/cubit/plants_cubit.dart';
import 'package:greenhouse_project/services/cubit/programs_cubit.dart';
import 'package:greenhouse_project/services/cubit/task_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class InputTextField extends StatelessWidget {
  final TextEditingController controller;
  final String errorText;
  final String labelText;

  const InputTextField(
      {super.key,
      required this.controller,
      required this.errorText,
      required this.labelText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        labelText: labelText,
        errorText: errorText,
        filled: true,
        fillColor: theme.colorScheme.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  const LoginTextField(
      {super.key, required this.controller, required this.labelText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white70,
        label: Text(labelText),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  final String name;
  final String data;
  final Widget icon;

  const ProfileTextField(
      {super.key, required this.name, required this.data, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          label: Text(name),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          prefixIcon: icon),
      controller: TextEditingController(text: data),
    );
  }
}

class InputDropdown extends StatelessWidget {
  final Map<String, dynamic> items;
  final dynamic value;
  final Function onChanged;

  const InputDropdown(
      {super.key,
      required this.items,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> itemsList = [];
    items.forEach((text, value) {
      DropdownMenuItem menuItem = DropdownMenuItem(
        value: value,
        child:
            Text(text, style: const TextStyle(overflow: TextOverflow.ellipsis)),
      );
      itemsList.add(menuItem);
    });
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        child: Center(
          child: DropdownButtonFormField(
            isExpanded: true,
            value: value,
            onChanged: (value) => onChanged(value),
            decoration: const InputDecoration(
              labelText: 'Select an option',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
            items: itemsList,
          ),
        ),
      ),
    );
  }
}

class TaskDetailsDialog extends StatelessWidget {
  final TaskData task;
  final String userRole;
  final Function showEditForm;
  final Function showDeleteForm;


  const TaskDetailsDialog({super.key, required this.task, required this.userRole, required this.showEditForm, required this.showDeleteForm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
            color: Colors.transparent,
            width: 2.0), // Add border color and width
      ),
      title: Text("Task Details"),
      content: Container(
        width: double.maxFinite, // Set maximum width
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
            SizedBox(height: 20), // Add spacing between details and buttons
            userRole == "worker"
                               ? Row(
                                   children: [
                                     Expanded(
                                       child: WhiteElevatedButton(
                                           text: "Contact Manager",
                                           onPressed: () {}),
                                     ),
                                     Expanded(
                                       child: WhiteElevatedButton(
                                           text: "Mark as Complete",
                                           onPressed: () {
                                             context
                                                 .read<TaskCubit>()
                                                 .completeTask(
                                                     task.taskReference);
                                           }),
                                     )
                                   ],
                                 )
                               : Row(children: [
                                   Expanded(
                                     child: WhiteElevatedButton(
                                         text: "Edit", onPressed: showEditForm()),
                                   ),
                                   Expanded(
                                     child: RedElevatedButton(
                                         text: "Delete", onPressed: showDeleteForm()),
                                   ),
                                   
                                   task.status == "waiting"
                                       ? Expanded(
                                         child: GreenElevatedButton(
                                             text: "Approve",
                                             onPressed: () {}),
                                       )
                                       : const SizedBox(),
                                   
                                 ]),

            SizedBox(height: 20),
            
            Align(
              alignment: Alignment.center,
              child: WhiteElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                text: "close",
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
          SizedBox(width: 10),
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

  const EmployeeDetailsDialog({super.key, required this.employee, required this.tasksFunction, required this.profileFunction, required this.toggleAccount});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
            color: Colors.transparent,
            width: 2.0), // Add border color and width
      ),
      title: Text("Employee Details"),
      content: Container(
        width: double.maxFinite, // Set maximum width
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
            SizedBox(height: 20), // Add spacing between details and buttons

              Row(
                                  children: [
                                    Expanded(
                                      child: WhiteElevatedButton(
                                          text: "Tasks",
                                          onPressed: () {
                                           tasksFunction();
                                          }),
                                    ),
                                    Expanded(
                                      child: WhiteElevatedButton(
                                          text: "Show profile",
                                          onPressed: () {
                                            profileFunction();
                                          }),
                                    ),
                                    Expanded(
                                      child: RedElevatedButton(
                                          text: employee.enabled
                                              ? "Disable account"
                                              : "Enable account",
                                          onPressed: () {
                                            toggleAccount();
                                          }),
                                    ),
                                  ],
                                ),
              SizedBox(height: 20),
            
            Align(
              alignment: Alignment.center,
              child: WhiteElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                text: "close",
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
          SizedBox(width: 10),
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


  const InventoryDetailsDialog({super.key, required this.inventory, required this.editInventory, required this.deleteInventory});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
            color: Colors.transparent,
            width: 2.0), // Add border color and width
      ),
      title: Text("Inventory Details"),
      content: Container(
        width: double.maxFinite, // Set maximum width
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set column to minimum size
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Name:", inventory.name),
            _buildDetailRow("Description:", inventory.description),
            _buildDetailRow("Amount:", inventory.amount.toString()),
            _buildDetailRow(
                "Time Added",
                inventory.timeAdded
                    .toString()
                    .substring(0, inventory.timeAdded.toString().length - 7)),
            SizedBox(height: 20), // Add spacing between details and buttons
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
                                          text:
                                               "Delete",
                                          onPressed: () {
                                            deleteInventory();
                                          }),
                                    ),
                                  ],
                                ),
              SizedBox(height: 20),
            
            Align(
              alignment: Alignment.center,
              child: WhiteElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                text: "close",
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
          SizedBox(width: 10),
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

  const PlantDetailsDialog({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
            color: Colors.transparent,
            width: 2.0), // Add border color and width
      ),
      title: Text("Plant Details"),
      content: Container(
        width: double.maxFinite, // Set maximum width
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
            SizedBox(height: 20), // Add spacing between details and buttons
            Align(
              alignment: Alignment.center,
              child: WhiteElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                text: "close",
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
          SizedBox(width: 10),
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

  const ProgramDetailsDialog({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
            color: Colors.transparent,
            width: 2.0), // Add border color and width
      ),
      title: Text("Program Details"),
      content: Container(
        width: double.maxFinite, // Set maximum width
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set column to minimum size
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Equipment:", program.equipment),
            _buildDetailRow("Title", program.title),
            _buildDetailRow(
                "Creation Date:",
                program.creationDate
                    .toString()
                    .substring(0, program.creationDate.toString().length - 7)),
            SizedBox(height: 20), // Add spacing between details and buttons
            Align(
              alignment: Alignment.center,
              child: WhiteElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                text: "close",
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
          SizedBox(width: 10),
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

class ToggleButtonContainer extends StatelessWidget {
  final EquipmentStatus equipment;
  final String imgPath;
  final BuildContext context;
  final DocumentReference userReference;
  ToggleButtonContainer(
      {required this.imgPath,
      required this.equipment,
      required this.context,
      required this.userReference});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: equipment.status
                ? theme.colorScheme.primary
                : theme.colorScheme.secondary),
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
        // color: equipment.status? theme.colorScheme.primary : theme.colorScheme.secondary,
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          children: [
            Row(children: [
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: ClipOval(
                        child: Image.asset(
                          imgPath,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover),
                      ),
                      )),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Switch(
                      value: equipment.status,
                      onChanged: (value) {
                        context.read<EquipmentStatusCubit>().toggleStatus(
                            userReference,
                            equipment.reference,
                            equipment.status);
                      }),
                ),
              )
            ]),
            Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  equipment.type,
                  style: subheadingTextStyle,
                ))
          ],
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.5, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class WavePainter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * .95);
    path.quadraticBezierTo(
        size.width * 0.35, size.height, size.width * 0.55, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.5, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class WavePainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * .95);

    path.quadraticBezierTo(
        size.width, size.height * 1.5, size.width * 1.5, size.height * 0.95);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

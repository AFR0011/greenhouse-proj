/// Buttons to be used throughout the application
/// Todo
/// Review program to add action, limit etc...
library;

import 'package:flutter/material.dart';
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
  final String hintText;

  const InputTextField({
    super.key,
    required this.controller,
    required this.errorText,
    required this.hintText
  });

  @override
  Widget build(BuildContext context) {
  return TextField(                
    decoration: InputDecoration(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.75),
      hintText: hintText,
      errorText: errorText,
      filled: true,
      fillColor:Color.fromARGB(209, 235, 245, 231),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),              
  );
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.labelText
  });

  @override
  Widget build(BuildContext context) {
  return TextField(                
    decoration: InputDecoration(
      filled: true,
      fillColor:Colors.white70,
      label: Text(labelText),
      border: const OutlineInputBorder(),
    ),              
  );
  }
}



class InputDropdown extends StatelessWidget {
  Map<String, dynamic> items;
  String? value;
  final Function onChanged;
  
  InputDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged  });

  @override
  Widget build(BuildContext context) {
  List<DropdownMenuItem<String>> itemsList = [];
  items.forEach((text, value) { DropdownMenuItem<String> menuItem = DropdownMenuItem(
              value: value,
              child: Text(text),
            );
            itemsList.add(menuItem);});
  return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: DropdownButtonFormField<String>(
          value: value,
          onChanged: (value) => onChanged(value),
          decoration: const InputDecoration(
            labelText: 'Select an option',
            border: OutlineInputBorder(),
          ),
          items: itemsList,
        ),
      ),
    );
  }
}

class TaskDetailsDialog extends StatelessWidget {
  final TaskData task;

  const TaskDetailsDialog({super.key, required this.task}); 

  @override
  Widget build(BuildContext context) {
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.transparent, width: 2.0), // Add border color and width
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
            _buildDetailRow("Due Date:", task.dueDate.toString().substring(0, task.dueDate.toString().length-7)),
            _buildDetailRow("Status:", task.status),
            SizedBox(height: 20), // Add spacing between details and buttons
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Close"),
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
              color: theme.colorScheme.onPrimary, // Optional: Customize label color
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme.colorScheme.onPrimary, // Optional: Customize value color
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class WorkerDetailsDialog extends StatelessWidget {
  final WorkerData worker;

  const WorkerDetailsDialog({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.transparent, width: 2.0), // Add border color and width
      ),
      title: Text("Worker Details"),
      content: Container(
        width: double.maxFinite, // Set maximum width
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set column to minimum size
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Name:", worker.name),
            _buildDetailRow("Surname:", worker.surname ),
            _buildDetailRow("Email:", worker.email),
            _buildDetailRow("Role:", worker.role),
            _buildDetailRow("Start Date:", worker.creationDate.toString().substring(0, worker.creationDate.toString().length-12) ),
            _buildDetailRow("Status:", worker.enabled? "Enabled" : "Disabled"),
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
              color: theme.colorScheme.onPrimary, // Optional: Customize label color
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme.colorScheme.onPrimary, // Optional: Customize value color
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

  const InventoryDetailsDialog({ super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.transparent, width: 2.0), // Add border color and width
      ),
      title: Text("Inventory Details"),
      content: Container(
        width: double.maxFinite, // Set maximum width
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set column to minimum size
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Name:", inventory.name),
            _buildDetailRow("Description:", inventory.description  ),
            _buildDetailRow("Amount:", inventory.amount.toString()),
            _buildDetailRow("Time Added", inventory.timeAdded.toString().substring(0, inventory.timeAdded.toString().length-7)),
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
              color: theme.colorScheme.onPrimary, // Optional: Customize label color
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme.colorScheme.onPrimary, // Optional: Customize value color
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

  const PlantDetailsDialog({ super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.transparent, width: 2.0), // Add border color and width
      ),
      title: Text("Plant Details"),
      content: Container(
        width: double.maxFinite, // Set maximum width
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set column to minimum size
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Type:", plant.type),
            _buildDetailRow("Subtype:", plant.subtype ),
            _buildDetailRow("Bord No:", plant.boardNo.toString()),
            _buildDetailRow("Birthdate", plant.birthdate.toString().substring(0, plant.birthdate.toString().length-7)),
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
              color: theme.colorScheme.onPrimary, // Optional: Customize label color
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme.colorScheme.onPrimary, // Optional: Customize value color
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

  const ProgramDetailsDialog({ super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.transparent, width: 2.0), // Add border color and width
      ),
      title: Text("Program Details"),
      content: Container(
        width: double.maxFinite, // Set maximum width
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set column to minimum size
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Equipment:", program.equipment),
            _buildDetailRow("Title", program.title ),
            _buildDetailRow("Creation Date:", program.creationDate.toString().substring(0, program.creationDate.toString().length-7)),
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
              color: theme.colorScheme.onPrimary, // Optional: Customize label color
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme.colorScheme.onPrimary, // Optional: Customize value color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
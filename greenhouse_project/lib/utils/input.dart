/// Buttons to be used throughout the application
library;

import 'package:flutter/material.dart';
import 'package:greenhouse_project/utils/text_styles.dart';

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
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomRight: Radius.circular(12)
        ),
      ),
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

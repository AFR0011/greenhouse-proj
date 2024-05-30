import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/equipment_status_cubit.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class InputTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final String labelText;

  const InputTextField(
      {super.key,
      required this.controller,
      required this.errorText,
      required this.labelText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          errorText: errorText,
          filled: true,
          fillColor: theme.colorScheme.secondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
      child: Center(
        child: DropdownButtonFormField(
          isExpanded: true,
          value: value,
          elevation: 16,
          onChanged: (value) => onChanged(value),
          decoration: const InputDecoration(
            labelText: 'Select an option',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
          items: itemsList,
        ),
      ),
    );
  }
}

class ToggleButtonContainer extends StatelessWidget {
  final EquipmentStatus equipment;
  final String imgPath;
  final BuildContext context;
  final DocumentReference userReference;
  const ToggleButtonContainer(
      {super.key,
      required this.imgPath,
      required this.equipment,
      required this.context,
      required this.userReference});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
          minHeight: 240, minWidth: 240, maxHeight: 400, maxWidth: 400),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          color: equipment.status
              ? theme.colorScheme.secondary.withOpacity(0.75)
              : theme.colorScheme.primary.withOpacity(0.75),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 8,
            )
          ]
          //border: Border.all(width: 2, color: Colors.white30),
          ),

      margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      // color: equipment.status? theme.colorScheme.primary : theme.colorScheme.secondary,
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Container(
        //padding: const EdgeInsets.all(1),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [Colors.white60, Colors.white10],
          ),
          //borderRadius: BorderRadius.circular(25),
          border: Border.all(width: 2, color: Colors.white30),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                equipment.type,
                style: headingTextStyle,
              ),
            ),
            ClipOval(
              child: Image.asset(imgPath,
                  width: 100, height: 100, fit: BoxFit.cover),
            ),
            //Spacer(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Switch(
                  value: equipment.status,
                  onChanged: (value) {
                    context.read<EquipmentStatusCubit>().toggleStatus(
                        userReference, equipment.reference, equipment.status);
                  },
                  activeColor: theme.colorScheme.secondary,
                  inactiveThumbColor: theme.colorScheme.primary,
                  inactiveTrackColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Readings extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const Readings(
      {super.key,
      required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Text(value.toString(),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    ));
  }
}

class CustomSlider extends StatelessWidget {
  final double currentSliderValue;
  final Function(double) updateSlider;

  CustomSlider({required this.updateSlider, required this.currentSliderValue});
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.tealAccent,
        inactiveTrackColor: Colors.tealAccent.shade100,
        trackShape: RoundedRectSliderTrackShape(),
        trackHeight: 4.0,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
        thumbColor: Colors.teal,
        overlayColor: Colors.teal.withOpacity(0.2),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
        tickMarkShape: RoundSliderTickMarkShape(),
        activeTickMarkColor: Colors.tealAccent,
        inactiveTickMarkColor: Colors.tealAccent.shade100,
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: Colors.teal,
        valueIndicatorTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      child: Slider(
        value: currentSliderValue,
        min: 0,
        max: 100,
        divisions: 100,
        label: currentSliderValue.round().toString(),
        onChanged: updateSlider,
      ),
    );
  }
}

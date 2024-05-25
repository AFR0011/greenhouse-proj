/// Plants page - view plants and sensor readings
///
/// TODO:
/// - Chat graphs
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/greenhouse_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/plants_cubit.dart';
import 'package:greenhouse_project/services/cubit/plants_edit_cubit.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/input.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class PlantsPage extends StatelessWidget {
  final UserCredential userCredential;
  final DocumentReference userReference;
  const PlantsPage({super.key,
   required this.userCredential,
   required this.userReference,});

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
        BlocProvider(create: (context) => PlantStatusCubit(userReference)),
        BlocProvider(create: (context) => ReadingsCubit()),
        BlocProvider(create: (context) => PlantsEditCubit()),

      ],
      child: _PlantsPageContent(userCredential: userCredential),
    );
  }
}

class _PlantsPageContent extends StatefulWidget {
  final UserCredential userCredential;

  const _PlantsPageContent({required this.userCredential});

  @override
  State<_PlantsPageContent> createState() => _PlantsPageState();
}

// Main page content
class _PlantsPageState extends State<_PlantsPageContent> {

  // User info local variables
  late DocumentReference _userReference;
  // Custom theme
  final ThemeData customTheme = theme;

  // Text controllers
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  // Dispose (destructor)
  @override
  void dispose() {
    _textController.dispose();
    _typeController.dispose();
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
    // BlocBuilder for user info
    return BlocBuilder<UserInfoCubit, HomeState>(
      builder: (context, state) {
        // Show "loading screen" if processing user info
        if (state is UserInfoLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // Show content once user info is loaded
        else if (state is UserInfoLoaded) {
          // Call function to create plants page
          _userReference = state.userReference;

          return Theme(data: customTheme, child: _createPlantsPage());
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

  // Function to create plants page
  Widget _createPlantsPage() {
    return Scaffold(
      // Appbar (header)
      appBar: createAltAppbar(context, "Plants"),
      // Plants section
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
        child: Column(
          children: [
            // Plants subheading
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 20,),
            ),
            // BlocBuilder for plantStatus state
            BlocBuilder<PlantStatusCubit, PlantStatusState>(
              builder: (context, state) {
                // show "loading screen" if processing plantStatus state
                if (state is PlantsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Show plants once plantStatus state is loaded
                else if (state is PlantsLoaded) {
                  List<PlantData> plantList = state.plants; // plants list
        
                  // Display nothing if no plants
                  if (plantList.isEmpty) {
                    return const Center(child: Text("No Plants..."));
                  }
                  // Display plants
                  else {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SizedBox(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: plantList.length,
                                itemBuilder: (context, index) {
                                  PlantData plant = plantList[index]; //plant data
                              
                                  // Display plant info
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
                                        Icons.grass_outlined,
                                        color: Colors.green[800]!,
                                        size: 30,
                                      ),
                                      ),
                                      title: Text(plant.type,
                                      style: TextStyle(fontWeight: FontWeight.bold,
                                      fontSize: 18),),
                                      subtitle: Text(plant.subtype),
                                      trailing: WhiteElevatedButton(
                                        // Show details and sensor readings
                                        text: 'Details',
                                        onPressed: () {
                                          // _showPlantDetails(plant);
                                          BuildContext mainContext = context;
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  PlantDetailsDialog(plant: plant, removePlant: () => showDeleteForm(mainContext, plant)));
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                    )],),
                    );
                  }
                }
        
                // Show error message once an error occurs
                else if (state is PlantsError) {
                  return Center(child: Text('Error: ${state.error}'));
                }
                // If the state is not any of the predefined states;
                // never happens; but, anything can happen
                else {
                  return const Center(child: Text('Unexpected State'));
                }
              },
            ),
          ],
        ),
      ),

      floatingActionButton: GreenElevatedButton(
        text: "Add Plant",
         onPressed: () => showAdditionForm(context)),
    );
  }

  // Function to show plant details
  void _showPlantDetails(PlantData plant) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              ),
              Text("Title: ${plant.type}"),
              Text("Description: ${plant.subtype}"),
              Text("Due Date: ${plant.birthdate}"),
              const Text(
                "Readings",
                style: subheadingTextStyle,
              ),
              _showReadings(plant),
            ],
          ),
        );
      },
    );
  }

  // Function to show sensor readings
  Widget _showReadings(PlantData plant) {
    final ReadingsCubit readingsCubit = BlocProvider.of<ReadingsCubit>(context);

    // BlocBuilder for readings state
    return BlocBuilder<ReadingsCubit, GreenhouseState>(
      bloc: readingsCubit,
      builder: (context, state) {
        // Show "loading screen" if processing readings state
        if (state is ReadingsLoading ||
            [EquipmentLoaded, EquipmentLoading].contains(state.runtimeType)) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ReadingsLoaded) {
          final readings = state.readings; // list of all readings

          Set<Map<String, dynamic>> latestAllReadings =
              readings.last.allReadings; // latest readings

          Map<String, dynamic>? latestReading =
              latestAllReadings.elementAtOrNull(plant.boardNo - 1)?[
                  plant.boardNo.toString()]; // readings associated with plant

          // Display nothing if no readings
          if (latestReading!.isEmpty) {
            return const Text("No readings available");
          } else {
            return Column(
              children: [
                Text("Gas: ${latestReading['gas']}%"),
                Text("Humidity: ${latestReading['humidity']}%"),
                Text("Light Intensity: ${latestReading['lightIntensity']}%"),
                Text("Temperature: ${latestReading['temperature']} C"),
                Text("Soil Moisture: ${latestReading['soilMoisture']}%"),
              ],
            );
          }
        }
        // Show error message once an error occurs
        else if (state is ReadingsError) {
          return Text(state.error);
        }
        // If the state is not any of the predefined states;
        // never happens; but, anything can happen
        else {
          return const Text("Something went wrong...");
        }
      },
    );
  }

   // Item addition form function
  void showAdditionForm(BuildContext context) {
    // Get instance of inventory cubit from main context
    PlantStatusCubit plantStatusCubit = BlocProvider.of<PlantStatusCubit>(context);
    PlantsEditCubit plantsEditCubit = BlocProvider.of<PlantsEditCubit>(context);
    String dropdownValue = "1";
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
                  title: const Text("Add Plant"),
            content: SizedBox(
              width: double.maxFinite,
              child: BlocBuilder<PlantsEditCubit, List<bool>>(
                bloc: plantsEditCubit,
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min, // Set column to minimum size
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputTextField(controller: _typeController, errorText: state[0]
                                ? ""
                                : "Type should be longer than 1 characters.", labelText: "Type"),
                      // TextField(
                      //   controller: _equipmentController,
                      //   decoration: InputDecoration(
                      //       errorText: state[0]
                      //           ? ""
                      //           : "Name should be longer than 1 characters."),
                      // ),
                      InputTextField(controller: _textController, errorText: state[1]
                                ? ""
                                : "Subtype should be longer than 2 characters.", labelText: "Subtype"),
                      //insert dropdown HERE!!
                       DropdownButtonFormField<String>(
                    value: dropdownValue,
                    decoration: const InputDecoration(
                      labelText: "Board No",
                    ),
                    items: <String>["1"].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: null,
                    onTap: () {},
                    disabledHint: Text(dropdownValue),
                  ),
                      // Submit and cancel buttons
                      Row(
                        children: [
                          Expanded(
                            child: GreenElevatedButton(
                                text: "Submit",
                                onPressed: () async {
                                  List<bool> validation = [true, true];
                                  if (_typeController.text.isEmpty) {
                                    validation[0] = !validation[0];
                                  }
                                  if (_textController.text.isEmpty) {
                                    validation[1] = !validation[1];
                                  }
                                          
                                  bool isValid =
                                      plantsEditCubit.updateState(validation);
                                  if (!isValid) {
                                  } else {
                                    Map<String, dynamic> data = {
                                      "birthdate": DateTime.now(),
                                      "boardNo": 1,
                                      "subtype": _textController.text,
                                      "type": _typeController.text,
                                    };
                                    await plantStatusCubit
                                        .addPlant(data, _userReference)
                                        .then((value) {
                                      Navigator.pop(context);
                                      _textController.clear();
                                      _typeController.clear();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text("Plant added succesfully!")));
                                    });
                                  }
                                }),
                          ),
                          Expanded(
                            child: WhiteElevatedButton(
                                text: "Cancel",
                                onPressed: () {
                                  Navigator.pop(context);
                                  _textController.clear();
                                  _typeController.clear();
                                }),
                          )
                        ],
                      )
                    ],
                  );
                },
              ),
            ),
          );
        });
  }

  // Plant deletion form function
  void showDeleteForm(BuildContext context, PlantData plant) {
    PlantStatusCubit plantStatusCubit = BlocProvider.of<PlantStatusCubit>(context);
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
                  title: Text("Are you sure?"),
                  content: Container(
                  width: double.maxFinite, // Set maximum width
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Set column to minimum size
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RedElevatedButton(
                              text: "Yes",
                              onPressed: () async {
                                plantStatusCubit
                                    .removePlant(
                                        plant.plantReference, _userReference)
                                    .then((value) {
                                  Navigator.pop(context);Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Item deleted succesfully!")));
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
              ));
        });
  }

}

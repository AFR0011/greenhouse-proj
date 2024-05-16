/// Plants page - view plants and sensor readings
///
/// TODO:
/// - Chat graphs
///
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/greenhouse_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/plants_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/input.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class PlantsPage extends StatelessWidget {
  final UserCredential userCredential;

  const PlantsPage({super.key, required this.userCredential});

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
        BlocProvider(create: (context) => PlantStatusCubit()),
        BlocProvider(create: (context) => ReadingsCubit()),
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
  // Custom theme
  final ThemeData customTheme = theme;

  // Text controllers
  final TextEditingController _textController = TextEditingController();

  // Dispose (destructor)
  @override
  void dispose() {
    _textController.dispose();
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
      appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          )),

      // Plants section
      body: Column(
        children: [
          // Plants subheading
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: const Text(
                "Plants",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
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
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: plantList.length,
                    itemBuilder: (context, index) {
                      PlantData plant = plantList[index]; //plant data

                      // Display plant info
                      return ListTile(
                        title: Text(plant.type),
                        subtitle: Text(plant.subtype),
                        trailing:WhiteElevatedButton(
                          // Show details and sensor readings
                          text: 'Details',
                          onPressed: () {
                            // _showPlantDetails(plant);
                            showDialog(context: context, builder: (context) => PlantDetailsDialog(plant:plant));
                          },
                        ),
                      );
                    },
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
}

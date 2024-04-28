/// TODO:
/// - Separate cubits for plants and readings in plant_status
///   They're sharing the same state, so can't show properly
///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/services/cubit/greenhouse_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/plants_cubit.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/text_styles.dart';
import 'package:greenhouse_project/utils/theme.dart';

class PlantsPage extends StatelessWidget {
  final UserCredential userCredential;

  const PlantsPage({super.key, required this.userCredential});

  @override
  Widget build(BuildContext context) {
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

class _PlantsPageState extends State<_PlantsPageContent> {
  // User info
  late String _userRole = "";
  late String _userName = "";
  late DocumentReference _userReference;
  // Custom theme
  final ThemeData customTheme = theme;
  // Text Controllers
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<UserInfoCubit>().getUserInfo(widget.userCredential);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BuildContext mainContext = context;
    return BlocConsumer<UserInfoCubit, HomeState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is UserInfoLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is UserInfoLoaded) {
          // Assign user info
          _userRole = state.userRole;
          _userName = state.userName;
          _userReference = state.userReference;
          return Theme(
            data: customTheme,
            child: _createPlantsPage(mainContext),
          );
        } else {
          return const Center(
            child: Text('Unexpected state'),
          );
        }
      },
    );
  }

  Widget _createPlantsPage(BuildContext mainContext) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(mainContext);
            },
            icon: const Icon(Icons.arrow_back),
          )),
      body: Column(
        children: [
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(mainContext).size.width - 20,
            child: const Text(
              "Plants",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          // Use BlocBuilder for plants
          BlocBuilder<PlantStatusCubit, PlantStatusState>(
            builder: (context, state) {
              if (state is PlantsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PlantsLoaded) {
                List<PlantData> plantList = state.plants;
                if (plantList.isEmpty) {
                  return const Center(child: Text("No Plants..."));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: plantList.length,
                    itemBuilder: (context, index) {
                      PlantData plant = plantList[index];
                      return ListTile(
                        title: Text(plant.type),
                        subtitle: Text(plant.subtype),
                        trailing: GreenElevatedButton(
                          text: 'Details',
                          onPressed: () {
                            _showPlantDetails(mainContext, plant);
                          },
                        ),
                      );
                    },
                  );
                }
              } else if (state is PlantsError) {
                print(state.error.toString());
                return Center(child: Text(state.error.toString()));
              } else {
                return const Center(child: Text('Unexpected State'));
              }
            },
          ),
        ],
      ),
    );
  }

  void _showPlantDetails(BuildContext mainContext, PlantData plant) {
    showDialog(
      context: mainContext,
      builder: (context) {
        return Dialog(
          child: Column(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(mainContext);
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
              _showReadings(mainContext, plant),
            ],
          ),
        );
      },
    );
  }

  Widget _showReadings(BuildContext mainContext, PlantData plant) {
    final ReadingsCubit readingsCubit =
        BlocProvider.of<ReadingsCubit>(mainContext);

    return BlocBuilder<ReadingsCubit, GreenhouseState>(
      bloc: readingsCubit,
      builder: (context, state) {
        if (state is ReadingsLoading ||
            [EquipmentLoaded, EquipmentLoading]
                .contains(state)) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ReadingsLoaded) {
          // Get list of ReadingsData
          final readings = state.readings;

          // Get the latest readings set
          Set<Map<String, dynamic>> latestAllReadings =
              readings.last.allReadings;

          // Get the latest reading key-value pairs (e.g. "gas":99)
          Map<String, dynamic>? latestReading = latestAllReadings
              .elementAtOrNull(plant.boardNo - 1)?[plant.boardNo.toString()];

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
        } else if (state is ReadingsError) {
          return Text("An error occurred: ${state.error}");
        } else {
          return const Text("Something went wrong...");
        }
      },
    );
  }
}

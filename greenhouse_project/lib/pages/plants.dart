/// Plants page - view plants and sensor readings
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/firebase_options.dart';
import 'package:greenhouse_project/services/cubit/greenhouse_cubit.dart';
import 'package:greenhouse_project/services/cubit/home_cubit.dart';
import 'package:greenhouse_project/services/cubit/plants_cubit.dart';
import 'package:greenhouse_project/services/cubit/plants_edit_cubit.dart';
import 'package:greenhouse_project/utils/appbar.dart';
import 'package:greenhouse_project/utils/buttons.dart';
import 'package:greenhouse_project/utils/dialogs.dart';
import 'package:greenhouse_project/utils/input.dart';
import 'package:greenhouse_project/utils/theme.dart';

// Web VAPID key for Firebase Cloud Messaging
const String webVapidKey =
    "BKWvS-G0BOBMCAmBJVz63de5kFb5R2-OVxrM_ulKgCoqQgVXSY8FqQp7QM5UoC5S9hKs5crmzhVJVyyi_sYDC9U";

// Plants page widget
class PlantsPage extends StatelessWidget {
  final UserCredential userCredential;
  final DocumentReference userReference;

  const PlantsPage({
    Key? key,
    required this.userCredential,
    required this.userReference,
  }) : super(key: key);

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

// Content of the Plants page
class _PlantsPageContent extends StatefulWidget {
  final UserCredential userCredential;

  const _PlantsPageContent({Key? key, required this.userCredential})
      : super(key: key);

  @override
  State<_PlantsPageContent> createState() => _PlantsPageState();
}

// State of the Plants page content
class _PlantsPageState extends State<_PlantsPageContent> {
  late DocumentReference _userReference;
  late String _userRole;

  final ThemeData customTheme = theme;

  // Text controllers
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserInfoCubit, HomeState>(
      builder: (context, state) {
        if (state is UserInfoLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is UserInfoLoaded) {
          _userReference = state.userReference;
          _userRole = state.userRole;
          return Theme(data: customTheme, child: _createPlantsPage());
        } else if (state is UserInfoError) {
          return Center(child: Text('Error: ${state.errorMessage}'));
        } else {
          return const Center(
            child: Text('Unexpected state'),
          );
        }
      },
    );
  }

  Widget _createPlantsPage() {
    return Scaffold(
      appBar: createAltAppbar(context, "Plants"),
      body: Container(
        height: MediaQuery.of(context).size.height,
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 20,
                ),
              ),
              BlocBuilder<PlantStatusCubit, PlantStatusState>(
                builder: (context, state) {
                  if (state is PlantsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PlantsLoaded) {
                    List<PlantData> plantList = state.plants;
                    if (plantList.isEmpty) {
                      return const Center(child: Text("No Plants..."));
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SizedBox(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: plantList.length,
                                itemBuilder: (context, index) {
                                  PlantData plant = plantList[index];
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
                                      title: Text(
                                        plant.type,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      subtitle: Text(plant.subtype),
                                      trailing: WhiteElevatedButton(
                                        text: 'Details',
                                        onPressed: () {
                                          BuildContext mainContext = context;
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  PlantDetailsDialog(
                                                      plant: plant,
                                                      userRole: _userRole,
                                                      mainContext: mainContext,
                                                      removePlant:
                                                          showDeleteForm));
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    }
                  } else if (state is PlantsError) {
                    return Center(child: Text('Error: ${state.error}'));
                  } else {
                    return const Center(child: Text('Unexpected State'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _userRole == "manager"
          ? GreenElevatedButton(
              text: "Add Plant", onPressed: () => showAdditionForm(context))
          : null,
    );
  }

  void showAdditionForm(BuildContext context) {
    PlantStatusCubit plantStatusCubit =
        BlocProvider.of<PlantStatusCubit>(context);

    PlantsEditCubit plantsEditCubit = BlocProvider.of<PlantsEditCubit>(context);
    String dropdownValue = "1";
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
            content: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                width: MediaQuery.of(context).size.width * .6,
                child: BlocBuilder<PlantsEditCubit, List<bool>>(
                  bloc: plantsEditCubit,
                  builder: (context, state) {
                    return Column(
                      mainAxisSize:
                          MainAxisSize.min, // Set column to minimum size
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputTextField(
                            controller: _typeController,
                            errorText: state[0]
                                ? null
                                : "Type should be longer than 1 characters.",
                            labelText: "Type"),
                        InputTextField(
                            controller: _textController,
                            errorText: state[1]
                                ? null
                                : "Subtype should be longer than 2 characters.",
                            labelText: "Subtype"),
                        DropdownButtonFormField<String>(
                          value: dropdownValue,
                          decoration: const InputDecoration(
                            labelText: "Board No",
                          ),
                          items: <String>["1"]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: null,
                          onTap: () {},
                          disabledHint: Text(dropdownValue),
                        ),
                        SizedBox(
                          height: 10,
                        ),
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Plant added successfully!")));
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
            ),
          );
        });
  }

  void showDeleteForm(BuildContext context, PlantData plant) {
    PlantStatusCubit plantStatusCubit =
        BlocProvider.of<PlantStatusCubit>(context);
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
              content: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  width: MediaQuery.of(context).size.width * .6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Plant deleted successfully!")));
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
                ),
              ));
        });
  }

  Future<void> _initializeUserInfo() async {
    try {
      if (DefaultFirebaseOptions.currentPlatform !=
          DefaultFirebaseOptions.android) {
        context.read<UserInfoCubit>().getUserInfo(widget.userCredential, null);
      } else {
        String? deviceFcmToken =
            await FirebaseMessaging.instance.getToken(vapidKey: webVapidKey);
        if (mounted) {
          context
              .read<UserInfoCubit>()
              .getUserInfo(widget.userCredential, deviceFcmToken);
        }
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }
}

import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'greenhouse_state.dart';
part 'readings_cubit.dart';
part 'equipment_cubit.dart';

class GreenhouseCubit extends Cubit<GreenhouseState> {
  GreenhouseCubit(super.initialState);
}

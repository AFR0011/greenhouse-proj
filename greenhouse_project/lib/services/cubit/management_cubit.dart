import "package:cloud_firestore/cloud_firestore.dart";
import "package:emailjs/emailjs.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";

part 'management_state.dart';
part 'manage_employees_cubit.dart';

class ManagementCubit extends Cubit<ManagementState> {
  ManagementCubit(super.initialState);
}

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:mailer/mailer.dart";
import "package:mailer/smtp_server.dart";
import "package:mailer/smtp_server/gmail.dart";

part 'management_state.dart';
part 'manage_tasks_cubit.dart';
part 'manage_workers_cubit.dart';

class ManagementCubit extends Cubit<ManagementState> {
  ManagementCubit(super.initialState);
}

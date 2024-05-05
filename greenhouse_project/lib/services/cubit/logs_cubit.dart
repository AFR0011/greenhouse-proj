import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greenhouse_project/services/cubit/equipment_status_cubit.dart';
import 'package:meta/meta.dart';

part 'logs_state.dart';

class LogsCubit extends Cubit<LogsState> {
  final CollectionReference log = 
      FirebaseFirestore.instance.collection('logs');

  LogsCubit() : super(LogsLoading()){
    _getLogs();
  }
   
   _getLogs() {
    log
      .orderBy('timestamp', descending: true)
      .snapshots()
      .listen(() { })
   }
}

class Logs {
  final String action;
  final String description;
  final DocumentReference externalId;
  final DateTime timeStamp;
  final String type;
  final DocumentReference userId;

  Logs(
   {required this.action,
    required this.description,
    required this.externalId,
    required this.timeStamp,
    required this.type,
    required this.userId});

  factory Logs.fromFirestore(DocumentSnapshot doc) {

  }
}

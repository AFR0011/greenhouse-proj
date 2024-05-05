import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greenhouse_project/services/cubit/equipment_status_cubit.dart';
import 'package:meta/meta.dart';

part 'logs_state.dart';

class LogsCubit extends Cubit<LogsState> {
  final CollectionReference log = 
      FirebaseFirestore.instance.collection('logs');

  final DocumentReference userReference;

  LogsCubit(this.userReference) : super(LogsLoading()){
    
  }
   
   _getLogs() async {
    
    log
      .orderBy('timestamp', descending: true)
      .snapshots()
      .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<LogsData> logs = snapshot.docs
          .map((doc) => LogsData.fromFirestore(doc))
          .toList();
          emit(LogsLoaded([...logs]));
        }
       });
   }
}

class LogsData {
  final String action;
  final String description;
  final DocumentReference externalId;
  final DateTime timeStamp;
  final String type;
  final DocumentReference userId; 

  LogsData(
   {required this.action,
    required this.description,
    required this.externalId,
    required this.timeStamp,
    required this.type,
    required this.userId});

  factory LogsData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LogsData(
      action: data['action'],
      description: data['description'],
      externalId: doc.reference,
      timeStamp: (data['timestamp'] as Timestamp).toDate(),
      type: data['type'],
      userId: doc.reference
      );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

part 'logs_state.dart';

class LogsCubit extends Cubit<LogsState> {
  final CollectionReference logs =
      FirebaseFirestore.instance.collection('logs');

  bool _isActive = true;

  LogsCubit() : super(LogsLoading()) {
    _getLogs();
  }

  void _getLogs() {
    if (!_isActive) return;
    try {
      logs
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<LogsData> logs =
              snapshot.docs.map((doc) => LogsData.fromFirestore(doc)).toList();
          if (_isActive) emit(LogsLoaded([...logs]));
        }
      });
    } catch (error) {
      if (_isActive) emit(LogsError(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
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
        userId: doc.reference);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'programs_state.dart';

class ProgramsCubit extends Cubit<ProgramsState> {
  final CollectionReference programs =
      FirebaseFirestore.instance.collection('programs');

  final CollectionReference logs =
      FirebaseFirestore.instance.collection('logs');

  bool _isActive = true;

  ProgramsCubit() : super(ProgramsLoading()) {
    _getPrograms();
  }

  void _getPrograms() {
    if (!_isActive) return;
    programs.orderBy('creationDate', descending: true).snapshots().listen(
        (snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final List<ProgramData> programs =
            snapshot.docs.map((doc) => ProgramData.fromFirestore(doc)).toList();
        emit(ProgramsLoaded([...programs]));
      }
    }, onError: (error) {
      emit(ProgramsError(error));
    });
  }

  Future<void> addProgram(
      Map<String, dynamic> data, DocumentReference userReference) async {
    if (!_isActive) return;

    emit(ProgramsLoading());
    try {
      DocumentReference externalId = await programs.add(data);

      logs.add({
        "action": "create",
        "description": "Program added by user at ${Timestamp.now().toString()}",
        "timestamp": Timestamp.now(),
        "type": "Program",
        "userId": userReference,
        "externalId": externalId,
      });
    } catch (error) {
      emit(ProgramsError(error.toString()));
    }
  }

  Future<void> removeProgram(
      DocumentReference item, DocumentReference userReference) async {
    if (!_isActive) return;

    emit(ProgramsLoading());
    try {
      Map<String, dynamic> data =
          item.get().then((doc) => doc.data()) as Map<String, dynamic>;
      logs.add({
        "action": "delete",
        "description":
            "Program removed by user at ${Timestamp.now().toString()} program details: ${data["title"]}",
        "timestamp": Timestamp.now(),
        "type": "Program",
        "userId": userReference,
      });

      await item.delete();
      _getPrograms();
    } catch (error) {
      emit(ProgramsError(error.toString()));
    }
  }

  Future<void> updatePrograms(DocumentReference item, Map<String, dynamic> data,
      DocumentReference userReference) async {
    if (!_isActive) return;

    emit(ProgramsLoading());
    try {
      await item.set(data, SetOptions(merge: true));
      _getPrograms();
      logs.add({
        "action": "Update",
        "description":
            "Program updated by user at ${Timestamp.now().toString()}",
        "timestamp": Timestamp.now(),
        "type": "Program",
        "userId": userReference,
        "externalId": item,
      });
    } catch (error) {
      emit(ProgramsError(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

class ProgramData {
  final int action;
  final int condition;
  final int limit;
  final String equipment;
  final DateTime creationDate;
  final String title;
  final DocumentReference reference;

  ProgramData(
      {required this.action,
      required this.condition,
      required this.limit,
      required this.equipment,
      required this.creationDate,
      required this.title,
      required this.reference});

  factory ProgramData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgramData(
        action: data['action'],
        condition: data['condition'],
        limit: data['limit'],
        equipment: data['equipment'],
        title: data['title'],
        creationDate: (data['creationDate'] as Timestamp).toDate(),
        reference: doc.reference);
  }
}

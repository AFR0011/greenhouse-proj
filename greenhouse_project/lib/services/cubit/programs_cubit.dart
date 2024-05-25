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
      final List<ProgramData> programs =
          snapshot.docs.map((doc) => ProgramData.fromFirestore(doc)).toList();
      emit(ProgramsLoaded([...programs]));
    }, onError: (error) {
      emit(ProgramsError(error));
    });
  }

  void addProgram(
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

  void removeProgram(
      DocumentReference program, DocumentReference userReference) async {
    if (!_isActive) return;

    emit(ProgramsLoading());
    try {
      DocumentSnapshot docSnapshot = await program.get();
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      logs.add({
        "action": "delete",
        "description":
            "Program removed by user at ${Timestamp.now().toString()} program details: ${data["title"]}",
        "timestamp": Timestamp.now(),
        "type": "Program",
        "userId": userReference,
      });

      await program.delete();
    } catch (error) {
      emit(ProgramsError(error.toString()));
    }
  }

  void updatePrograms(DocumentReference program, Map<String, dynamic> data,
      DocumentReference userReference) async {
    if (!_isActive) return;

    emit(ProgramsLoading());
    try {
      await program.update(data);
      await logs.add({
        "action": "Update",
        "description":
            "Program updated by user at ${Timestamp.now().toString()}",
        "timestamp": Timestamp.now(),
        "type": "Program",
        "userId": userReference,
        "externalId": program,
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
  final String action;
  final String condition;
  final double limit;
  final String equipment;
  final DateTime creationDate;
  final String title;
  final String description;
  final DocumentReference reference;

  ProgramData(
      {required this.action,
      required this.condition,
      required this.limit,
      required this.equipment,
      required this.creationDate,
      required this.title,
      required this.description,
      required this.reference});

  factory ProgramData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgramData(
        action: data['action'],
        condition: data['condition'],
        limit: data['limit'],
        equipment: data['equipment'],
        title: data['title'],
        description: data['description'],
        creationDate: (data['creationDate'] as Timestamp).toDate(),
        reference: doc.reference);
  }
}

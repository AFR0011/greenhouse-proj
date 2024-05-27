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
  bool _isProcessing = false;

  ProgramsCubit() : super(ProgramsLoading()) {
    _getPrograms();
  }

  void _getPrograms() {
    if (!_isActive) return;
    programs.orderBy('creationDate', descending: true).snapshots().listen(
        (snapshot) {
      final List<ProgramData> programs =
          snapshot.docs.map((doc) => ProgramData.fromFirestore(doc)).toList();
      if (_isActive && !_isProcessing) emit(ProgramsLoaded([...programs]));
    }, onError: (error) {
      if (_isActive && !_isProcessing) emit(ProgramsError(error));
    });
  }

  void addProgram(
      Map<String, dynamic> data, DocumentReference userReference) async {
    if (!_isActive) return;
    _isProcessing = true;
    emit(ProgramsLoading());
    try {
      DocumentReference externalId = await programs.add(data);

      DocumentSnapshot userSnapshot = await userReference.get();
      String name = userSnapshot.get("name");
      String surname = userSnapshot.get("surname");
      String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
      String stringTime = Timestamp.now().toDate().toString().substring(11, 19);
      String title = data["title"];

      await logs.add({
        "action": "create",
        "description":
            "program \"$title\" added by \"$name $surname\" on $stringDate at $stringTime",
        "timestamp": Timestamp.now(),
        "type": "Program",
        "userId": userReference,
        "externalId": externalId,
      });
    } catch (error) {
      emit(ProgramsError(error.toString()));
    }
    _isProcessing = false;
    _getPrograms();
  }

  void removeProgram(
      DocumentReference program, DocumentReference userReference) async {
    if (!_isActive) return;
    _isProcessing = true;
    emit(ProgramsLoading());
    try {
      DocumentReference externalId = program;
      DocumentSnapshot docSnapshot = await program.get();
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      DocumentSnapshot userSnapshot = await userReference.get();
      String name = userSnapshot.get("name");
      String surname = userSnapshot.get("surname");
      String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
      String stringTime = Timestamp.now().toDate().toString().substring(11, 19);
      String title = data["title"];

      await logs.add({
        "action": "delete",
        "description":
            "program \"$title\" deleted by \"$name $surname\" on $stringDate at $stringTime",
        "timestamp": Timestamp.now(),
        "type": "Program",
        "userId": userReference,
        "externalId": externalId,
      });

      await program.delete();
    } catch (error) {
      emit(ProgramsError(error.toString()));
    }
    _isProcessing = false;
    _getPrograms();
  }

  void updatePrograms(DocumentReference program, Map<String, dynamic> data,
      DocumentReference userReference) async {
    if (!_isActive) return;
    _isProcessing = true;
    emit(ProgramsLoading());
    try {
      await program.update(data);

      DocumentReference externalId = program;

      DocumentSnapshot userSnapshot = await userReference.get();
      String name = userSnapshot.get("name");
      String surname = userSnapshot.get("surname");
      String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
      String stringTime = Timestamp.now().toDate().toString().substring(11, 19);
      String title = data["title"];

      await logs.add({
        "action": "update",
        "description":
            "program \"$title\" updated by \"$name $surname\" on $stringDate at $stringTime",
        "timestamp": Timestamp.now(),
        "type": "Program",
        "userId": userReference,
        "externalId": externalId,
      });
    } catch (error) {
      emit(ProgramsError(error.toString()));
    }
    _isProcessing = false;
    _getPrograms();
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
        limit: data['limit'].roundToDouble(),
        equipment: data['equipment'],
        title: data['title'],
        description: data['description'],
        creationDate: (data['creationDate'] as Timestamp).toDate(),
        reference: doc.reference);
  }
}

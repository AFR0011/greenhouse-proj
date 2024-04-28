import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'programs_state.dart';

class ProgramsCubit extends Cubit<ProgramsState> {
  final CollectionReference programs =
      FirebaseFirestore.instance.collection('programs');

  ProgramsCubit() : super(ProgramsLoading()) {
    _getPrograms();
  }

  void _getPrograms() {
    programs
        .orderBy('creationDate', descending: true)
        .snapshots()
        .listen((snapshot) {
          if(snapshot.docs.isNotEmpty){
            final List<ProgramData> programs =
            snapshot.docs.map((doc) => ProgramData.fromFirestore(doc)).toList();
            emit(ProgramsLoaded([...programs]));
          }
    }, onError: (error){
      print(error.toString());
      emit(ProgramError(error));
    });
  }

  Future<void> addProgram(Map<String, dynamic> data) async {
    emit(ProgramsLoading());
    try {
      await programs.add(data);
    } catch (error) {
      emit(ProgramError(error.toString()));
    }
  }

  Future<void> removeProgram(DocumentReference item) async {
    emit(ProgramsLoading());
    try {
      await item.delete();
      _getPrograms();
    } catch (error) {
      emit(ProgramError(error.toString()));
    }
  }

  Future <void> updatePrograms(
      DocumentReference item, Map<String, dynamic> data) async {
    emit(ProgramsLoading());
    try {
      await item.set(data, SetOptions(merge: true));
      _getPrograms();
    } catch (error) {
      emit(ProgramError(error.toString()));
    }
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

  ProgramData({
    required this.action,
    required this.condition,
    required this.limit,
    required this.equipment,
    required this.creationDate,
    required this.title,
    required this.reference
  });

  factory ProgramData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgramData(
      action: data['action'],
      condition: data['condition'],
      limit: data['limit'],
      equipment: data['equipment'],
      title: data['title'],
      creationDate: (data['creationDate'] as Timestamp).toDate(),
      reference: doc.reference
    );
  }
}

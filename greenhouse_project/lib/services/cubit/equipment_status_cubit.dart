import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'equipment_status_state.dart';

class EquipmentStatusCubit extends Cubit<EquipmentStatusState> {
  final CollectionReference equipment =
      FirebaseFirestore.instance.collection('equipment');

  EquipmentStatusCubit() : super(StatusLoading()) {
    _fetchEquipmentStaus();
  }

  _fetchEquipmentStaus() {
    equipment.snapshots().listen((snapshot) {
      final List<EquipmentStatus> status = snapshot.docs
          .map((doc) => EquipmentStatus.fromFirestore(doc))
          .toList();
      emit(StatusLoaded([...status]));
    }, onError: (error) {
      print(error.toString());
      emit(StatusError(error.toString()));
    });
  }
}

class EquipmentStatus {
  final int board;
  final bool status;
  final String type;

  EquipmentStatus({
    required this.board,
    required this.status,
    required this.type,
  });

  factory EquipmentStatus.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EquipmentStatus(
      board: data['board'],
      status: data['status'],
      type: data['type'],
    );
  }
}

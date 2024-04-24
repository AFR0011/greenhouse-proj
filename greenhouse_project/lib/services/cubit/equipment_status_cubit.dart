import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/pages/equipmentStatus.dart';
import 'package:greenhouse_project/services/cubit/greenhouse_cubit.dart';

part 'equipment_status_state.dart';

class EquipmentStatusCubit extends Cubit<EquipmentStatusState> {
  final CollectionReference equipment = 
    FirebaseFirestore.instance.collection('equipment');

  EquipmentStatusCubit () : super(StatusLoading()) {
    _fetchEquipmentStaus();
  }

  _fetchEquipmentStaus() {
    equipment
    .orderBy('status', descending: true)
    .snapshots()
    .listen((snapshot) {
      if(snapshot.docs.isNotEmpty){
        final List<EquipmentStatus> status =
        snapshot.docs.map((doc) => EquipmentStatus.fromFirestore(doc)).toList();
        emit(StatusLoaded([...status]));
      }       
     });
  }
  void switchStatus(DocumentReference reference, bool currentStatus) async{
    reference.update(
      
       {'status': !currentStatus}
    );
  }
}

class EquipmentStatus{
  final int board;
  final bool status;
  final String type;
  final DocumentReference reference;

  EquipmentStatus({
    required this.board,
    required this.status,
    required this.type,
    required this.reference
  });

  factory EquipmentStatus.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EquipmentStatus(
      board: data['board'],
      status: data['status'],
      type: data['type'],
      reference: doc.reference
    );
  }
}



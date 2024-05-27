import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'equipment_status_state.dart';

class EquipmentStatusCubit extends Cubit<EquipmentStatusState> {
  final CollectionReference equipment =
      FirebaseFirestore.instance.collection('equipment');

  final CollectionReference logs =
      FirebaseFirestore.instance.collection('logs');

  bool _isActive = true;
  bool _isProcessing = false;

  EquipmentStatusCubit() : super(StatusLoading()) {
    _getEquipmentStatus();
  }

  void _getEquipmentStatus() {
    if (!_isActive) return;
    try {
      equipment
          .orderBy('type', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<EquipmentStatus> status = snapshot.docs
              .map((doc) => EquipmentStatus.fromFirestore(doc))
              .toList();
          if (_isActive && !_isProcessing) emit(StatusLoaded([...status]));
        }
      });
    } catch (error) {
      if (_isActive && !_isProcessing) emit(StatusError(error.toString()));
    }
  }

  void toggleStatus(DocumentReference userReference,
      DocumentReference equipment, bool currentStatus) async {
    if (!_isActive) return;
    _isProcessing = true;
    equipment.update({'status': !currentStatus});

    String equipmentType = (await equipment.get()).get("type");
    DocumentSnapshot userSnapshot = await userReference.get();
    String name = userSnapshot.get("name");
    String surname = userSnapshot.get("surname");
    String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
    String stringTime = Timestamp.now().toDate().toString().substring(11, 19);

    await logs.add({
      "action": "Update",
      "description":
          "$equipmentType toggled ${!currentStatus ? "on" : "off"} by \"$name $surname\" on $stringDate at $stringTime",
      "timestamp": Timestamp.now(),
      "type": "equipment status",
      "userId": userReference,
      "externalId": equipment,
    });

    _isProcessing = false;
    _getEquipmentStatus();
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

class EquipmentStatus {
  final int board;
  final bool status;
  final String type;
  final DocumentReference reference;

  EquipmentStatus(
      {required this.board,
      required this.status,
      required this.type,
      required this.reference});

  factory EquipmentStatus.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EquipmentStatus(
        board: data['board'],
        status: data['status'],
        type: data['type'],
        reference: doc.reference);
  }
}

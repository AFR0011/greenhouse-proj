part of 'greenhouse_cubit.dart';

class EquipmentCubit extends GreenhouseCubit {
  final CollectionReference equipment =
      FirebaseFirestore.instance.collection('equipment');

  bool _isActive = true;

  EquipmentCubit() : super(EquipmentLoading()) {
    _fetchEquipmentInfo();
  }

  _fetchEquipmentInfo() {
    if (!_isActive) return;
    equipment
        .orderBy('status', descending: true)
        .snapshots()
        .listen((snapshot) {
      final List<EquipmentData> equipment =
          snapshot.docs.map((doc) => EquipmentData.fromFirestore(doc)).toList();

      emit(EquipmentLoaded([...equipment]));
    });
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

class EquipmentData {
  final int board;
  final bool status;
  final String type;

  EquipmentData({
    required this.board,
    required this.status,
    required this.type,
  });

  factory EquipmentData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EquipmentData(
      board: data['board'],
      status: data['status'],
      type: data['type'],
    );
  }
}

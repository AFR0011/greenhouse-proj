import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/foundation.dart";

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final CollectionReference inventory =
      FirebaseFirestore.instance.collection('inventory');

  InventoryCubit() : super(InventoryLoading()) {
    _getInventory();
  }

  void _getInventory() {
    emit(InventoryLoading());
    inventory.snapshots().listen((snapshot) {
      final List<InventoryData> inventory =
          snapshot.docs.map((doc) => InventoryData.fromFirestore(doc)).toList();
      emit(InventoryLoaded([...inventory]));
    }, onError: (error) {
      emit(InventoryError(error.toString()));
    });
  }
}

class InventoryData {
  final num amount;
  final String description;
  final String name;
  final DateTime timeAdded;

  InventoryData({
    required this.amount,
    required this.description,
    required this.name,
    required this.timeAdded,
  });

  factory InventoryData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryData(
      amount: data['amount'],
      description: data['descritpion'] ?? ' ',
      name: data['name'],
      timeAdded: (data['time added'] as Timestamp).toDate(),
    );
  }
}

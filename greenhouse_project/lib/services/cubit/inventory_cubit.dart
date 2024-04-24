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

  Future<void> addInventory(Map<String, dynamic> data) async {
    emit(InventoryLoading());
    try {
      await inventory.add(data);
    } catch (error) {
      emit(InventoryError(error.toString()));
    }
  }

  Future<void>  removeInventory(DocumentReference item) async {
    emit(InventoryLoading());
    try {
      await item.delete();
      _getInventory();
    } catch (error) {
      emit(InventoryError(error.toString()));
    }
  }

  Future <void> updateInventory(
      DocumentReference item, Map<String, dynamic> data) async {
    emit(InventoryLoading());
    try {
      await item.set(data, SetOptions(merge: true));
      _getInventory();
    } catch (error) {
      emit(InventoryError(error.toString()));
    }
  }
}

class InventoryData {
  final num amount;
  final String description;
  final String name;
  final DateTime timeAdded;
  final bool isPending;
  final DocumentReference reference;

  InventoryData({
    required this.amount,
    required this.description,
    required this.name,
    required this.timeAdded,
    required this.isPending,
    required this.reference,
  });

  factory InventoryData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryData(
      amount: data['amount'],
      description: data['description'] ?? ' ',
      name: data['name'],
      timeAdded: (data['timeAdded'] as Timestamp).toDate(),
      isPending: data['pending'],
      reference: doc.reference,
    );
  }
}

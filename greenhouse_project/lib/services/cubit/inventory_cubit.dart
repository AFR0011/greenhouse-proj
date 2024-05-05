import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/foundation.dart";

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {

  final CollectionReference inventory =
      FirebaseFirestore.instance.collection('inventory');

      final CollectionReference logs =
      FirebaseFirestore.instance.collection('logs');

  InventoryCubit() : super(InventoryLoading()) {
    _getInventory();
  }

  void _getInventory() {
    inventory.snapshots().listen((snapshot) {
      final List<InventoryData> inventory =
          snapshot.docs.map((doc) => InventoryData.fromFirestore(doc)).toList();
      emit(InventoryLoaded([...inventory]));
    }, onError: (error) {
      emit(InventoryError(error.toString()));
    });
  }

  Future<void> addInventory(Map<String, dynamic> data,
   DocumentReference userReference) async {
    try {
      DocumentReference externalId = await inventory.add(data);

      logs.add({
        "action": "create",
        "description": "inventory added by user at ${Timestamp.now().toString()}",
        "timestamp": Timestamp.now(),
        "type": "inventory",
        "userId": userReference,
        "externalId": externalId,
        });    

    } catch (error) {
      emit(InventoryError(error.toString()));
    }
  }

  Future<void> removeInventory(DocumentReference item, DocumentReference userReference) async {
    try {
      logs.add({
        "action": "Delete",
        "description": "Item deleted by user at ${Timestamp.now().toString()}",
        "timestamp": Timestamp.now(),
        "type": "Inventory Item",
        "userId": userReference,
        "externalId": item,
        });

      await item.delete();

    } catch (error) {
      emit(InventoryError(error.toString()));
    }
  }

  Future<void> updateInventory(
      DocumentReference item, Map<String, dynamic> data,
       DocumentReference userReference) async {
    try {
      await item.set(data, SetOptions(merge: true));

      logs.add({
        "action": "Update",
        "description": "Item updated by user at ${Timestamp.now().toString()}",
        "timestamp": Timestamp.now(),
        "type": "Inventory Item",
        "userId": userReference,
        "externalId": item,
        });

    } catch (error) {
      emit(InventoryError(error.toString()));
    }
  }

  Future<void> approveItem(DocumentReference itemRef, userReference) async {
  try {
    await itemRef.set({"pending": false}, SetOptions(merge: true));

    logs.add({
        "action": "Approve",
        "description": "Inventory approved by user at ${Timestamp.now().toString()}",
        "timestamp": Timestamp.now(),
        "type": "Inventory Item",
        "userId": userReference,
        "externalId": itemRef,
        });

  }
  catch (error){
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

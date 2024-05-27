import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/foundation.dart";

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final CollectionReference inventory =
      FirebaseFirestore.instance.collection('inventory');

  final CollectionReference logs =
      FirebaseFirestore.instance.collection('logs');

  bool _isActive = true;
  bool _isProcessing = false;

  InventoryCubit() : super(InventoryLoading()) {
    _getInventory();
  }

  void _getInventory() {
    if (!_isActive) return;
    inventory.snapshots().listen((snapshot) {
      final List<InventoryData> inventory =
          snapshot.docs.map((doc) => InventoryData.fromFirestore(doc)).toList();
      if (_isActive && !_isProcessing) emit(InventoryLoaded([...inventory]));
    }, onError: (error) {
      if (_isActive && !_isProcessing) emit(InventoryError(error.toString()));
    });
  }

  Future<void> addInventory(
      Map<String, dynamic> data, DocumentReference userReference) async {
    if (!_isActive) return;
    _isProcessing = true;
    try {
      DocumentReference externalId = await inventory.add(data);

      DocumentSnapshot userSnapshot = await userReference.get();
      String name = userSnapshot.get("name");
      String surname = userSnapshot.get("surname");
      String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
      String stringTime = Timestamp.now().toDate().toString().substring(11, 19);

      await logs.add({
        "action": "create",
        "description":
            "${data["amount"]} ${data["name"]} added by \"$name $surname\" on $stringDate at $stringTime",
        "timestamp": Timestamp.now(),
        "type": "inventory",
        "userId": userReference,
        "externalId": externalId,
      });
    } catch (error) {
      emit(InventoryError(error.toString()));
    }
    _isProcessing = false;
    _getInventory();
  }

  Future<void> removeInventory(
      DocumentReference item, DocumentReference userReference) async {
    if (!_isActive) return;
    _isProcessing = true;
    try {
      DocumentSnapshot userSnapshot = await userReference.get();
      String name = userSnapshot.get("name");
      String surname = userSnapshot.get("surname");
      String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
      String stringTime = Timestamp.now().toDate().toString().substring(11, 19);
      String itemName = (await item.get()).get("name");

      await logs.add({
        "action": "Delete",
        "description":
            "$itemName deleted by \"$name $surname\" on $stringDate at $stringTime",
        "timestamp": Timestamp.now(),
        "type": "Inventory Item",
        "userId": userReference,
        "externalId": item,
      });

      await item.delete();
    } catch (error) {
      emit(InventoryError(error.toString()));
    }
    _isProcessing = false;
    _getInventory();
  }

  Future<void> updateInventory(DocumentReference item,
      Map<String, dynamic> data, DocumentReference userReference) async {
    if (!_isActive) return;
    _isProcessing = true;

    try {
      await item.update(data);

      DocumentSnapshot userSnapshot = await userReference.get();
      String name = userSnapshot.get("name");
      String surname = userSnapshot.get("surname");
      String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
      String stringTime = Timestamp.now().toDate().toString().substring(11, 19);
      String itemName = (await item.get()).get("name");

      await logs.add({
        "action": "Update",
        "description":
            "$itemName updated by \"$name $surname\" on $stringDate at $stringTime",
        "timestamp": Timestamp.now(),
        "type": "Inventory Item",
        "userId": userReference,
        "externalId": item,
      });
    } catch (error) {
      emit(InventoryError(error.toString()));
    }
    _isProcessing = false;
    _getInventory();
  }

  Future<void> approveItem(DocumentReference item, userReference) async {
    if (!_isActive) return;
    _isProcessing = true;

    try {
      await item.update({"pending": false});

      DocumentSnapshot userSnapshot = await userReference.get();
      String name = userSnapshot.get("name");
      String surname = userSnapshot.get("surname");
      String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
      String stringTime = Timestamp.now().toDate().toString().substring(11, 19);
      String itemName = (await item.get()).get("name");

      await logs.add({
        "action": "Approve",
        "description":
            "$itemName approved by \"$name $surname\" on $stringDate at $stringTime",
        "timestamp": Timestamp.now(),
        "type": "Inventory Item",
        "userId": userReference,
        "externalId": item,
      });
    } catch (error) {
      emit(InventoryError(error.toString()));
    }
    _isProcessing = false;
    _getInventory();
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
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

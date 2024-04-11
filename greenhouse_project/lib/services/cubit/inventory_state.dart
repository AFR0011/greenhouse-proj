
part of 'inventory_cubit.dart';

sealed class InventoryState{}

final class InventoryLoading extends InventoryState{}

final class InventoryLoaded extends InventoryState{

  List<InventoryData> inventory;

  InventoryLoaded(this.inventory);
}

final class InventoryError extends InventoryState{

  String error;

  InventoryError(this.error);
}
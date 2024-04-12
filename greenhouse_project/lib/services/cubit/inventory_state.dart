part of 'inventory_cubit.dart';

@immutable
sealed class InventoryState {}

final class InventoryLoading extends InventoryState {}

final class InventoryLoaded extends InventoryState {
  final List<InventoryData> inventory;

  InventoryLoaded(this.inventory);
}

final class InventoryError extends InventoryState {
  final String error;

  InventoryError(this.error);
}

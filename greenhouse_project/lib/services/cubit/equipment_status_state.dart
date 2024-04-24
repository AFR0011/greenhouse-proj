part of 'equipment_status_cubit.dart';

@immutable
sealed class EquipmentStatusState {}

final class EquipmentStatusInitial extends EquipmentStatusState {}

final class StatusLoading extends EquipmentStatusState {}

final class StatusLoaded extends EquipmentStatusState {
  final List<EquipmentStatus> status;

  StatusLoaded(this.status);
}

final class StatusError extends EquipmentStatusState {
  final String error;
  StatusError(this.error);
}


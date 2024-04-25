part of 'greenhouse_cubit.dart';

@immutable
sealed class GreenhouseState {}

final class ReadingsLoading extends GreenhouseState {}

final class ReadingsLoaded extends GreenhouseState {
  final List<ReadingsData> readings;

  ReadingsLoaded(this.readings);
}

final class ReadingsError extends GreenhouseState {
  final String error;

  ReadingsError(this.error);
}

final class EquipmentLoading extends GreenhouseState {}

final class EquipmentLoaded extends GreenhouseState {
  final List<EquipmentData> equipment;

  EquipmentLoaded(this.equipment);
}

final class ProgramsLoading extends GreenhouseState {}

final class ProgramsLoaded extends GreenhouseState {
  final List<ProgramData> programs;

  ProgramsLoaded(this.programs);
}

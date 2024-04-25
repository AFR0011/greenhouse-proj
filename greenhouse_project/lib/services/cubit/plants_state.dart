part of 'plants_cubit.dart';

@immutable
sealed class PlantStatusState {}

final class PlantStatusLoading extends PlantStatusState {}

final class PlantStatusLoaded extends PlantStatusState {
  List<ReadingsData> readings;
  List<PlantData> plants;

  PlantStatusLoaded(this.readings, this.plants);
}

final class PlantsLoading extends PlantStatusState {}

final class PlantsLoaded extends PlantStatusState {
  List<PlantData> plants;

  PlantsLoaded(this.plants);
}

final class PlantsError extends PlantStatusState {
  String error;

  PlantsError(this.error);
}

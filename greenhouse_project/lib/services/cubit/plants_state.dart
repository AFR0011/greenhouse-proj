part of 'plants_cubit.dart';

@immutable
sealed class PlantStatusState {}

final class PlantsLoading extends PlantStatusState {}

final class PlantsLoaded extends PlantStatusState {
  final List<PlantData> plants;

  PlantsLoaded(this.plants);
}

final class PlantsError extends PlantStatusState {
  final String error;

  PlantsError(this.error);
}

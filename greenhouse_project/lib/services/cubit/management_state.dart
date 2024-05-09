part of 'management_cubit.dart';

@immutable
sealed class ManagementState {}

final class ManageWorkersLoading extends ManagementState {}

final class ManageWorkersLoaded extends ManagementState {
  final List<WorkerData> workers;

  ManageWorkersLoaded(this.workers);
}

final class ManageWorkersError extends ManagementState {
  final String error;

  ManageWorkersError(this.error);
}

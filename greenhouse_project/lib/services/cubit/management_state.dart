part of 'management_cubit.dart';

@immutable
sealed class ManagementState {}

final class ManageWorkersLoading extends ManagementState {}

final class ManageWorkersLoaded extends ManagementState {
  final List<WorkerData> workers;

  ManageWorkersLoaded(this.workers);
}

final class ManageTasksLoading extends ManagementState {}

final class ManageTasksLoaded extends ManagementState {
  final List<TaskData> tasks;

  ManageTasksLoaded(this.tasks);
}

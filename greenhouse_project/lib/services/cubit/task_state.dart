part of 'task_cubit.dart';

@immutable
sealed class TaskState {}

final class TaskInitial extends TaskState {}

final class TaskLoading extends TaskState {}

final class TaskLoaded extends TaskState {
  final List<TaskData> tasks;

  TaskLoaded(
    this.tasks,
  );
}

final class TaskError extends TaskState {
  final String error;

  TaskError(
    this.error,
  );
}

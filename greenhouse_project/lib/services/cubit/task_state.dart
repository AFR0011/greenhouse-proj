part of 'task_cubit.dart';

@immutable
sealed class TaskState {}

final class TaskInitial extends TaskState {}

final class TaskLoading extends TaskState {}

final class TaskLoaded extends TaskState {
  List<TaskData> tasks;

  TaskLoaded({
    required this.tasks,
  });

}
final class TaskError extends TaskState {
  String error;

  TaskError({
    required this.error,
  });

}

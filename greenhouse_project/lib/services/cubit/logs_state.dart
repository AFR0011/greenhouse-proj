part of 'logs_cubit.dart';

@immutable
sealed class LogsState {}

final class LogsInitial extends LogsState {}

final class LogsLoading extends LogsState {}

final class LogsLoaded extends LogsState {
  final List<LogsData> logs;

  LogsLoaded(this.logs);
}

final class LogsError extends LogsState {
  final String error;
  LogsError(this.error);
}
part of 'programs_cubit.dart';

@immutable
sealed class ProgramsState {}

final class ProgramsInitial extends ProgramsState{}

final class ProgramsLoading extends ProgramsState {}

final class ProgramsLoaded extends ProgramsState {
  final List<ProgramData> programs;

  ProgramsLoaded(this.programs);
}

final class ProgramError extends ProgramsState {
  final String error;
  ProgramError(this.error);
}
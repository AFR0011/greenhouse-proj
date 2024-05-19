part of 'management_cubit.dart';

@immutable
sealed class ManagementState {}

final class ManageEmployeesLoading extends ManagementState {}

final class ManageEmployeesLoaded extends ManagementState {
  final List<EmployeeData> employees;

  ManageEmployeesLoaded(this.employees);
}

final class ManageEmployeesError extends ManagementState {
  final String error;

  ManageEmployeesError(this.error);
}

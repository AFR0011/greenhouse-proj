part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthSuccess extends AuthState {
  final UserCredential userCredential; //User auth credentials
  AuthSuccess(this.userCredential);
}

final class AuthFailure extends AuthState {
  final String? error;
  AuthFailure(this.error);
}

final class AuthLoading extends AuthState {}

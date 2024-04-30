part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> userData;

  ProfileLoaded(this.userData);
}

final class ProfileError extends ProfileState {
  final String error;

  ProfileError(this.error);
}

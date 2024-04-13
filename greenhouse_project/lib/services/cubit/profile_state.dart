part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  Map<String, dynamic> userData;

  ProfileLoaded(this.userData);
}

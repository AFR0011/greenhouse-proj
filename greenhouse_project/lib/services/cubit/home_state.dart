part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

class UserState extends HomeState {
  final UserCredential? userCredential;
  UserState(this.userCredential);
}

class NotificationListState extends HomeState {
  final List<String> notifications;

  NotificationListState(this.notifications);
}

class NotificationsLoading extends HomeState {}

class NotificationsLoaded extends HomeState {
  final List<NotificationData> notifications;

  NotificationsLoaded(this.notifications);
}

class NotificationsError extends HomeState {
  final String errorMessage;

  NotificationsError(this.errorMessage);
}

class UserInfoLoading extends HomeState {}

class UserInfoLoaded extends HomeState {
  final String userRole;
  final String userName;
  final DocumentReference userReference;
  final bool enabled;

  UserInfoLoaded(
      this.userRole, this.userName, this.userReference, this.enabled);
}

class UserInfoError extends HomeState {
  final String errorMessage;

  UserInfoError(this.errorMessage);
}

class FooterNavigationState extends HomeState {
  final int selectedIndex;

  FooterNavigationState(this.selectedIndex);
}

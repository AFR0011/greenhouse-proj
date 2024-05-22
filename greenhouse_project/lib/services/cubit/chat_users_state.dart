part of 'chat_users_cubit.dart';

@immutable
sealed class ChatUsersState {}

final class ChatUsersInitial extends ChatUsersState {}

final class ChatUsersLoading extends ChatUsersState {}

final class ChatUsersLoaded extends ChatUsersState {
  final List<UserData> chatUsers;

  ChatUsersLoaded(this.chatUsers);
}

class ChatUsersError extends ChatUsersState {
  final String error;

  ChatUsersError(this.error);
}

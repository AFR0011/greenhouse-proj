part of 'chats_cubit.dart';

@immutable
sealed class ChatsState {}

final class ChatsInitial extends ChatsState {}

final class ChatsLoading extends ChatsState {}

final class ChatsLoaded extends ChatsState {
  final List<ChatsData?> chats;

  ChatsLoaded(this.chats);
}

class ChatsError extends ChatsState {
  final String error;

  ChatsError(this.error);
}

part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

final class ChatLoading extends ChatState {}

final class ChatLoaded extends ChatState {
  final List<MessageData> messages;

  ChatLoaded(this.messages);
}

final class ChatError extends ChatState {
  final String error;

  ChatError(this.error);
  String test = Timestamp.now().toString();
}

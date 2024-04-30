import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');
  final DocumentReference? reference;

  ChatCubit(this.reference) : super(ChatLoading()) {
    _getMessages();
  }
  void _getMessages() {
    //Get user's chats
    messages
        .where('chat', isEqualTo: reference)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      final List<MessageData> messages =
          snapshot.docs.map((doc) => MessageData.fromFirestore(doc)).toList();

      emit(ChatLoaded([...messages]));
    }, onError: (error) {
      emit(ChatError(error.toString()));
    });
  }

  Future<void> sendMessage(String message, DocumentReference receiver,
      DocumentReference sender, DocumentReference chat) async {
    await messages.add({
      "chat": chat,
      "message": message,
      "receiver": receiver,
      "sender": sender,
      "timestamp": Timestamp.now()
    });
    return;
  }
}

class MessageData {
  final String message;
  final DateTime timestamp;
  final DocumentReference receiver;

  MessageData(
      {required this.message, required this.receiver, required this.timestamp});

  factory MessageData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MessageData(
        message: data['message'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        receiver: data['receiver']);
  }
}

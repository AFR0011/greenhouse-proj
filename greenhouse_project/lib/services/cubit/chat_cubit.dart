import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');

  final CollectionReference logs =
      FirebaseFirestore.instance.collection('logs');

  final DocumentReference? reference;
  bool _isActive = true; // Flag to track the status of the ChatCubit

  ChatCubit(this.reference) : super(ChatLoading()) {
    _getMessages();
  }

  void _getMessages() {
    // Get user's chats
    messages
        .where('chat', isEqualTo: reference)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      final List<MessageData> messages =
          snapshot.docs.map((doc) => MessageData.fromFirestore(doc)).toList();

      if (_isActive) {
        emit(ChatLoaded([...messages]));
      }
    }, onError: (error) {
      emit(ChatError(error.toString()));
    });
  }

  Future<void> sendMessage(String message, DocumentReference receiver,
      DocumentReference sender, DocumentReference chat) async {
    if (!_isActive) {
      return; // Do nothing if the ChatCubit is closed
    }

    try {
      DocumentReference externalId = await messages.add({
        "chat": chat,
        "message": message,
        "receiver": receiver,
        "sender": sender,
        "timestamp": Timestamp.now()
      });

      logs.add({
        "action": "create",
        "description": "message sent by user at ${Timestamp.now().toString()}",
        "timestamp": Timestamp.now(),
        "type": "message",
        "userId": reference,
        "externalId": externalId,
      });
    } catch (error) {
      emit(ChatError(
          error.toString())); // Emit an error state if an error occurs
    }
  }

  // Close (cubit destructor)
  @override
  Future<void> close() {
    _isActive = false; // Set the flag to indicate that the ChatCubit is closed
    return super.close();
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

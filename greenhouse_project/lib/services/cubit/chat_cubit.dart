import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

part 'chat_state.dart';

// Cubit for managing chat state and interactions with Firestore.
class ChatCubit extends Cubit<ChatState> {
  // Reference to the 'messages' collection in Firestore.
  final CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');

  // Reference to the 'logs' collection in Firestore.
  final CollectionReference logs =
      FirebaseFirestore.instance.collection('logs');

  // Reference to a chat document in Firestore.
  final DocumentReference? chatReference;
  // Flag to check if the cubit is active.
  bool _isActive = true;

  // Constructor initializing the cubit with a document reference and loading initial state.
  ChatCubit(this.chatReference) : super(ChatLoading()) {
    _getMessages();
  }

  // Private method to listen to message changes in Firestore and update state.
  void _getMessages() {
    if (!_isActive) return;
    messages
        .where('chat', isEqualTo: chatReference)
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

  // Public method to send a message and log the action in Firestore.
  Future<void> sendMessage(String message, DocumentReference receiver,
      DocumentReference sender, DocumentReference chat) async {
    if (!_isActive) return;

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
        "userId": sender,
        "externalId": externalId,
      });
    } catch (error) {
      emit(ChatError(error.toString()));
    }
  }

  // Overridden close method to deactivate the cubit before closing.
  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

// Data model class for message data.
class MessageData {
  final String message;
  final DateTime timestamp;
  final DocumentReference receiver;

  MessageData(
      {required this.message, required this.receiver, required this.timestamp});

  // Factory constructor to create a MessageData instance from a Firestore document.
  factory MessageData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MessageData(
        message: data['message'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        receiver: data['receiver']);
  }
}

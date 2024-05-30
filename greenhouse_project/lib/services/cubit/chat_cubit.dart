import 'dart:convert';
import 'package:http/http.dart' as http;
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
  bool _isProcessing = false;

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
        .listen((snapshot) async {
      final List<MessageData> messages =
          snapshot.docs.map((doc) => MessageData.fromFirestore(doc)).toList();

      if (_isActive && !_isProcessing) emit(ChatLoaded([...messages]));
    }, onError: (error) {
      if (_isActive && !_isProcessing) emit(ChatError(error.toString()));
    });
  }

  // Public method to send a message and log the action in Firestore.
  Future<void> sendMessage(String message, DocumentReference receiver,
      DocumentReference sender, DocumentReference chat) async {
    if (!_isActive) return;
    _isProcessing = true;

    DocumentSnapshot senderSnapshot = await sender.get();
    String name, surname;
    String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
    String stringTime = Timestamp.now().toDate().toString().substring(11, 19);
    name = await senderSnapshot.get("name");
    surname = await senderSnapshot.get("surname");

    try {
      DocumentReference externalId = await messages.add({
        "chat": chat,
        "message": message,
        "receiver": receiver,
        "sender": sender,
        "timestamp": Timestamp.now()
      });

      await logs.add({
        "action": "create",
        "description":
            "message sent by \"$name $surname\" on \"$stringDate\" at $stringTime: $message",
        "timestamp": Timestamp.now(),
        "type": "message",
        "userId": sender,
        "externalId": externalId,
      });
      
      _isProcessing = false;
      _getMessages();
    } catch (error, stack) {
      print(stack);
      print(error);
      emit(ChatError(error.toString()));
    }
  }

  Future<void> sendNotification(
      String userId, String title, String body) async {
    final url = Uri.parse(
        'https://greenhouse-5b1d55d4ffae.herokuapp.com/sendNotification');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'userId': userId,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.statusCode}');
      print('Response body: ${response.body}');
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

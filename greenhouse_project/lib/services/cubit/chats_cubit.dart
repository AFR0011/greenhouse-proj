// ignore: avoid_web_libraries_in_flutte

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenhouse_project/pages/chat.dart';

part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  final CollectionReference chats =
      FirebaseFirestore.instance.collection('chats');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final UserCredential? user;

  bool _isActive = true;
  bool _isProcessing = false;

  ChatsCubit(this.user) : super(ChatsLoading()) {
    if (user != null) {
      _getChats();
    }
  }

  void _getChats() async {
    if (!_isActive) return;
    // Get user reference
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user?.user?.email)
        .get();
    DocumentReference userReference = userQuery.docs.first.reference;

    //Get user's chats
    chats.where('users', arrayContains: userReference).snapshots().listen(
        (snapshot) async {
      final List<Future<ChatsData?>> userChatsFutures = snapshot.docs
          .map((doc) => ChatsData.fromFirestore(doc, userReference))
          .toList();

      final userChats = await Future.wait(userChatsFutures);
      if (_isActive && !_isProcessing) emit(ChatsLoaded([...userChats]));
    }, onError: (error) {
      if (_isActive && !_isProcessing) emit(ChatsError(error.toString()));
    });
  }

  ChatsData? getChatByReference(
      List<ChatsData?> chats, DocumentReference chatReference) {
    if (!_isActive) return null;
    return chats.firstWhere((chat) => chatReference == chat?.reference);
  }

  Future<void> createChat(
      BuildContext context, DocumentReference receiverReference) async {
    try {
      _isProcessing = true;
      //get user ref
      QuerySnapshot userQuery =
          await users.where('email', isEqualTo: user?.user?.email).get();
      DocumentReference userReference = userQuery.docs.first.reference;

      //check if chat a exists already
      QuerySnapshot existChatQuery = await chats
          .where(Filter.or(Filter('users', arrayContains: userReference),
              Filter('users', arrayContains: receiverReference)))
          .get();

      for (var doc in existChatQuery.docs) {
        List<DocumentReference> users = [doc['users'][0], doc['users'][1]];
        if (users.contains(userReference) &&
            users.contains(receiverReference)) {
          // navigate to existing chat
          DocumentReference existChatReference = doc.reference;
          _navigateToChat(context, existChatReference);
          _isProcessing = false;
          return _getChats();
        }
      }

      //create a new chat
      DocumentReference newChatReference = await chats.add({
        'users': [userReference, receiverReference],
        'creationDate': Timestamp.now(),
      });

      //Navigate to new chat
      _navigateToChat(context, newChatReference);
    } catch (error) {
      emit(ChatsError(error.toString()));
    }
    _isProcessing = false;
    _getChats();
  }

  void _navigateToChat(BuildContext context, DocumentReference chatReference) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          userCredential: user!,
          chatReference: chatReference,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

class ChatsData {
  final DateTime creationDate;
  final Map<String, dynamic>? receiverData;
  final Uint8List receiverPicture;
  final DocumentReference reference;

  ChatsData(
      {required this.receiverData,
      required this.receiverPicture,
      required this.creationDate,
      required this.reference});

  static Future<ChatsData?> fromFirestore(
      DocumentSnapshot doc, DocumentReference userReference) async {
    final data = doc.data() as Map<String, dynamic>;

    final List<DocumentReference> users =
        data["users"].cast<DocumentReference>().toList();
        print(users);
    DocumentReference receiverReference =
        users[0] == userReference ? users[1] : users[0];
        print("rceiver reference: $receiverReference");

    // Fetch receiver data asynchronously
    final snapshot = await receiverReference.get();
    final receiverSnapshotData = snapshot.data();
        print("data reference: $receiverSnapshotData\n");
    final receiverData = receiverSnapshotData as Map<String, dynamic>;

    final Uint8List? receiverPicture = await FirebaseStorage.instance
        .refFromURL(receiverData['picture'])
        .getData();

    receiverData['reference'] = receiverReference;

    return ChatsData(
        receiverData: receiverData,
        receiverPicture: receiverPicture!,
        creationDate: (data['creationDate'] as Timestamp).toDate(),
        reference: doc.reference);
  }
}

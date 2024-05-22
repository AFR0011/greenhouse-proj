import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  final CollectionReference chats =
      FirebaseFirestore.instance.collection('chats');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final UserCredential? user;

  bool _isActive = true;

  ChatsCubit(this.user) : super(ChatsLoading()) {
    if (user != null) {
      _subscribeToChats();
    }
  }

  void _subscribeToChats() async {
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
      if (_isActive) emit(ChatsLoaded([...userChats]));
    }, onError: (error) {
      if (_isActive) emit(ChatsError(error.toString()));
    });
  }

  ChatsData? getChatByReference(
      List<ChatsData?> chats, DocumentReference chatReference) {
    if (!_isActive) return null;
    return chats.firstWhere((chat) => chatReference == chat?.reference);
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }

  List<UserData?>? getUsers() {
    if (!_isActive) return null;
    List<UserData?>? usersData;
    //Get all users except current user
    users.where("email", isNotEqualTo: user?.user?.email).snapshots().listen(
        (snapshot) async {
      final List<Future<UserData?>> userDataFutures =
          snapshot.docs.map((doc) => UserData.fromFirestore(doc)).toList();
      usersData = await Future.wait(userDataFutures);
    }, onError: (error) {
      if (_isActive) emit(ChatsError(error.toString()));
    });
    return usersData;
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
    DocumentReference receiverReference =
        users[0] == userReference ? users[1] : users[0];

    // Fetch receiver data asynchronously
    final snapshot = await receiverReference.get();
    final receiverSnapshotData = snapshot.data();
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

class UserData {
  final String email;
  final DateTime creationDate;
  final String name;
  final String surname;
  final bool enabled;
  final DocumentReference reference;
  final Uint8List picture;
  final String role;

  UserData(
      {required this.email,
      required this.creationDate,
      required this.name,
      required this.surname,
      required this.reference,
      required this.enabled,
      required this.picture,
      required this.role});

  static Future<UserData?> fromFirestore(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    final Uint8List? picture =
        await FirebaseStorage.instance.refFromURL(data['picture']).getData();

    return UserData(
        name: data['name'],
        surname: data['surname'],
        email: data['email'],
        creationDate: (data['creationDate'] as Timestamp).toDate(),
        enabled: data['enabled'],
        reference: doc.reference,
        picture: picture!,
        role: data["role"]);
  }
}

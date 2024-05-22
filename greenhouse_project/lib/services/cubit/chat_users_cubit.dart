import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/foundation.dart";

part 'chat_users_state.dart';

class ChatUsersCubit extends Cubit<ChatUsersState> {
  UserCredential user;
  CollectionReference users = FirebaseFirestore.instance.collection("users");

  bool _isActive = true;


  ChatUsersCubit(this.user) : super(ChatUsersInitial()) {
    _getUsers();
  }
    void _getUsers() {
    if (!_isActive) return;
    emit(ChatUsersLoading());
    List<UserData> usersData = [];
    //Get all users except current user
    users.where("email", isNotEqualTo: user.user?.email).snapshots().listen(
        (snapshot) async {
      final List<Future<UserData>> userDataFutures =
          snapshot.docs.map((doc) => UserData.fromFirestore(doc)).toList();
      usersData = await Future.wait(userDataFutures);
      emit(ChatUsersLoaded(usersData));
    }, onError: (error,stack) {
      print(error);
      print(stack);
      if (_isActive) emit(ChatUsersError(error.toString()));
    });
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

  static Future<UserData> fromFirestore(DocumentSnapshot doc) async {
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

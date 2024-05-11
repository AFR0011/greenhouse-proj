import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  Reference storageReference = FirebaseStorage.instance
      .refFromURL("gs://greenhouse-ctrl-system.appspot.com");
  DocumentReference? userReference;

  ProfileCubit(this.userReference) : super(ProfileLoading()) {
    if (userReference != null) {
      _getUserProfile(storageReference);
    }
  }

  void _getUserProfile(Reference storageReference) async {
    try {
      DocumentSnapshot? userSnapshot = 
      await userReference?.get();
      final userSnapshotData = userSnapshot?.data();
      final firestoreData = userSnapshotData as Map<String, dynamic>;
      
      UserData userData = 
      await UserData.fromFirestore(firestoreData, userReference!, storageReference);
      emit(ProfileLoaded(userData));
    } catch (error, stack) {
      emit(ProfileError(stack.toString()));
    }
  }
}

class UserData {
  final DateTime creationDate;
  final String email;
  final String name;
  final String surname;
  final String role;
  final Uint8List? picture;
  final DocumentReference reference;

  UserData({
    required this.creationDate,
    required this.email,
    required this.name,
    required this.surname,
    required this.role,
    required this.picture,
    required this.reference,
  });

  static Future<UserData> fromFirestore (
      Map<String, dynamic> data, DocumentReference userReference, Reference storageReference)async {
         final Uint8List? picture = await storageReference.child(data['picture']).getData();
         
        return UserData(
      creationDate: (data['creationDate'] as Timestamp).toDate(),
      email: data['email'],
      name: data['name'],
      surname: data['surname'],
      role: data['role'],
      picture: picture,
      reference: userReference,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
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
      DocumentSnapshot? userSnapshot = await userReference?.get();
      final userSnapshotData = userSnapshot?.data();
      final firestoreData = userSnapshotData as Map<String, dynamic>;
      // final picture =
      //     await storageReference.child(firestoreData['picture']).getData();
      // firestoreData['picture'] = picture;
      UserData userData = UserData.fromFirestore(firestoreData, userReference!);
      emit(ProfileLoaded(userData));
    } catch (error) {
      emit(ProfileError(error.toString()));
    }
  }
}

class UserData {
  final DateTime creationDate;
  final String email;
  final String name;
  final String surname;
  final String role;
  final Uint8List picture;
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

  factory UserData.fromFirestore(
      Map<String, dynamic> data, DocumentReference userReference) {
    return UserData(
      creationDate: (data['creationDate'] as Timestamp).toDate(),
      email: data['email'],
      name: data['name'],
      surname: data['surname'],
      role: data['role'],
      picture: data['picture'],
      reference: userReference,
    );
  }
}

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

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
  Future selectImage() async {
    final ImagePicker  _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if(_file != null){
      Uint8List img = await _file.readAsBytes();
      print("HI THERE");
      
    // Upload img to Storage storageReference.add)
    UploadTask uploadTask = storageReference.child(Timestamp.now().toString()).putData(img);
    TaskSnapshot snapshot = await uploadTask;
    // Get url of uploaded image
    String imageUrl = await snapshot.ref.getDownloadURL();
    // Set "picture" for current user as url
    try{
      await userReference!.update({
        'picture': imageUrl
      });
      DocumentSnapshot updatedSnapshot = await userReference!.get();
      UserData userdata = await UserData.fromFirestore(
        updatedSnapshot.data() as Map<String, dynamic>,
        userReference!,storageReference);
      emit(ProfileLoaded(userdata));
    } catch (error) {
      emit(ProfileError(error.toString()));
    }
    
    }
    

    print('Image selection Failed'); 
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

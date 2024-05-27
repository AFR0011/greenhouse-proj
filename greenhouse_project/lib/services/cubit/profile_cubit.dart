import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  FirebaseStorage storage = FirebaseStorage.instance;
  DocumentReference userReference;

  bool _isActive = true;
  bool _isProcessing = false;

  ProfileCubit(this.userReference) : super(ProfileLoading()) {
    _getUserProfile(storage);
  }

  void _getUserProfile(FirebaseStorage storage) async {
    if (!_isActive) return;

    try {
      DocumentSnapshot userSnapshot = await userReference.get();
      final userSnapshotData = userSnapshot.data();
      final firestoreData = userSnapshotData as Map<String, dynamic>;

      UserData? userData =
          await UserData.fromFirestore(firestoreData, userReference, storage);
      if (_isActive && !_isProcessing) emit(ProfileLoaded(userData));
    } catch (error) {
      if (_isActive && !_isProcessing) emit(ProfileError(error.toString()));
    }
  }

  Future selectImage() async {
    if (!_isActive) return;
    _isProcessing = true;
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      // Upload img to Storage
      Uint8List img = await file.readAsBytes();
      UploadTask uploadTask =
          storage.ref().child(Timestamp.now().toString()).putData(img);

      // Get url of uploaded image
      String imageUrl = await storage
          .ref()
          .child("Default.jpg")
          .getDownloadURL(); // default if something goes wrong
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Store url in firestore database
      try {
        await userReference.update({'picture': imageUrl});
        DocumentSnapshot updatedSnapshot = await userReference.get();
        UserData userdata = await UserData.fromFirestore(
            updatedSnapshot.data() as Map<String, dynamic>,
            userReference,
            storage);
        emit(ProfileLoaded(userdata));
      } catch (error) {
        emit(ProfileError(error.toString()));
      }
    } else {
      print('Image selection Failed');
    }
    _isProcessing = false;
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

class UserData {
  final DateTime creationDate;
  final String email;
  final String name;
  final String surname;
  final String role;
  final bool enabled;
  final Uint8List picture;
  final DocumentReference reference;

  UserData({
    required this.creationDate,
    required this.email,
    required this.name,
    required this.surname,
    required this.role,
    required this.picture,
    required this.enabled,
    required this.reference,
  });

  static Future<UserData> fromFirestore(Map<String, dynamic> data,
      DocumentReference userReference, FirebaseStorage storage) async {
    final Uint8List? picture =
        await storage.refFromURL(data['picture']).getData();

    return UserData(
      creationDate: (data['creationDate'] as Timestamp).toDate(),
      email: data['email'],
      name: data['name'],
      surname: data['surname'],
      role: data['role'],
      enabled: data["enabled"],
      picture: picture as Uint8List,
      reference: userReference,
    );
  }
}

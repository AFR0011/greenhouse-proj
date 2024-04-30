import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  DocumentReference? userReference;

  ProfileCubit(this.userReference) : super(ProfileLoading()) {
    if (userReference != null) {
      _getUserProfile();
    }
  }

  void _getUserProfile() async {
    try {
      DocumentSnapshot? userSnapshot = await userReference?.get();
      final userSnapshotData = userSnapshot?.data();
      final userData = userSnapshotData as Map<String, dynamic>;
      emit(ProfileLoaded(userData));
    } catch (error) {
      emit(ProfileError(error.toString()));
    }
  }
}

part of 'home_cubit.dart';

class UserInfoCubit extends HomeCubit {
  UserInfoCubit() : super(UserInfoLoading());

  Future<void> getUserInfo(UserCredential userCredential) async {
    try {
      String? email = userCredential.user?.email;
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = userQuery.docs.first;
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        final String userRole = userData?['role'] ?? 'Unknown';
        final String userName = userData?['name'] ?? 'Unknown';
        final DocumentReference userReference = userSnapshot.reference;
        final bool enabled = userData?['enabled'];
        print("USER DATA: ${userData}\n\n");

        emit(UserInfoLoaded(userRole, userName, userReference, enabled));
      } else {
        emit(UserInfoError("User not found"));
      }
    } catch (error) {
      emit(UserInfoError(error.toString()));
    }
  }

  Future<void> setUserInfo(DocumentReference userReference, String name,
      String email, String password) async {
    emit(UserInfoLoading());
    try {
      userReference.update({
        "name": name,
        "email": email,
      });
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      userCredential.user?.updatePassword(password);

      getUserInfo(userCredential);
    } catch (error) {
      print(error.toString());
      emit(UserInfoError(error.toString()));
    }
  }

  void deleteUserAccount(
      UserCredential userCredential, DocumentReference userReference) {
    try {
      userCredential.user?.delete();
      userReference.delete();
    } catch (e) {
      emit(UserInfoError(e.toString()));
    }
  }
}

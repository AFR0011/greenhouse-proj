part of 'home_cubit.dart';

class UserInfoCubit extends HomeCubit {
  bool _isActive = true;

  UserInfoCubit() : super(UserInfoLoading());

  Future<void> getUserInfo(UserCredential userCredential) async {
    if (!_isActive) return;
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
    if (!_isActive) return;
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
      UserCredential userCredential, DocumentReference userReference) async {
    if (!_isActive) return;
    try {
      await userCredential.user?.delete();
      await userReference.delete();
    } catch (e) {
      emit(UserInfoError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

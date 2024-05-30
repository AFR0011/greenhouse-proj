part of 'home_cubit.dart';

class UserInfoCubit extends HomeCubit {
  bool _isActive = true;
  bool _isProcessing = false;

  UserInfoCubit() : super(UserInfoLoading());

  Future<void> getUserInfo(
      UserCredential userCredential, String? fcmToken) async {
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
        if (fcmToken != null) {
          await updateUserFCMToken(userQuery.docs.first.reference, fcmToken);
        }
        if (_isActive && !_isProcessing) {
          emit(UserInfoLoaded(userRole, userName, userReference, enabled));
        }
      } else {
        if (_isActive && !_isProcessing) emit(UserInfoError("User not found"));
      }
    } catch (error) {
      if (_isActive && !_isProcessing) emit(UserInfoError(error.toString()));
    }
  }

  Future<void> setUserInfo(DocumentReference userReference, String name,
      String email, String password, String currentPassword) async {
    if (!_isActive) return;
    _isProcessing = true;
    emit(UserInfoLoading());
    try {
      userReference.update({
        "name": name,
        "email": email,
      });
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: currentPassword);
      userCredential.user?.updatePassword(password);

      getUserInfo(userCredential, null);
    } catch (error) {
      emit(UserInfoError(error.toString()));
    }
    _isProcessing = false;
  }

  void deleteUserAccount(
      UserCredential userCredential, DocumentReference userReference) async {
    if (!_isActive) return;
    _isProcessing = true;
    try {
      await userCredential.user?.delete();
      await userReference.delete();
    } catch (e) {
      emit(UserInfoError(e.toString()));
    }
    _isProcessing = false;
  }

  Future<void> updateUserFCMToken(
      DocumentReference userReference, String fcmToken) async {
    if (!_isActive) return;
    _isProcessing = true;

    try {
      await userReference.update({"fcmToken": fcmToken});
    } catch (error) {
      emit(UserInfoError(error.toString()));
    }
    _isProcessing = false;
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

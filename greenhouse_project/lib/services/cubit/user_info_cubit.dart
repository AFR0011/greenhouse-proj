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

        emit(UserInfoLoaded(userRole, userName, userReference));
      } else {
        emit(UserInfoError("User not found"));
      }
    } catch (error) {
      emit(UserInfoError(error.toString()));
    }
  }
}

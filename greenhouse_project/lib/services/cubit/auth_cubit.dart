import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void authLoginRequest(String email, String password) async {
    emit(AuthLoading());
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return emit(AuthSuccess(userCredential));
    } on FirebaseAuthException catch (e) {
      return emit(AuthFailure(e.message));
    }
  }

  void authLogoutRequest() async {
    try {
      await FirebaseAuth.instance.signOut();
      emit(AuthLoading());
      return emit(AuthInitial());
    } catch (e) {
      return emit(AuthFailure("Logout Failed"));
    }
  }
}

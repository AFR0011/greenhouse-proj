import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  bool _isActive = true;

  AuthCubit() : super(AuthInitial());

  void authLoginRequest(String email, String password) async {
    if (!_isActive) return;
    emit(AuthLoading());
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(AuthSuccess(userCredential));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message));
    }
  }

  Future<void> authLogoutRequest() async {
    if (!_isActive) return;
    try {
      emit(AuthLoading());
      await FirebaseAuth.instance.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure("Logout Failed"));
    }
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

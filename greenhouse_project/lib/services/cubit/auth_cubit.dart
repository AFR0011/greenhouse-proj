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
      return emit(AuthSuccess(userCredential));
    } on FirebaseAuthException catch (e) {
      return emit(AuthFailure(e.message));
    }
  }

  Future<void> authLogoutRequest() async {
    if (!_isActive) return;
    try {
      emit(AuthLoading());
      await FirebaseAuth.instance.signOut();
      return emit(AuthInitial());
    } catch (e) {
      return emit(AuthFailure("Logout Failed"));
    }
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

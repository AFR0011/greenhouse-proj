import "dart:convert";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:shared_preferences/shared_preferences.dart";
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  bool _isActive = true;
  final _prefs = SharedPreferences.getInstance();

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
      await _prefs.then((prefs) {
        prefs.setBool('isLoggedIn', true);
        prefs.setString(
            'userCredentials', jsonEncode(userCredential.toString()));
      });
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
      await _prefs.then((prefs) {
        prefs.setBool('isLoggedIn', false);
        prefs.setString('userCredentials', "");
      });
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

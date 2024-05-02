import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/foundation.dart";

part 'profile_edit_state.dart';

class ProfileEditCubit extends Cubit<List<bool>> {
  ProfileEditCubit() : super([true, true, true]);

  bool updateState(List<bool> validation) {
    emit([...validation]);
    if (validation.contains(false)) {
      return false;
    } else {
      return true;
    }
  }
}

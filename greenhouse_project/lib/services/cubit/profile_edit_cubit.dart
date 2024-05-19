import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/foundation.dart";

part 'profile_edit_state.dart';

class ProfileEditCubit extends Cubit<List<bool>> {
  bool _isActive = true;

  ProfileEditCubit() : super([true, true, true]);

  bool updateState(List<bool> validation) {
    if (!_isActive) return false;
    emit([...validation]);
    if (validation.contains(false)) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

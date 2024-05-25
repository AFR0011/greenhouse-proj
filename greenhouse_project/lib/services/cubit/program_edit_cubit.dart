import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

part 'program_edit_state.dart';

class ProgramEditCubit extends Cubit<List<dynamic>> {
  bool _isActive = true;
  ProgramEditCubit() : super(["", "", 0, "", "", ""]);

  List<bool> checkValidationAndUpdate(List<dynamic> values) {
    if (!_isActive) return [false, false, false, false, false, false];
    List<bool> validation = [true, true, true, true, true, true];
    if (values[0].isEmpty) {
      validation[0] = false;
    }
    if (values[1].isEmpty) {
      validation[1] = false;
    }
    if (values[2] < 0 || values[2] > 100) {
      validation[2] = false;
    }
    if (values[3] == null) {
      validation[3] = false;
    }
    if (values[4] == null) {
      validation[4] = false;
    }
    if (values[5] == null) {
      validation[5] = false;
    }
    print(validation);
    emit([...values]);
    return validation;
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

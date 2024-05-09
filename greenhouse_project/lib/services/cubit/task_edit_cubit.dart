import "package:flutter_bloc/flutter_bloc.dart";
// import "package:flutter/foundation.dart";
// part "task_edit_state.dart";

class TaskEditCubit extends Cubit<List<dynamic>> {
  TaskEditCubit() : super([true, true, true, null]);

  bool updateState(List<dynamic> validation) {
    emit([...validation]);
    if (validation.contains(false) || validation.contains(null)) {
      return false;
    } else {
      return true;
    }
  }
}

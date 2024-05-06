import "package:flutter_bloc/flutter_bloc.dart";

class TaskEditCubit extends Cubit<List<bool>> {
  TaskEditCubit() : super([true, true, true, true]);

  bool updateState(List<bool> validation) {
    emit([...validation]);
    if (validation.contains(false)) {
      return false;
    } else {
      return true;
    }
  }
}

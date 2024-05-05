import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'task_edit_state.dart';

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

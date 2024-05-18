import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
// import "package:flutter/foundation.dart";
// part "task_edit_state.dart";

class TaskEditCubit extends Cubit<List<dynamic>> {
  TaskEditCubit() : super([true, true, DateTime.now(), null]);

  bool updateState(List<dynamic> validation) {
    emit([...validation]);
    if (validation.contains(false) || validation.contains(null)) {
      return false;
    } else {
      return true;
    }
  }

}

class TaskDropdownCubit extends Cubit<DocumentReference?> {
  final BuildContext context;
  TaskDropdownCubit(this.context) : super(null);

  void updateDropdown(DocumentReference value) {
    emit(value);
    List<dynamic> validation = context.read<TaskEditCubit>().state;
    validation[3] = value;
    context.read<TaskEditCubit>().updateState(validation);
  }

}

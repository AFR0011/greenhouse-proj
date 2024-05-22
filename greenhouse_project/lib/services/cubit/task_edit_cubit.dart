import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class TaskEditCubit extends Cubit<List<dynamic>> {
  bool _isActive = true;

  TaskEditCubit() : super([true, true, DateTime.now(), null]);

  bool updateState(List<dynamic> validation) {
    if (!_isActive) return false;
    emit([...validation]);
    if (validation.contains(false) || validation.contains(null)) {
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

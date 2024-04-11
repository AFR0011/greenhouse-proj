import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/foundation.dart";

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final CollectionReference tasks =
      FirebaseFirestore.instance.collection('tasks');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final UserCredential? user;

  TasksCubit(this.user) : super(TasksLoading()) {
    if (user != null) {
      _subscribeToTasks();
    }
  }

  void _subscribeToTasks() {
    emit(TasksLoading());

    // Get tasks from the database

    // emit(TasksLoaded(tasks));
  }
}

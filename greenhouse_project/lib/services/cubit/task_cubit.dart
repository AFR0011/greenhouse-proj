/// TODO:
/// - Check _getTasks();
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final CollectionReference tasks =
      FirebaseFirestore.instance.collection('tasks');

  final CollectionReference logs =
      FirebaseFirestore.instance.collection('logs');

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final DocumentReference userReference;

  bool _isActive = true;

  TaskCubit(this.userReference) : super(TaskLoading()) {
    _getTasks();
  }

  void _getTasks() async {
    if (!_isActive) return;
    DocumentSnapshot userSnapshot = await userReference.get();
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    String userRole = userData['role'];

    //Get user Tasks
    if (userRole == "manager" || userRole == "admin") {
      tasks
          .where('manager', isEqualTo: userReference)
          .orderBy('dueDate', descending: true)
          .snapshots()
          .listen((snapshot) {
        final List<TaskData> tasks =
            snapshot.docs.map((doc) => TaskData.fromFirestore(doc)).toList();
        emit(TaskLoaded([...tasks]));
      }, onError: (error) {
        emit(TaskError(error.toString()));
      });
    } else if (userRole == "worker") {
      tasks
          .where('worker', isEqualTo: userReference)
          .orderBy('dueDate', descending: true)
          .snapshots()
          .listen((snapshot) {
        final List<TaskData> tasks =
            snapshot.docs.map((doc) => TaskData.fromFirestore(doc)).toList();
        emit(TaskLoaded([...tasks]));
      }, onError: (error) {
        emit(TaskError(error.toString()));
      });
    }
  }

  void completeTask(DocumentReference taskReference) async {
    if (!_isActive) return;
    taskReference.update({'status': 'waiting'});
  }

  void addTask(String title, String desc, DateTime dueDate,
      DocumentReference worker) async {
    if (!_isActive) return;
    try {
      DocumentReference externalId = await tasks.add({
        "title": title,
        "description": desc,
        "status": 'incomplete',
        "dueDate":
            Timestamp((dueDate.millisecondsSinceEpoch / 1000).round(), 0),
        "manager": userReference,
        "worker": worker
      });

      logs.add({
        "action": "create",
        "description": "Task added by user at ${Timestamp.now().toString()}",
        "timestamp": Timestamp.now(),
        "type": "task",
        "userId": userReference,
        "externalId": externalId,
      });
    } catch (error) {
      emit(TaskError(error.toString()));
    }
  }

  void removeTask(
      DocumentReference item, DocumentReference userReference) async {
    if (!_isActive) return;
    emit(TaskLoading());
    try {
      DocumentSnapshot snapshot = await item.get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      await item.delete();
      await logs.add({
        "action": "Delete",
        "description":
            "Task deleted by user at ${Timestamp.now().toString()} Task details: ${data["title"]}",
        "timestamp": Timestamp.now(),
        "type": "task",
        "userId": userReference,
        "externalId": item,
      });
    } catch (error, stack) {
      emit(TaskError(stack.toString()));
    }
  }

  Future<void> updateTask(DocumentReference item, Map<String, dynamic> data,
      DocumentReference userReference) async {
    if (!_isActive) return;
    emit(TaskLoading());
    try {
      await item.update(data);
      _getTasks();
      logs.add({
        "action": "Update",
        "description": "Task updated by user at ${Timestamp.now().toString()}",
        "timestamp": Timestamp.now(),
        "type": "Task",
        "userId": userReference,
        "externalId": item,
      });
    } catch (error) {
      emit(TaskError(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

class TaskData {
  final String description;
  final String status;
  final String title;
  final DateTime dueDate;
  final DocumentReference manager;
  final DocumentReference taskReference;

  TaskData(
      {required this.description,
      required this.status,
      required this.title,
      required this.dueDate,
      required this.manager,
      required this.taskReference});

  factory TaskData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskData(
      description: data['description'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'],
      title: data['title'],
      manager: data['manager'],
      taskReference: doc.reference,
    );
  }
}

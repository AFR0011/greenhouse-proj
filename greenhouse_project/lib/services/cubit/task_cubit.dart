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
  bool _isProcessing = false;

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
        if (_isActive && !_isProcessing) emit(TaskLoaded([...tasks]));
      }, onError: (error) {
        if (_isActive && !_isProcessing) emit(TaskError(error.toString()));
      });
    } else if (userRole == "worker") {
      tasks
          .where('worker', isEqualTo: userReference)
          .orderBy('dueDate', descending: true)
          .snapshots()
          .listen((snapshot) {
        final List<TaskData> tasks =
            snapshot.docs.map((doc) => TaskData.fromFirestore(doc)).toList();
        if (_isActive && !_isProcessing) emit(TaskLoaded([...tasks]));
      }, onError: (error) {
        if (_isActive && !_isProcessing) emit(TaskError(error.toString()));
      });
    }
  }

  void completeTask(DocumentReference taskReference) async {
    _isProcessing = true;
    if (!_isActive) return;
    DocumentSnapshot taskSnapshot = await taskReference.get();
    String status = taskSnapshot.get("status");
    if (status == "waiting") {
      taskReference.update({'status': 'completed'});
    } else {
      taskReference.update({'status': 'waiting'});
    }
    _isProcessing = false;
    _getTasks();
  }

  void addTask(String title, String desc, DateTime dueDate,
      DocumentReference worker) async {
    if (!_isActive) return;
    _isProcessing = true;
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

      DocumentSnapshot userSnapshot = await userReference.get();
      String name = userSnapshot.get("name");
      String surname = userSnapshot.get("surname");
      String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
      String stringTime = Timestamp.now().toDate().toString().substring(11, 19);

      await logs.add({
        "action": "create",
        "description":
            "task \"$title\" added by \"$name $surname\" on $stringDate at $stringTime",
        "timestamp": Timestamp.now(),
        "type": "Program",
        "userId": userReference,
        "externalId": externalId,
      });
    } catch (error) {
      emit(TaskError(error.toString()));
    }
    _isProcessing = false;
    _getTasks();
  }

  void removeTask(
      DocumentReference item, DocumentReference userReference) async {
    if (!_isActive) return;
    _isProcessing = true;
    emit(TaskLoading());
    try {
      DocumentReference externalId = item;

      DocumentSnapshot snapshot = await item.get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      await item.delete();

      DocumentSnapshot userSnapshot = await userReference.get();
      String name = userSnapshot.get("name");
      String surname = userSnapshot.get("surname");
      String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
      String stringTime = Timestamp.now().toDate().toString().substring(11, 19);
      String title = data["title"];

      await logs.add({
        "action": "delete",
        "description":
            "task \"$title\" deleted by \"$name $surname\" on $stringDate at $stringTime",
        "timestamp": Timestamp.now(),
        "type": "Program",
        "userId": userReference,
        "externalId": externalId,
      });
    } catch (error, stack) {
      emit(TaskError(stack.toString()));
    }
    _isProcessing = false;
    _getTasks();
  }

  Future<void> updateTask(DocumentReference item, Map<String, dynamic> data,
      DocumentReference userReference) async {
    if (!_isActive) return;
    _isProcessing = true;
    emit(TaskLoading());
    try {
      DocumentReference externalId = item;

      await item.update(data);

      DocumentSnapshot userSnapshot = await userReference.get();
      String name = userSnapshot.get("name");
      String surname = userSnapshot.get("surname");
      String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
      String stringTime = Timestamp.now().toDate().toString().substring(11, 19);
      String title = data["title"];

      await logs.add({
        "action": "create",
        "description":
            "task \"$title\" added by \"$name $surname\" on $stringDate at $stringTime",
        "timestamp": Timestamp.now(),
        "type": "Program",
        "userId": userReference,
        "externalId": externalId,
      });
    } catch (error) {
      emit(TaskError(error.toString()));
    }
    _isProcessing = false;
    _getTasks();
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

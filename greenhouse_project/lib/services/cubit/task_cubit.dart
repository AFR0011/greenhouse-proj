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

  TaskCubit(this.userReference) : super(TaskLoading()) {
    _getTasks();
  }

  void _getTasks() async {
    DocumentSnapshot userSnapshot = await userReference.get();
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

    //Get user Tasks
    tasks
        .where(userData['role'], isEqualTo: userReference)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      final List<TaskData> tasks =
          snapshot.docs.map((doc) => TaskData.fromFirestore(doc)).toList();
      emit(TaskLoaded(tasks: [...tasks]));
    }, onError: (error) {
      emit(TaskError(error: error.toString()));
    });
  }

  void completeTask(DocumentReference taskReference) async {
    taskReference.set(
        [
          {'status': 'waiting'}
        ] as Map<String, dynamic>,
        SetOptions(merge: true));
  }

  void addTask(title, desc, worker, dueDate) async{
    try{
      DocumentReference externalId = await tasks.add({
        "title" : title,
        "description" : desc,
        "status" : 'incomplete',
        "dueDate" : dueDate,
        "manager" : userReference,
        "worker" : worker
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
      emit(TaskError(error: error.toString()));
    }
  }
}

class TaskData {
  final String description;
  final String status;
  final String title;
  final DateTime dueDate;
  final DocumentReference taskReference;

  TaskData(
      {required this.description,
      required this.status,
      required this.title,
      required this.dueDate,
      required this.taskReference});

  factory TaskData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskData(
      description: data['description'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'],
      title: data['title'],
      taskReference: doc.reference,
    );
  }
}

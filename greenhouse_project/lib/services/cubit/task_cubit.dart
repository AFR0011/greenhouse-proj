import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {

      final CollectionReference tasks =
      FirebaseFirestore.instance.collection('tasks');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final UserCredential? user;

  TaskCubit(this.user) : super(TaskLoading()) {
    if (user != null) {
      _subscribeToTasks();
    }
  }

  void _subscribeToTasks() async {
     QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user?.user?.email)
        .get();
    DocumentReference userReference = userQuery.docs.first.reference;

    //Get user Tasks
    tasks
        .where('worker', isEqualTo: userReference)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      final List<TaskData> tasks = snapshot.docs
          .map((doc) => TaskData.fromFirestore(doc))
          .toList();
      emit(TaskLoaded(tasks: [...tasks]));
    }, onError: (error) {
      emit(TaskError(error: error.toString()));});
  }

  
  }
  class TaskData{
      final String description;
      final String status;
      final String title; 
      final DateTime dueDate;

        TaskData({
    required this.description,
    required this.status,
    required this.title,
    required this.dueDate,
  });

   factory TaskData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskData(
      description: data['description'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'],
      title: data['title'],
    );
  }
    }

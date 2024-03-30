import 'package:cloud_firestore/cloud_firestore.dart';

class TasksService {
  //get collection of tasks
  final CollectionReference tasks =
      FirebaseFirestore.instance.collection('tasks');

  // // CREATE
  // Future<void> addNotification(String message, DocumentReference user) {
  //   return notes.add({
  //     'note': note,
  //     'timestamp': Timestamp.now(),
  //   });
  // }

  // READ
  Stream<QuerySnapshot> getTasksStream(DocumentReference? userRef) {
    final tasksStream = tasks
        .where('worker', isEqualTo: userRef)
        .orderBy("status", descending: true)
        .snapshots();

    return tasksStream;
  }

  // // UPDATE
  // Future<void> updateNotification(String docID, String newNote) {
  //   return notes.doc(docID).update({
  //     'note': newNote,
  //     'timestamp': Timestamp.now(),
  //   });
  // }

  // // DELETE
  // Future<void> deleteNotification(String docID) {
  //   return notes.doc(docID).delete();
  // }
}

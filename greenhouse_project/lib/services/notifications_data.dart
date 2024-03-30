import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsService {
  //get collection of notifications
  final CollectionReference notifications =
      FirebaseFirestore.instance.collection('notifications');

  // // CREATE
  // Future<void> addNotification(String message, DocumentReference user) {
  //   return notes.add({
  //     'note': note,
  //     'timestamp': Timestamp.now(),
  //   });
  // }

  // READ
  Stream<QuerySnapshot> getNotificationsStream(DocumentReference? userRef) {
    final notificationsStream = notifications
        .where('user', isEqualTo: userRef)
        .orderBy("timestamp", descending: true)
        .snapshots();

    return notificationsStream;
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

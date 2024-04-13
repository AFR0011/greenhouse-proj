part of 'management_cubit.dart';

class ManageTasksCubit extends ManagementCubit {
  final CollectionReference tasks =
      FirebaseFirestore.instance.collection('tasks');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final UserCredential? user;

  ManageTasksCubit(this.user) : super(ManageTasksLoading()) {
    if (user != null) {
      _fetchTasks();
    }
  }

  _fetchTasks() async {
    // Get user reference
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user?.user?.email)
        .get();
    DocumentReference userReference = userQuery.docs.first.reference;

    tasks
        .where("manager", isEqualTo: userReference)
        .snapshots()
        .listen((snapshot) {
      final List<TaskData> tasks =
          snapshot.docs.map((doc) => TaskData.fromFirestore(doc)).toList();

      emit(ManageTasksLoaded([...tasks]));
    });
  }
}

class TaskData {
  final String description;
  final DateTime dueDate;
  final String status;
  final String title;
  final DocumentReference worker;

  TaskData({
    required this.description,
    required this.dueDate,
    required this.status,
    required this.title,
    required this.worker,
  });

  factory TaskData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskData(
      description: data['description'],
      worker: data['worker'],
      status: data['status'],
      title: data['title'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
    );
  }
}

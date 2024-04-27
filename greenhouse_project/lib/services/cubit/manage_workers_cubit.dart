part of 'management_cubit.dart';

class ManageWorkersCubit extends ManagementCubit {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final UserCredential? user;

  ManageWorkersCubit(this.user) : super(ManageWorkersLoading()) {
    if (user != null) {
      _fetchWorkers();
    }
  }

  _fetchWorkers() {
    users.where("role", isEqualTo: "worker").snapshots().listen((snapshot) {
      final List<WorkerData> workers =
          snapshot.docs.map((doc) => WorkerData.fromFirestore(doc)).toList();

      emit(ManageWorkersLoaded([...workers]));
    }, onError: (error) {
      emit(ManageWorkersError(error));
    });
  }
}

class WorkerData {
  final String email;
  final DateTime creationDate;
  final String name;
  final String surname;
  final DocumentReference reference;

  WorkerData(
      {required this.email,
      required this.creationDate,
      required this.name,
      required this.surname,
      required this.reference});

  factory WorkerData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkerData(
        name: data['name'],
        surname: data['surname'],
        email: data['email'],
        creationDate: (data['creationDate'] as Timestamp).toDate(),
        reference: doc.reference);
  }
}

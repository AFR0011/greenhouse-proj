part of 'management_cubit.dart';

class ManageEmployeesCubit extends ManagementCubit {
  // final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference logs =
      FirebaseFirestore.instance.collection('logs');
  final UserCredential? user;

  bool _isActive = true;
  bool _isProcessing = false;

  ManageEmployeesCubit(this.user) : super(ManageEmployeesLoading()) {
    if (user != null) {
      _getEmployees();
    }
  }

  void _getEmployees() {
    if (!_isActive) return;
    List<EmployeeData> employees;
    users.snapshots().listen((snapshot) {
      employees =
          snapshot.docs.map((doc) => EmployeeData.fromFirestore(doc)).toList();

      if (_isActive && !_isProcessing)
        emit(ManageEmployeesLoaded([...employees]));
    }, onError: (error) {
      if (_isActive && !_isProcessing) emit(ManageEmployeesError(error));
    });
  }

  // Employee provisioning is intentionally unavailable in this archived case
  // study. The removed implementation created a password in the client and sent
  // it through a client-side email provider. A live successor must use a trusted
  // backend and a password-reset or invitation flow instead.
  Future<void> createEmployee(
      String email, String role, DocumentReference userReference) async {
    if (!_isActive) return;
    emit(ManageEmployeesError(
        "Employee provisioning is disabled in this archived case study."));
  }

  Future<void> disableEmployee(
      EmployeeData workerData, DocumentReference userReference) async {
    if (!_isActive) return;
    _isProcessing = true;
    emit(ManageEmployeesLoading());
    try {
      await workerData.reference.update({"enabled": false});
      DocumentReference externalId = workerData.reference;

      DocumentSnapshot userSnapshot = await userReference.get();
      String name = userSnapshot.get("name");
      String surname = userSnapshot.get("surname");
      String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
      String stringTime = Timestamp.now().toDate().toString().substring(11, 19);
      String role = workerData.role;

      await logs.add({
        "action": "create",
        "description":
            "$role account disabled by \"$name $surname\" on $stringDate at $stringTime",
        "timestamp": Timestamp.now(),
        "type": "message",
        "userId": userReference,
        "externalId": externalId,
      });
    } catch (error) {
      emit(ManageEmployeesError(error.toString()));
    }
    _isProcessing = false;
    _getEmployees();
  }

  Future<void> enableEmployee(
      EmployeeData workerData, DocumentReference userReference) async {
    if (!_isActive) return;
    _isProcessing = true;
    emit(ManageEmployeesLoading());
    try {
      await workerData.reference.update({"enabled": true});
      DocumentReference externalId = workerData.reference;

      DocumentSnapshot userSnapshot = await userReference.get();
      String name = userSnapshot.get("name");
      String surname = userSnapshot.get("surname");
      String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
      String stringTime = Timestamp.now().toDate().toString().substring(11, 19);
      String role = workerData.role;

      await logs.add({
        "action": "create",
        "description":
            "$role account enabled by \"$name $surname\" on $stringDate at $stringTime",
        "timestamp": Timestamp.now(),
        "type": "message",
        "userId": userReference,
        "externalId": externalId,
      });
    } catch (error) {
      emit(ManageEmployeesError(error.toString()));
    }
    _isProcessing = false;
    _getEmployees();
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

class EmployeeData {
  final String email;
  final DateTime creationDate;
  final String name;
  final String surname;
  final bool enabled;
  final DocumentReference reference;
  final String role;

  EmployeeData(
      {required this.email,
      required this.creationDate,
      required this.name,
      required this.surname,
      required this.reference,
      required this.enabled,
      required this.role});

  factory EmployeeData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmployeeData(
        name: data['name'],
        surname: data['surname'],
        email: data['email'],
        creationDate: (data['creationDate'] as Timestamp).toDate(),
        enabled: data['enabled'],
        reference: doc.reference,
        role: data["role"]);
  }
}

part of 'management_cubit.dart';

class ManageEmployeesCubit extends ManagementCubit {
  static const String _chars =
      "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890=+-_~!@#%^&*()[]|{}?><";
  final _rnd = Random.secure();

  String getRandomPassword(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  // final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference logs =
      FirebaseFirestore.instance.collection('logs');
  final UserCredential? user;
  final FirebaseStorage storage = FirebaseStorage.instance;

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
    users.where("role", isEqualTo: "worker").snapshots().listen((snapshot) {
      employees =
          snapshot.docs.map((doc) => EmployeeData.fromFirestore(doc)).toList();

      if (_isActive && !_isProcessing)
        emit(ManageEmployeesLoaded([...employees]));
    }, onError: (error) {
      if (_isActive && !_isProcessing) emit(ManageEmployeesError(error));
    });
  }

  // Create worker account and send credentials via email
  Future<void> createEmployee(
      String email, String role, DocumentReference userReference) async {
    if (!_isActive) return;
    _isProcessing = true;
    emit(ManageEmployeesLoading());

    // Get url of uploaded image
    String imageUrl = await storage.ref().child("Default.jpg").getDownloadURL();
    try {
      String password = getRandomPassword(16);
      // Create user profile
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user document in Firestore
      DocumentReference externalId = await users.add({
        "creationDate": Timestamp.now(),
        "email": email,
        "name": email,
        "surname": email,
        "role": role,
        "picture": imageUrl,
        "enabled": true,
      });

      DocumentSnapshot userSnapshot = await userReference.get();
      String name = userSnapshot.get("name");
      String surname = userSnapshot.get("surname");
      String stringDate = Timestamp.now().toDate().toString().substring(0, 10);
      String stringTime = Timestamp.now().toDate().toString().substring(11, 19);

      await logs.add({
        "action": "create",
        "description":
            "$role account created by \"$name $surname\" on $stringDate at $stringTime",
        "timestamp": Timestamp.now(),
        "type": "message",
        "userId": userReference,
        "externalId": externalId,
      });

      // Use EmailJS to send email
      String emailMessage =
          '''Your email  used to create an account in the Greenhouse Control
          System environment.\n\nIf you think this is a mistake, please ignore
          this email.\n\nYou can login to your account using the following
          password: $password''';

      EmailJS.init(const Options(
          publicKey: "Dzqja-Lc3erScWnmb", privateKey: "6--KQwTNaq-EKoZJg4-t6"));

      EmailJS.send("service_1i330zn", "template_zx9tnxd",
          {"receiver": email, "message": emailMessage});
    } catch (error) {
      emit(ManageEmployeesError(error.toString()));
    }
    _isProcessing = false;
    _getEmployees();
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

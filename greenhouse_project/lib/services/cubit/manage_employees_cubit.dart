/// TODO:
/// - Add default pfp storage reference to create_worker
/// - Create remote config and a new email for mailer setup

part of 'management_cubit.dart';

class ManageEmployeesCubit extends ManagementCubit {
  // final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference logs =
      FirebaseFirestore.instance.collection('logs');

  final UserCredential? user;

  final FirebaseStorage storage = FirebaseStorage.instance;
  bool _isActive = true;

  ManageEmployeesCubit(this.user) : super(ManageEmployeesLoading()) {
    if (user != null) {
      fetchEmployees();
    }
  }

  List<EmployeeData>? fetchEmployees() {
    if (!_isActive) return null;
    List<EmployeeData>? employees;
    users
        .where(Filter.or(Filter("role", isEqualTo: "worker"),
            Filter("role", isEqualTo: "manager")))
        .snapshots()
        .listen((snapshot) {
      employees =
          snapshot.docs.map((doc) => EmployeeData.fromFirestore(doc)).toList();

      emit(ManageEmployeesLoaded([...employees!]));
    }, onError: (error) {
      emit(ManageEmployeesError(error));
    });
    return employees;
  }

  // Create worker account and send credentials via email
  Future<void> createEmployee(
      String email, String role, DocumentReference userReference) async {
    if (!_isActive) return;
    // Get url of uploaded image
    String imageUrl = await storage.ref().child("Default.jpg").getDownloadURL();
    try {
      // Create user profile
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: '12345678');

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

      logs.add({
        "action": "create",
        "description": "message sent by user at ${Timestamp.now().toString()}",
        "timestamp": Timestamp.now(),
        "type": "message",
        "userId": userReference,
        "externalId": externalId,
      });

      // Use EmailJS to send email
      String _emailMessage = "Your email  used to create an account in " +
          "the Greenhouse Control System environment.\n\nIf you think this is a " +
          "mistake, please ignore this email.\n\nYou can login to your account " +
          "using the following password: 12345678";

      EmailJS.init(const Options(
          publicKey: "Dzqja-Lc3erScWnmb", privateKey: "6--KQwTNaq-EKoZJg4-t6"));

      EmailJS.send("service_1i330zn", "template_zx9tnxd",
          {"receiver": email, "message": _emailMessage});
    } catch (error) {
      print(error);
      emit(ManageEmployeesError(error.toString()));
    }
  }

  Future<void> disableEmployee(EmployeeData workerData) async {
    if (!_isActive) return;
    try {
      await workerData.reference
          .set({"enabled": false}, SetOptions(merge: true));
    } catch (error) {
      emit(ManageEmployeesError(error.toString()));
    }
    return;
  }

  Future<void> enableEmployee(EmployeeData workerData) async {
    if (!_isActive) return;

    try {
      await workerData.reference
          .set({"enabled": true}, SetOptions(merge: true));
    } catch (error) {
      emit(ManageEmployeesError(error.toString()));
    }
    return;
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

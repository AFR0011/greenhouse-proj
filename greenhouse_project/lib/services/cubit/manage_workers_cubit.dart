/// TODO:
/// - Add default pfp storage reference to create_worker
/// - Create remote config and a new email for mailer setup

part of 'management_cubit.dart';

class ManageWorkersCubit extends ManagementCubit {
  // final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference logs =
      FirebaseFirestore.instance.collection('logs');

  final UserCredential? user;
  final String mailerUsername = 'itec229.gr1.21008639@gmail.com';
  final String mailerPassword = 'pnvt twlg mrru dmus';

  bool _isActive = true;

  ManageWorkersCubit(this.user) : super(ManageWorkersLoading()) {
    if (user != null) {
      _fetchWorkers();
    }
  }

  _fetchWorkers() {
    if (!_isActive) return;
    users.where("role", isEqualTo: "worker").snapshots().listen((snapshot) {
      final List<WorkerData> workers =
          snapshot.docs.map((doc) => WorkerData.fromFirestore(doc)).toList();

      emit(ManageWorkersLoaded([...workers]));
    }, onError: (error) {
      emit(ManageWorkersError(error));
    });
  }

  // Create worker account and send credentials via email
  Future<void> createWorker(
      String email, String role, DocumentReference userReference) async {
    if (!_isActive) return;
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
        "picture": <Uint8List>[],
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

      // Mail transfer server
      final smtpServer = gmail(mailerUsername, mailerPassword);

      // Create our message.
      final message = Message()
            ..from = const Address(
                'itec229.gr1.21008639@gmail.com', 'Greenhouse Co.')
            ..recipients.add(email)
            // ..ccRecipients.addAll(['abc@gmail.com', 'xyz@gmail.com']) // For Adding Multiple Recipients
            // ..bccRecipients.add(Address('a@gmail.com')) For Binding Carbon Copy of Sent Email
            ..subject = 'Greenhouse Account Created'
            ..text =
                "Oh well hello there!\n Your email was used by a manager to create an account in the greenhouse control system. You can now login using your email and the following password:\n 12345678\n Please make sure to change this password as soon as possible!"
          // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>"; // For Adding Html in email
          // ..attachments = [
          //   FileAttachment(File('image.png'))  //For Adding Attachments
          //     ..location = Location.inline
          //     ..cid = '<myimg@3.141>'
          // ]
          ;
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      print(e.toString());
    } catch (error) {
      print(error);
      emit(ManageWorkersError(error.toString()));
    }
  }

  Future<void> disableWorker(WorkerData workerData) async {
    if (!_isActive) return;
    try {
      await workerData.reference
          .set({"enabled": false}, SetOptions(merge: true));
    } catch (error) {
      emit(ManageWorkersError(error.toString()));
    }
    return;
  }

  Future<void> enableWorker(WorkerData workerData) async {
    if (!_isActive) return;

    try {
      await workerData.reference
          .set({"enabled": true}, SetOptions(merge: true));
    } catch (error) {
      emit(ManageWorkersError(error.toString()));
    }
    return;
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

class WorkerData {
  final String email;
  final DateTime creationDate;
  final String name;
  final String surname;
  final bool enabled;
  final DocumentReference reference;
  final String role;

  WorkerData(
      {required this.email,
      required this.creationDate,
      required this.name,
      required this.surname,
      required this.reference,
      required this.enabled,
      required this.role});

  factory WorkerData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkerData(
        name: data['name'],
        surname: data['surname'],
        email: data['email'],
        creationDate: (data['creationDate'] as Timestamp).toDate(),
        enabled: data['enabled'],
        reference: doc.reference,
        role: data["role"]);
  }
}

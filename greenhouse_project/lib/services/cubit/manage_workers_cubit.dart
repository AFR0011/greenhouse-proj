part of 'management_cubit.dart';

class ManageWorkersCubit extends ManagementCubit {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final UserCredential? user;
  final String mailerUsername = 'itec229.gr1.21008639@gmail.com'; //Your Email
  final String mailerPassword =
      'pnvt twlg mrru dmus'; // 16 Digits App Password Generated From Google Account
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

  // Create worker account and send credentials via email
  Future<void> createWorker(String email) async {
    try {
      // Create user profile
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: '12345678');

      // Create user document in Firestore
      await users.add({
        "creationDate": Timestamp.now(),
        "email": email,
        "name": email,
        "surname": email,
        "role": "worker"
      });

      // Mail transfer server
      final smtpServer = gmail(mailerUsername, mailerPassword);

      // Create our message.
      final message = Message()
            ..from = const Address('itec229.gr1.21008639@gmail.com', 'Greenhouse Co.')
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
      try {
        final sendReport = await send(message, smtpServer);
        print('Message sent: ' + sendReport.toString());
      } on MailerException catch (e) {
        print('Message not sent.');
        print(e.toString());
      }
    } catch (error) {
      emit(ManageWorkersError(error.toString()));
    }
  }

  // Future<void> deleteWorker(WorkerData workerData) async {
  //   try {
  //     // Get user email
  //     await FirebaseAuth.instance.currentUser!.delete();

  //     // Create user document in Firestore
  //     await workerData.reference.delete();

  //     try {

  //       print('Message sent: ' + sendReport.toString());
  //     } on MailerException catch (e) {
  //       print('Message not sent.');
  //       print(e.toString());
  //     }
  //   } catch (error) {
  //     emit(ManageWorkersError(error.toString()));
  //   }
  // }
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

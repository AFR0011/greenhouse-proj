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
Future<void> createWorker(email) async{
    FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: '12345678');
    try{
      await users.add({
        "creationDate": Timestamp.now(),
        "emai":email,
        "name":email,
        "surname":email,
        "role":"worker"
      });
  } catch (error){
    emit(ManageWorkersError(error.toString()));
  }
  }

  String username = 'itec229.gr1.21008639@gmail.com'; //Your Email
  String password =
      'pnvt twlg mrru dmus'; // 16 Digits App Password Generated From Google Account

  final smtpServer = gmail(username,password);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.

  // Create our message.
  final message = Message()
        ..from = Address(username, 'Greenhouse Co.')
        ..recipients.add('recipient-email@gmail.com')
        // ..ccRecipients.addAll(['abc@gmail.com', 'xyz@gmail.com']) // For Adding Multiple Recipients
        // ..bccRecipients.add(Address('a@gmail.com')) For Binding Carbon Copy of Sent Email
        ..subject = 'Mail from Mailer'
        ..text = 'Hello dear, An account with the following pass'
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Mail Send Successfully")));
  } on MailerException catch (e) {
    print('Message not sent.');
    print(e.message);
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
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

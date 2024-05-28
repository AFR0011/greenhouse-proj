part of 'home_cubit.dart';

class NotificationsCubit extends HomeCubit {
  final CollectionReference notifications =
      FirebaseFirestore.instance.collection('notifications');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final UserCredential? user;

  bool _isActive = true;
  bool _isProcessing = false;

  NotificationsCubit(this.user) : super(NotificationsLoading()) {
    if (user != null) {
      initNotifications();
    }
  }

  void initNotifications() async {
    if (!_isActive) return;
    // _firebaseMessaging.requestPermission();

    // String? fcmToken = await _firebaseMessaging.getToken();
    // print("Device Token: $fcmToken");

    // Get user reference
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user?.user?.email)
        .get();
    DocumentReference userReference = userQuery.docs.first.reference;

    // Get user notifications
    notifications
        .where('user', isEqualTo: userReference)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final List<NotificationData> notifications = snapshot.docs
          .map((doc) => NotificationData.fromFirestore(doc))
          .toList();
      if (_isActive && !_isProcessing)
        emit(NotificationsLoaded([...notifications]));
    }, onError: (error) {
      if (_isActive && !_isProcessing)
        emit(NotificationsError(error.toString()));
    });
  }

  void handleNotification(RemoteMessage? message) {
    if (!_isActive || message == null) return;
    _isProcessing = true;
    // HANDLE NOTIFICATION WITHIN APP
    _isProcessing = false;
  }

// // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
//     final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
//     if (apnsToken != null) {
//       // APNS token is available, make FCM plugin API requests...
//     }
//   }

  Future<void> sendNotification(
      String userId, String title, String body) async {
    final url = Uri.parse(
        'https://your-heroku-app-name.herokuapp.com/sendNotification'); // Replace with your Heroku app URL

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'userId': userId,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Future<void> close() {
    _isActive = false;
    return super.close();
  }
}

class NotificationData {
  final String message;
  final DateTime timestamp;

  NotificationData({
    required this.message,
    required this.timestamp,
  });

  factory NotificationData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationData(
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

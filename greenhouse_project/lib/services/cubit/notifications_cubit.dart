part of 'home_cubit.dart';

class NotificationsCubit extends HomeCubit {
  final CollectionReference notifications =
      FirebaseFirestore.instance.collection('notifications');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final UserCredential? user;

  bool _isActive = true;

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

    //Get user notifications
    // Get user notifications
    notifications
        .where('user', isEqualTo: userReference)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final List<NotificationData> notifications = snapshot.docs
          .map((doc) => NotificationData.fromFirestore(doc))
          .toList();
      emit(NotificationsLoaded([...notifications]));
    }, onError: (error) {
      emit(NotificationsError(error.toString()));
    });
  }

  void handleNotification(RemoteMessage? message) {
    if (!_isActive || message == null) return;
  }

// // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
//     final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
//     if (apnsToken != null) {
//       // APNS token is available, make FCM plugin API requests...
//     }
//   }
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

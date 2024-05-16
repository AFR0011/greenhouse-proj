part of 'home_cubit.dart';

class NotificationsCubit extends HomeCubit {
  final CollectionReference notifications =
      FirebaseFirestore.instance.collection('notifications');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final UserCredential? user;

  NotificationsCubit(this.user) : super(NotificationsLoading()) {
    if (user != null) {
      initNotifications();
    }
  }

  void initNotifications() async {
    String? deviceToken = await FirebaseMessaging.instance.getToken();

    // Get user notifications
    // Display or something?
    // Push notifications??

    // Get user reference
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user?.user?.email)
        .get();
    DocumentReference userReference = userQuery.docs.first.reference;

    //Get user notifications
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
    // You may set the permission requests to "provisional" which allows the user to choose what type
// of notifications they would like to receive once the user receives a notification.
    final notificationSettings =
        await FirebaseMessaging.instance.requestPermission(provisional: true);

// For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      // APNS token is available, make FCM plugin API requests...
    }
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

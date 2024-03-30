part of 'home_cubit.dart';

class NotificationsCubit extends HomeCubit {
  final CollectionReference notifications =
      FirebaseFirestore.instance.collection('notifications');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final UserCredential? user;

  NotificationsCubit(this.user) : super(NotificationsLoading()) {
    if (user != null) {
      _subscribeToNotifications();
    }
  }

  void _subscribeToNotifications() async {
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

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Singleton pattern
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  Future<void> init() async {
    // Requesting permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // Handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Message received in foreground: ${message.notification?.title} - ${message.notification?.body}');
    });

    // Optionally, handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
  }

  static Future<void> _firebaseBackgroundMessageHandler(
      RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }
}

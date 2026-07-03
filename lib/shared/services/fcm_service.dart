import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/firebase_collections.dart';
import '../../core/utils/logger.dart';
import '../../features/auth/models/user_model.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize FCM service: request permission, set up handlers, initialize local notifications
  Future<void> initialize() async {
    // Request notification permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    logger.info('FCM permission status: ${settings.authorizationStatus}');

    // Initialize local notifications for foreground display
    await _initLocalNotifications();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check for initial message (when app was terminated and opened via notification)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    logger.info('FCM service initialized');
  }

  /// Initialize Flutter Local Notifications plugin
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        logger.info('Notification tapped: ${response.payload}');
        // Deep linking will be handled by the router
      },
    );

    // Create notification channels for Android 8.0+
    const androidChannel = AndroidNotificationChannel(
      'barber_book_channel',
      'BarberBook Notifications',
      description: 'Notifications for booking updates, promotions, and more',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Get the current FCM device token and save it to Firestore
  Future<String?> getToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveToken(userId, token);
        logger.info('FCM token saved for user: $userId');
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        await _saveToken(userId, newToken);
        logger.info('FCM token refreshed for user: $userId');
      });

      return token;
    } catch (e) {
      logger.error('FCM getToken error: $e');
      return null;
    }
  }

  /// Save FCM token to the user's Firestore document
  Future<void> _saveToken(String userId, String token) async {
    await _firestore.collection(FirebaseCollections.users).doc(userId).update({
      'fcmToken': token,
    });
  }

  /// Subscribe to topics based on user role
  Future<void> subscribeToTopics(UserModel user) async {
    if (user.isCustomer) {
      await _messaging.subscribeToTopic(AppConstants.topicAllCustomers);
      await _messaging.subscribeToTopic(AppConstants.topicPromotions);
      logger.info('Subscribed to customer topics');
    } else if (user.isAdmin) {
      await _messaging.subscribeToTopic(AppConstants.topicAllAdmins);
      logger.info('Subscribed to admin topics');
    }
  }

  /// Unsubscribe from all topics (on logout)
  Future<void> unsubscribeFromAllTopics() async {
  await _messaging.unsubscribeFromTopic(AppConstants.topicAllCustomers);
  await _messaging.unsubscribeFromTopic(AppConstants.topicAllAdmins);
  await _messaging.unsubscribeFromTopic(AppConstants.topicPromotions);

  logger.info('Unsubscribed from all topics');
}

  /// Handle foreground messages by displaying a local notification
  void _handleForegroundMessage(RemoteMessage message) {
    logger.info(
      'Foreground notification: ${message.notification?.title} - ${message.notification?.body}',
    );

    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'barber_book_channel',
            'BarberBook Notifications',
            channelDescription: 'Notifications for booking updates and promotions',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['route'],
      );
    }
  }

  /// Handle notification tap (background/terminated state)
  void _handleNotificationTap(RemoteMessage message) {
    logger.info('Notification tapped with data: ${message.data}');
    // Navigation will be handled by the router via deep link data in message.data
  }

  Future<void> showTestNotification({

  required String title,

  required String body,

}) async {

  await _localNotifications.show(

    999,

    title,

    body,

    const NotificationDetails(

      android: AndroidNotificationDetails(

        'barber_book_channel',

        'BarberBook Notifications',

        channelDescription:
            'Notifications',

        importance: Importance.high,

        priority: Priority.high,

      ),

    ),

  );

}

  /// Get the current badge count (Android)
  Future<int> getBadgeCount() async {
    // Badge count is managed via Firestore notification query
    return 0;
  }

  /// Clear badge count
  Future<void> clearBadge() async {
    await _messaging.setAutoInitEnabled(true);
  }
}

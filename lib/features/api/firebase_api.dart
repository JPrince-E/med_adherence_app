// // ignore_for_file: avoid_print

// import 'dart:convert';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:med_adherence_app/features/views/notification_screen.dart';
// import 'package:med_adherence_app/main.dart';

// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   print('Title: ${message.notification?.title}');
//   print('Body: ${message.notification?.body}');
//   print('Payload: ${message.data}');
// }

// class FirebaseApi {
//   final _firebaseMessaging = FirebaseMessaging.instance;

//   final _androidChannel = const AndroidNotificationChannel(
//     'high_importance_channel',
//     'High Importance Notifications',
//     description: 'This channel is used for important notifications',
//     importance: Importance.defaultImportance,
//   );

//   final _localNotifications = FlutterLocalNotificationsPlugin();

//   void handleMessage(RemoteMessage? message) {
//     if (message == null) return;

//     navigatorKey.currentState?.pushNamed(
//       NotificationScreen.route,
//       arguments: message,
//     );
//   }

//   void onDidReceiveLocalNotification(
//       NotificationResponse notificationResponse) async {
//     final String? payload = notificationResponse.payload;
//     if (notificationResponse.payload != null) {
//       print('notification payload: $payload');
//     }
//   }

//   Future initLocalNotifications() async {
//     const androidinitializationSettings =
//         AndroidInitializationSettings('@drawable/logo');
//     final DarwinInitializationSettings iosInitializationSettingsDarwin =
//         DarwinInitializationSettings(
//       requestSoundPermission: false,
//       requestBadgePermission: false,
//       requestAlertPermission: false,
//       onDidReceiveLocalNotification: onDidReceiveLocalNotification,
//     );
//     InitializationSettings settings = InitializationSettings(
//       android: androidinitializationSettings,
//       iOS: iosInitializationSettingsDarwin,
//     );

//     await _localNotifications.initialize(
//       settings,
//       // onSelectNotification: (payload) {
//       //   final message = RemoteMessage.fromMap(jsonDecode(payload!));
//       //   handleMessage(message);
//       // }
//     );

//     final platform = _localNotifications.resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>();
//     await platform?.createNotificationChannel(_androidChannel);
//   }

//   Future initPushNotifications() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//     FirebaseMessaging.onMessage.listen((message) {
//       final notification = message.notification;
//       if (notification == null) return;

//       _localNotifications.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             _androidChannel.id,
//             _androidChannel.name,
//             channelDescription: _androidChannel.description,
//             icon: '@drawable/logo',
//           ),
//         ),
//         payload: jsonEncode(message.toMap()),
//       );
//     });
//   }

//   Future<void> initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     final fCMToken = await _firebaseMessaging.getToken();
//     print('Token: $fCMToken');
//     initPushNotifications();
//     initLocalNotifications();
//   }
// }


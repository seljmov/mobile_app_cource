import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'local_notification_service.dart';

class FirebaseConfigurator {
  /// Обработчик сообщений
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Handling a background message');
  }

  static void printMessageData(RemoteMessage message) {
    debugPrint("title -> ${message.notification!.title}");
    debugPrint("body -> ${message.notification!.body}");
    debugPrint("data -> ${message.data}");
  }

  /// Настройка Firebase
  static Future<void> configureFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    var messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await LocalNotificationService.initialize();

    // 1. Этот метод вызывается, когда приложение находится в завершенном состоянии, и вы получаете уведомление
    // когда вы нажимаете на уведомление, приложение открывается из завершенного состояния и
    // вы можете получить данные уведомления с помощью этого метода
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      debugPrint("FirebaseMessaging.getInitialMessage");
      if (message != null && message.notification != null) {
        printMessageData(message);
        await LocalNotificationService.showNotification(message);
      }
    });

    // 2. Этот метод вызывается только тогда, когда приложение находится
    // на переднем плане, это означает, что приложение должно быть открыто
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint("FirebaseMessaging.onMessage.listen");
      if (message.notification != null) {
        printMessageData(message);
        await LocalNotificationService.showNotification(message);
      }
    });

    // 3. Этот метод вызывается только тогда, когда приложение находится
    // в фоновом режиме и не завершается (не закрывается)
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      debugPrint("FirebaseMessaging.onMessageOpenedApp.listen");
      if (message.notification != null) {
        printMessageData(message);
        await LocalNotificationService.showNotification(message);
      }
    });
  }
}

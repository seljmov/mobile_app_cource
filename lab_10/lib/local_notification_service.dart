import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Сервис работы с уведомлениями
class LocalNotificationService {
  static const _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // name
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
  );

  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Инициализировать плагин отправки уведомлений
  static Future<void> initialize() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: IOSInitializationSettings(),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// Показать уведомление
  static Future<void> showNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "flutter_push_notification_app",
          "flutter_push_notification_app",
          importance: Importance.max,
          priority: Priority.high,
          color: Colors.black,
          playSound: true,
          icon: "@mipmap/ic_launcher",
        ),
        iOS: IOSNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        ),
      );

      debugPrint("title -> ${message.notification!.title}");
      debugPrint("body -> ${message.notification!.body}");
      debugPrint("data -> ${message.data}");

      await _notificationsPlugin.show(
        id,
        message.notification?.title,
        message.notification?.body,
        notificationDetails,
        payload: json.encode(message.data),
      );
    } on Exception catch (e) {
      debugPrint(
        "LocalNotificationService -> createAndDisplayNotification(message) -> e -> $e",
      );
    }
  }

  /// Отправить токен устройства в firebase
  static Future<void> sendDevicePushNotificationToken() async {
    final firestore = FirebaseFirestore.instance;
    final fcm = FirebaseMessaging.instance;

    final token = await fcm.getToken();

    final tokens = firestore.collection('tokens').doc(token);

    await tokens.set({
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem
    });
    debugPrint("firebase token отправлен!");
    debugPrint("token -> $token");
  }

  /// Отправить тестовое сообщение самому себе через firebase
  static Future<void> sendTestPushNotificationIntoFcm({
    required String title,
    required String body,
  }) async {
    final fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();

    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      'to': '$token',
      'notification': {
        'title': title,
        'body': body,
        'sound': 'default',
        'playSound': true,
      },
      'data': {
        'Type': 1,
        'RequestId': 537,
      },
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=',
    };

    final client = Dio();
    final response = await client.post(
      postUrl,
      data: data,
      options: Options(
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      debugPrint("okey");
    } else {
      debugPrint('bad -> ${response.statusCode}');
    }
  }
}

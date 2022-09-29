import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lab_10/local_notification_service.dart';

import 'firebase_configurator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalNotificationService.sendDevicePushNotificationToken();
  await FirebaseConfigurator.configureFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.center,
          child: Text("Hello world!"),
        ),
      ),
    );
  }
}

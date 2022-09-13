import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<Map<Permission, PermissionStatus>> _getPermisionStatuses() async {
    return await [
      Permission.storage,
      Permission.contacts,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        body: Align(
          alignment: Alignment.center,
          child: FutureBuilder<Map<Permission, PermissionStatus>>(
            future: _getPermisionStatuses(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError ||
                  snapshot.error != null ||
                  !snapshot.hasData ||
                  snapshot.data == null) {
                return const Text(
                  "Что-то пошло не так...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                );
              }

              var permissions = snapshot.data!;
              final contactPermission =
                  permissions.containsKey(Permission.contacts) &&
                      permissions[Permission.contacts]!.isGranted;
              final storagePermission =
                  permissions.containsKey(Permission.storage) &&
                      permissions[Permission.storage]!.isGranted;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Разрешение галереи",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    storagePermission ? "Получено" : "Не получено",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          storagePermission ? Colors.white : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Разрешение контактов",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contactPermission ? "Получено" : "Не получено",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          contactPermission ? Colors.white : Colors.redAccent,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

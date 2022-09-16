import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String filename = 'counter';

  Future<String> _getFilenamePath() async {
    final path = (await getApplicationDocumentsDirectory()).path;
    return '$path/$filename.txt';
  }

  Future<File> _getFile(String path) async {
    if (!(await File(path).exists())) {
      return File(path).create();
    }
    return File(path);
  }

  Future<int> _getSavedPointsNumber() async {
    final path = await _getFilenamePath();
    final file = await _getFile(path);
    final content = await file.readAsString();
    final point = int.tryParse(content) ?? 0;
    return point;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(28, 28, 30, 1),
        body: FutureBuilder<int>(
          future: _getSavedPointsNumber(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData ||
                snapshot.data == null ||
                snapshot.hasError ||
                snapshot.error != null) {
              return const Center(
                child: Text(
                  "Что-то пошло не так...",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            }

            final point = snapshot.data ?? 0;
            final pointsNotifier = ValueNotifier<int>(point);
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Количество очков",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ValueListenableBuilder<int>(
                    valueListenable: pointsNotifier,
                    builder: (context, points, child) {
                      return Text(
                        points.toString(),
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            pointsNotifier.value = pointsNotifier.value - 1;
                          },
                          icon: const Icon(Icons.remove),
                          label: const Text("Убавить"),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            pointsNotifier.value = pointsNotifier.value + 1;
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Добавить"),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final path = await _getFilenamePath();
                          final file = await _getFile(path);
                          await file.writeAsString(
                            pointsNotifier.value.toString(),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.grey,
                          ),
                        ),
                        child: const Text("Сохранить в файл"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final path = await _getFilenamePath();
                          final file = await _getFile(path);
                          final content = await file.readAsString();
                          final points = int.tryParse(content);
                          if (points != null) {
                            pointsNotifier.value = points;
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.grey,
                          ),
                        ),
                        child: const Text("Прочитать из файла"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

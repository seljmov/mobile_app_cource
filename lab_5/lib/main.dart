import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(
    availableCameras: cameras,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.availableCameras,
  }) : super(key: key);

  final List<CameraDescription> availableCameras;

  @override
  Widget build(BuildContext context) {
    var currentIndex = 0;
    final size = availableCameras.length;
    final cameraControllerNotifier = ValueNotifier<CameraController>(
      CameraController(
        availableCameras[currentIndex],
        ResolutionPreset.low,
      ),
    );
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            ValueListenableBuilder<CameraController>(
              valueListenable: cameraControllerNotifier,
              builder: (context, controller, child) {
                return Align(
                  alignment: Alignment.center,
                  child: FutureBuilder<void>(
                    future: controller.initialize(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      return CameraPreview(controller);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                currentIndex = currentIndex == size - 1 ? 0 : currentIndex + 1;
                cameraControllerNotifier.value = CameraController(
                  availableCameras[currentIndex],
                  ResolutionPreset.low,
                );
              },
              child: const Text("Переключить камеру"),
            ),
          ],
        ),
      ),
    );
  }
}

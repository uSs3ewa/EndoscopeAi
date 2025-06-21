// ====================================================
//  Главное окно приложения, на котором производится отрисовка
// ====================================================
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'pages/file_video_page.dart';
import 'pages/home_page.dart';
import 'pages/recordings_page.dart';
import 'routes.dart';
import 'pages/stream_page.dart';
import 'pages/annotate/annotate_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  // Получение списка доступных камер
  Future<void> _initializeCameras() async {
    try {
      cameras = await availableCameras();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing cameras: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EncodescopeAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 90, 6, 201),
        ),
      ),
      initialRoute: Routes.root,
      routes: {
        Routes.recordings: (context) => RecordingsPage(),
        Routes.homePage: (context) => const HomePage(),
        Routes.fileVideoPlayer: (context) => const FileVidePlayerPage(),
        Routes.streamVideoPlayer: (context) {
          if (!_isCameraInitialized || cameras.isEmpty) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return StreamPage(camera: cameras.first);
        },
        Routes.annotate: (context) {
          final path = ModalRoute.of(context)!.settings.arguments as String;
          return AnnotatePage(imagePath: path);
        },
      },
    );
  }
}

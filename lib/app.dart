// ====================================================
//  Главное окно приложения, на котором производится отрисовка
// ====================================================
import 'package:flutter/material.dart';

import 'pages/file_video_page.dart';
import 'pages/home_page.dart';
import 'pages/recordings_page.dart';
import 'routes.dart';
import 'pages/stream_page.dart';
import 'pages/annotate/annotate_page.dart';

//  Главное окно приложения, на котором производится отрисовка
class App extends StatelessWidget {
  const App({super.key});

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
        // инициализация путей и окон
        Routes.recordings: (context) => RecordingsPage(),
        Routes.homePage: (context) => const HomePage(),
        Routes.fileVideoPlayer: (context) => const FileVidePlayerPage(),
        Routes.streamVideoPlayer: (context) => StreamPlayerPage(),

        // — новое окно аннотаций —
        Routes.annotate: (context) {
          final path =
            ModalRoute.of(context)!.settings.arguments as String;
          return AnnotatePage(imagePath: path);
        },
      },
    );
  }
}
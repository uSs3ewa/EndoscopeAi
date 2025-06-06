import 'package:flutter/material.dart';

import 'streamApp.dart';
import 'homePage.dart';
import 'recordingsApp.dart';
import 'fileVideoApp.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 90, 6, 201),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/recordings': (context) => RecordingsApp(),
        '/': (context) => const HomePage(),
        '/fileVideoPlayer': (context) => const FileVideoApp(),
        '/streamVideoPlayer': (context) => StreamPlayerApp(),
      },
    );
  }
}
import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player_win/video_player_win.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Video Player App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 98, 8, 214)),
        ),
        initialRoute: '/',
        routes: {
          '/recordings': (context) => RecordingsApp(),
          '/': (context) => const MyHomePage(),
          '/fileVideoPlayer': (context) => const FileVideoApp(),
          '/streamVideoPlayer': (context) => StreamPlayerApp(),
        },
      ),
    );
  }
}

class StreamPlayerApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Стриминг плеер:')),
    body: Column(children: [ElevatedButton(onPressed: () {Navigator.pushNamed(context, '/');}, child: Text("Назад"))],));
  }

}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная страница')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                ChooseFile.pickFile(context);
              },
              child: const Text('Открыть видеоплеер'),
            ),
            const SizedBox(height: 20),
             ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/recordings');
              },
              child: const Text('Открыть видеозаписи'),
            ),
            const SizedBox(height: 20),
             ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/streamVideoPlayer');
              },
              child: const Text('Открыть стриминговый плеер'),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordingsApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Записи:')),
    body: Column(children: [ElevatedButton(onPressed: () {Navigator.pushNamed(context, '/');}, child: Text("Назад"))],));
  }

}

class FileVideoApp extends StatefulWidget {
  const FileVideoApp({super.key});

  @override
  State<FileVideoApp> createState() => _FileVideoAppState();
}

class _FileVideoAppState extends State<FileVideoApp> {
  late final WinVideoPlayerController _controller;
  late final Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  bool _showControls = false;
  bool _isValidFile = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late ScreenshotController _screenshotController;


  @override
  void initState() {
    super.initState();

    if (ChooseFile.checkFile()){
      _isValidFile = true;
      _screenshotController = ScreenshotController();
      _controller = WinVideoPlayerController.file(File(ChooseFile.filePath.toString()))
      ..initialize().then((_) {
        setState(() {
          _totalDuration = _controller.value.duration;
        });
        
        // Обновляем позицию каждые 100 мс
        _controller.addListener(_updateProgress);
      });
          // _controller = WinVideoPlayerController.network(
    //   'https://xn--80aafadvc9bifbaeqg0p.xn--p1ai/03-03-2025/1.mp4',
    // );
    
    _initializeVideoPlayerFuture = _controller.initialize()//.then((_) {
    //   // Автоматически начинаем воспроизведение после инициализации
    //   _controller.play();
    //   setState(() => _isPlaying = true);
    // })
    .catchError((error) {
      debugPrint('Ошибка инициализации видео: $error');
    });
    }
  }

  void _updateProgress() {
    if (mounted) {
      setState(() {
        _currentPosition = _controller.value.position;
        _totalDuration = _controller.value.duration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidFile){
      return Center(
        child: Screenshot(controller: _screenshotController,
        child: Scaffold(
          appBar: AppBar(
          title: const Text('Видеоплеер'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () async {
                 // Получаем скриншот
                 await _screenshotController.capture(delay: const Duration(seconds: 1))
                     .then((image) async {
                   if (image != null) {
                     // Сохраняем скриншот в файл
                     // Используйте любой метод сохранения, который вам нужен (например, File.writeAsBytes)
                     print('Скриншот получен');
                     final directory = Directory.current;
                     final filePath = '${directory.path}/data/screenshots/screenshot.png'; // Создайте имя файла // TODO: добавить реализацию отслеживания количества созданных скриншотов, для этого нужно создать отдельную функцию
                     final file = File(filePath);
                     await file.writeAsBytes(image); // Сохраните скриншот в файл
                     print('Скриншот сохранен в: $filePath');
                   } else {
                     print('Ошибка при получении скриншота');
                   }
                 });
               },
      backgroundColor: const Color.fromARGB(255, 252, 232, 232), 
      child: Icon(Icons.camera_alt, color: const Color.fromARGB(255, 65, 63, 63)),),
      body: Center( child: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка загрузки видео: ${snapshot.error}'));
            }
            return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: WinVideoPlayer(_controller),
          ),
          if (_showControls || !_isPlaying)
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 167, 38, 29),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: _togglePlayPause,
              ),
            ),
            if (_showControls || !_isPlaying)
            // Полоска прогресса
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text(_formatDuration(_currentPosition)),
                    Expanded(
                      child: Slider(
                        activeColor: const Color.fromARGB(255, 167, 38, 29),
                        value: _currentPosition.inMilliseconds.toDouble(),
                        min: 0,
                        max: _totalDuration.inMilliseconds.toDouble(),
                        onChangeStart: (_) {if (!_isPlaying) _controller.pause();},
                        onChangeEnd: (_) {if (_isPlaying) _controller.play();},
                        onChanged: (value) {
                          setState(() {
                            _currentPosition = Duration(milliseconds: value.toInt());
                            _controller.seekTo(_currentPosition);
                          });
                        },
                      ),
                    ),
                    Text(_formatDuration(_totalDuration)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    )
    ),
    )
      );
    }
    else {
      return Scaffold(appBar: AppBar(title: const Text('Error'), leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {Navigator.pushNamed(context, '/');},
        ),),
    body: const Text('Ошибка во время открытия файла'));
    }
  }

   String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    return duration.inHours > 0 
      ? '$hours:$minutes:$seconds' 
      : '$minutes:$seconds';
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller.play() : _controller.pause();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ChooseFile{
  static String? filePath;
  static String? fileName;

  static bool checkFile(){
    if (filePath == null){
      return false;
    }
    return true;
  }

  static void pickFile(BuildContext context) async {
       FilePickerResult? result = await FilePicker.platform.pickFiles(
         type: FileType.video, // Или конкретный тип файла
       );
       print(result);

       if (result != null) {
         // Получаем путь к выбранному файлу
         ChooseFile.filePath = result.files.single.path;
         ChooseFile.fileName = p.basenameWithoutExtension(result.files.single.path.toString());
         // Обрабатываем выбранный файл (открываем, загружаем, и т.д.)
         print('Выбранный файл: $filePath');
       } else {
         print('Отменено пользователем');
       }
       Navigator.pushNamed(context, '/fileVideoPlayer');
     }
}

class ScreenshotData {
  
}

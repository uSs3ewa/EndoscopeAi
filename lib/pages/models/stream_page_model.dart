// ====================================================
//  Страница для просмотра стриммингого видео
//  Тут имплементировано взаимодействие с логикой, не касающейся UI
// ====================================================

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:endoscopy_ai/shared/widget/screenshot_preview.dart';
import 'package:endoscopy_ai/backend/python_service.dart';
import 'package:path/path.dart' as p;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/services.dart';

class StreamPageModel with ChangeNotifier {
  final CameraDescription cameraDescription; // данные о камере
  CameraController? _controller;
  bool _isInitialized = false; // инициализированная ли камера
  bool _cameraAvailable = true; // доступна ли камера
  final List<ScreenshotPreviewModel> _shots = []; // список миниатюр
  late final Future<void> cameraInitialized; // состояние инициализации камеры
  Timer? _cameraCheckTimer; // Таймер для периодической проверки
  final PythonService _python = PythonService();
  StreamSubscription<String>? _sttSub;
  final List<String> _transcripts = [];
  final List<String> _segments = [];
  bool _isRecording = false;
  bool _isPaused = false;
  late final Directory _recordingsDir;

  Future<void> _runSystemFFmpeg(String listFile, String output) async {
    final ffmpeg = Platform.environment['FFMPEG_PATH'] ?? 'ffmpeg';
    await Process.run(
      ffmpeg,
      [
        '-y',
        '-f',
        'concat',
        '-safe',
        '0',
        '-i',
        listFile,
        '-c',
        'copy',
        output,
      ],
      runInShell: true,
    );
  }

  bool get recording => _isRecording;
  bool get paused => _isPaused;
  List<String> get transcripts => _transcripts;

  // Геттеры/сеттеры
  bool get isInitialized => _isInitialized;
  bool get cameraAvailable => _cameraAvailable; // Геттер для доступности камеры
  CameraController get controller => _controller!;
  List<ScreenshotPreviewModel> get shots => _shots;

  // `cameraDescription` -  данные о камере
  StreamPageModel({required this.cameraDescription}) {
    cameraInitialized = _initializeCamera();
    _prepareDirs();
    _startCameraCheckTimer();
  }

  // Инициализация контроллера камеры
  Future<void> _initializeCamera() async {
    try {
    // Если контроллер уже создан, освободим ресурсы перед повторной инициализацией
      if (_controller != null) {
        try {
          if (_controller!.value.isRecordingVideo) {
            await _controller!.stopVideoRecording();
          }
        } catch (_) {}
        await _controller!.dispose();
      }

      _controller = CameraController(
        cameraDescription,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing camera: $e');
      }
      _isInitialized = false;
      _controller = null;
    }
  }

  Future<void> initialize() async {
    await _initializeCamera();
    _startCameraCheckTimer();
  }

  Future<void> _prepareDirs() async {
    final base = await getApplicationDocumentsDirectory();
    _recordingsDir = Directory(p.join(base.path, 'recordings'));
    if (!await _recordingsDir.exists()) {
      await _recordingsDir.create(recursive: true);
    }
  }

  // Метод для проверки состояния камеры
  Future<void> _checkCameraAvailability() async {
    try {
      if (!_isInitialized) {
        await _initializeCamera();
      } else {
        // Простая проверка, можно добавить более сложную логику
        _cameraAvailable = true;
        notifyListeners();
      }
    } catch (e) {
      _cameraAvailable = false;
      _isInitialized = false;
      notifyListeners();
    }
  }

  // Запуск таймера для периодической проверки
  void _startCameraCheckTimer() {
    _cameraCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await _checkCameraAvailability();
    });
  }

  // Сохранение кадра в файл. Возвращает путь к этому кадру
  Future<XFile?> takePicture() async {
    if (!_isInitialized) return null;
    try {
      return await _controller!.takePicture();
    } catch (e) {
      if (kDebugMode) {
        print('Error taking picture: $e');
      }
      return null;
    }
  }

  // Функция, которая вызвается при успешном сохранении кадра
  void saveScreenshot(XFile file) {
    // Добавляем кадр в ленту
    _shots.add(
      ScreenshotPreviewModel(
        file.path,
        Duration.zero /* TODO: implement stopwatch */,
      ),
    );
  }

  Future<void> startRecording() async {
    if (_isRecording || !_isInitialized) return;
    await _controller!.startVideoRecording();
    _isRecording = true;
    _isPaused = false;
    _segments.clear();
    _transcripts.clear();
    _sttSub = _python.listen().listen((t) {
      if (t.trim().isEmpty) return;
      _transcripts.add(t.trim());
      notifyListeners();
    });
    notifyListeners();
  }
 
  Future<String?> stopRecording({String? savePath}) async {
    if (!_isRecording) return null;
    try {
      if (!_isPaused) {
        final file = await _controller!.stopVideoRecording();
        _segments.add(file.path);
      }
      _isRecording = false;
      _isPaused = false;
      _sttSub?.cancel();
      _python.stopListening();
      final outFileName =
          '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final recordingsOut = p.join(_recordingsDir.path, outFileName);

    if (_segments.length == 1) {
      await File(_segments.first).copy(recordingsOut);
    } else {
      final listFile = File(p.join(_recordingsDir.path, 'segments.txt'));
      final content = _segments
          .map((s) => "file '${s.replaceAll('\\', '/')}'")
          .join('\n');
      await listFile.writeAsString(content);
     try {
        if (Platform.isWindows || Platform.isLinux) {
          await _runSystemFFmpeg(listFile.path, recordingsOut);
        } else {
          try {
            await FFmpegKit.execute(
                "-y -f concat -safe 0 -i \"${listFile.path}\" -c copy \"$recordingsOut\"");
          } on MissingPluginException {
            await _runSystemFFmpeg(listFile.path, recordingsOut);
          }
        }
      } finally {
        await listFile.delete();
      }
    }

    for (final s in _segments) {
      try {
        File(s).deleteSync();
      } catch (_) {}
    }
    _segments.clear();

    String finalPath = recordingsOut;
    if (savePath != null) {
      await File(recordingsOut).copy(savePath);
      finalPath = savePath;
    }
    notifyListeners();
    return finalPath;
    } catch (e) {
      if (kDebugMode) {
        print('Error during stopRecording: $e');
      }
      return null;
    }
  }

  // Освобождение ресурсов
  void dispose() {
    print('StreamPageModel disposed');

    _sttSub?.cancel();
    _python.stopListening();

    if (_controller != null) {
      if (_controller!.value.isRecordingVideo) {
        _controller!.stopVideoRecording();
      }
      _controller!.dispose();
      _controller = null;
    }
    _isInitialized = false;
    _isPaused = false;
    _cameraCheckTimer?.cancel();
    super.dispose();
  }
}

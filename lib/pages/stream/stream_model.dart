// ====================================================
//  Страница для просмотра стриммингого видео
//  Тут имплементировано взаимодействие с логикой, не касающейся UI
// ====================================================

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:endoscopy_ai/shared/widget/screenshot_preview.dart';
import 'package:endoscopy_ai/shared/camera/windows_camera_helper.dart';
import 'package:path/path.dart' as p;
import 'package:endoscopy_ai/pages/recordings/recordings_model.dart';
import 'package:endoscopy_ai/features/patient/record_data.dart';

class StreamPageModel with ChangeNotifier {
  final CameraDescription cameraDescription; // данные о камере
  final RecordData recordData;
  CameraController? _controller;
  bool _isInitialized = false; // инициализированная ли камера
  bool _cameraAvailable = true; // доступна ли камера
  final List<ScreenshotPreviewModel> _shots = []; // список миниатюр
  Future<void>? _cameraInitializationFuture; // состояние инициализации камеры
  Timer? _cameraCheckTimer; // Таймер для периодической проверки
  StreamSubscription<String>? _sttSub;
  final List<String> _transcripts = [];
  bool _isRecording = false;
  bool _isPaused = false;
  late final Directory _recordingsDir;
  late final Directory _screenshotsDir;
  bool _isDisposed = false; // Флаг для предотвращения операций после dispose

  bool get recording => _isRecording;
  bool get paused => _isPaused;
  List<String> get transcripts => _transcripts;

  // Геттеры/сеттеры
  bool get isInitialized => _isInitialized;
  bool get cameraAvailable => _cameraAvailable; // Геттер для доступности камеры
  CameraController? get controller => _controller;
  List<ScreenshotPreviewModel> get shots => _shots;

  // `cameraDescription` -  данные о камере
  StreamPageModel({required this.cameraDescription, required this.recordData}) {
    _prepareDirs();
    // Не инициализируем камеру в конструкторе, только в initialize()
  }

  // Инициализация контроллера камеры с Windows-специфичными фиксами
  Future<void> _initializeCamera() async {
    if (_isDisposed) return;

    // Если уже инициализируемся, ждем завершения
    if (_cameraInitializationFuture != null) {
      await _cameraInitializationFuture;
      return;
    }

    // Создаем новую Future для инициализации
    _cameraInitializationFuture = _performCameraInitialization();

    try {
      await _cameraInitializationFuture;
    } finally {
      _cameraInitializationFuture = null;
    }
  }

  Future<void> _performCameraInitialization() async {
    if (_isDisposed) return;

    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;
    while (attempt < maxAttempts) {
      try {
        await _disposeCamera();
        await Future.delayed(Duration(milliseconds: delayMs));
        _controller = null;

        // Используем Windows-специфичный хелпер для инициализации
        _controller = await WindowsCameraHelper.initializeCamera(
          cameraDescription,
          resolution: ResolutionPreset.medium,
          enableAudio: true,
        );

        if (_isDisposed) {
          await _disposeCamera();
          return;
        }

        _isInitialized = true;
        _cameraAvailable = true;

        // Set camera modes safely (auto, as example)
        if (_controller != null) {
          await safeSetFlashMode(FlashMode.auto);
          await safeSetExposureMode(ExposureMode.auto);
          await safeSetFocusMode(FocusMode.auto);
        }

        // Уведомляем слушателей на главном потоке
        if (!_isDisposed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDisposed) {
              notifyListeners();
            }
          });
        }
        return;
      } catch (e) {
        final errorDescription =
            WindowsCameraHelper.getWindowsCameraErrorDescription(e);
        final isAlreadyExists =
            e.toString().contains('Camera with given device id already exists');
        if (kDebugMode) {
          print('Error initializing camera: $errorDescription');
          print('Original error: $e');
        }
        if (isAlreadyExists) {
          attempt++;
          delayMs *= 2; // Exponential backoff
          if (kDebugMode) {
            print(
                'Camera already exists error detected. Waiting longer before retry...');
          }
          await Future.delayed(Duration(milliseconds: delayMs));
          continue;
        }
        _isInitialized = false;
        _cameraAvailable = false;
        await _disposeCamera();
        _controller = null;
        if (!_isDisposed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDisposed) {
              notifyListeners();
            }
          });
        }
        throw Exception(errorDescription);
      }
    }
    // If we reach here, all attempts failed
    _isInitialized = false;
    _cameraAvailable = false;
    await _disposeCamera();
    _controller = null;
    if (!_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          notifyListeners();
        }
      });
    }
    throw Exception(
        'Camera initialization failed after $maxAttempts attempts: Camera is already in use. Please close other applications using the camera and try again.');
  }

  Future<void> initialize() async {
    if (_isDisposed) return;
    await _initializeCamera();
    if (!_isDisposed) {
      _startCameraCheckTimer();
    }
  }

  Future<void> _prepareDirs() async {
    final base = Directory(recordData.pathToStorage);
    _recordingsDir = Directory(p.join(base.path, 'videos'));
    _screenshotsDir = Directory(p.join(base.path, 'screenshots')); 
    if (!await _recordingsDir.exists()) {
      await _recordingsDir.create(recursive: true);
    }
    if (!await _screenshotsDir.exists()) {
      await _screenshotsDir.create(recursive: true);
    }
  }

  // Метод для проверки состояния камеры
  Future<void> _checkCameraAvailability() async {
    if (_isDisposed) return;

    try {
      if (!_isInitialized || _controller == null) {
        // Check if camera is available before trying to initialize
        final isAvailable = await WindowsCameraHelper.isCameraAvailable(
          cameraDescription,
        );
        if (!isAvailable) {
          _cameraAvailable = false;
          _isInitialized = false;
          notifyListeners();
          return;
        }

        await _initializeCamera();
      } else {
        // Простая проверка, можно добавить более сложную логику
        _cameraAvailable = true;
        if (!_isDisposed) {
          notifyListeners();
        }
      }
    } catch (e) {
      _cameraAvailable = false;
      _isInitialized = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  // Метод для принудительной переинициализации камеры
  Future<void> reinitializeCamera() async {
    if (_isDisposed) return;

    try {
      _isInitialized = false;
      _cameraAvailable = false;
      notifyListeners();

      await _disposeCamera();
      await _initializeCamera();
    } catch (e) {
      if (kDebugMode) {
        print('Error reinitializing camera: $e');
      }
      _cameraAvailable = false;
      _isInitialized = false;
      notifyListeners();
    }
  }

  // Запуск таймера для периодической проверки
  void _startCameraCheckTimer() {
    if (_isDisposed) return;

    _cameraCheckTimer?.cancel();
    _cameraCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      await _checkCameraAvailability();
    });
  }

  // Сохранение кадра в файл. Возвращает путь к этому кадру
  Future<XFile?> takePicture() async {
    if (!_isInitialized || _controller == null || _isDisposed) return null;
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
  Future<void> saveScreenshot(XFile file) async {
    if (_isDisposed) return;

    final name = '${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
    final outPath = p.join(_screenshotsDir.path, name);
    await File(file.path).copy(outPath);

    _shots.add(
      ScreenshotPreviewModel(
        outPath,
        Duration.zero /* TODO: implement stopwatch */,
      ),
    );
  }

  Future<void> startRecording() async {
    if (_isRecording || !_isInitialized || _controller == null || _isDisposed)
      return;
    await _controller!.startVideoRecording();
    _isRecording = true;
    _isPaused = false;
    _transcripts.clear();
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<String?> stopRecording({String? savePath}) async {
    if (!_isRecording || _controller == null || _isDisposed) return null;
    try {
      final file = await _controller!.stopVideoRecording();
      _isRecording = false;
      _isPaused = false;
      _sttSub?.cancel();

      final outFileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final recordingsOut = p.join(_recordingsDir.path, outFileName);
      await File(file.path).copy(recordingsOut);
      String finalPath = recordingsOut;

      if (savePath != null) {
        await File(recordingsOut).copy(savePath);
        finalPath = savePath;
      }
      if (!_isDisposed) {
        notifyListeners();
      }
      // Автоматически добавляем запись в список записей
      await RecordingsPageModel().addRecording(
        Recording(
          filePath: finalPath,
          timestamp: DateTime.now(),
          fileName: p.basename(finalPath),
        ),
      );
      return finalPath;
    } catch (e) {
      if (kDebugMode) {
        print('Error during stopRecording: $e');
      }
      return null;
    }
  }

  // Platform-safe camera control helpers
  Future<void> safeSetFlashMode(FlashMode mode) async {
    if (Platform.isWindows) return; // Skip on Windows
    try {
      await _controller?.setFlashMode(mode);
    } catch (e) {
      if (e is UnimplementedError) {
        // if (kDebugMode) print('setFlashMode not implemented on this platform');
      } else {
        rethrow;
      }
    }
  }

  Future<void> safeSetExposureMode(ExposureMode mode) async {
    if (Platform.isWindows) return; // Skip on Windows
    try {
      await _controller?.setExposureMode(mode);
    } catch (e) {
      if (e is UnimplementedError) {
        // if (kDebugMode)
        //   print('setExposureMode not implemented on this platform');
      } else {
        rethrow;
      }
    }
  }

  Future<void> safeSetFocusMode(FocusMode mode) async {
    if (Platform.isWindows) return; // Skip on Windows
    try {
      await _controller?.setFocusMode(mode);
    } catch (e) {
      if (e is UnimplementedError) {
        // if (kDebugMode) print('setFocusMode not implemented on this platform');
      } else {
        rethrow;
      }
    }
  }

  // Example usage after camera initialization (call these only if needed):
  // await safeSetFlashMode(FlashMode.auto);
  // await safeSetExposureMode(ExposureMode.auto);
  // await safeSetFocusMode(FocusMode.auto);

  // Освобождение ресурсов
  @override
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    print('StreamPageModel disposed');

    _sttSub?.cancel();
    _cameraCheckTimer?.cancel();

    // Асинхронное освобождение ресурсов камеры
    _disposeCamera();

    _isInitialized = false;
    _isPaused = false;
    _isRecording = false;

    super.dispose();
  }

  // Безопасное освобождение ресурсов камеры
  Future<void> _disposeCamera() async {
    if (_controller == null) return;

    try {
      await WindowsCameraHelper.disposeCamera(_controller);
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing camera: $e');
      }
    } finally {
      _controller = null;
    }
  }
}

// ====================================================
//  Страница для просмотра стриммингого видео
//  Тут имплементировано взаимодействие с логикой, не касающейся UI
// ====================================================

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:endoscopy_ai/shared/widget/screenshot_preview.dart';

class StreamPageModel with ChangeNotifier {
  final CameraDescription cameraDescription; // данные о камере
  late CameraController _controller;
  bool _isInitialized = false; // инициализированная ли камера
  bool _cameraAvailable = true; // доступна ли камера
  final List<ScreenshotPreviewModel> _shots = []; // список миниатюр
  late final Future<void> cameraInitialized; // состояние инициализации камеры
  Timer? _cameraCheckTimer; // Таймер для периодической проверки

  // Геттеры/сеттеры
  bool get isInitialized => _isInitialized;
  bool get cameraAvailable => _cameraAvailable; // Геттер для доступности камеры
  CameraController get controller => _controller;
  List<ScreenshotPreviewModel> get shots => _shots;

  // `cameraDescription` -  данные о камере
  StreamPageModel({required this.cameraDescription}) {
    cameraInitialized = _initializeCamera();
    _startCameraCheckTimer();
  }

  // Инициализация контроллера камеры
  Future<void> _initializeCamera() async {
    try {
      _controller = CameraController(
        cameraDescription,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller.initialize();
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing camera: $e');
      }
    }
  }

  Future<void> initialize() async {
    await _initializeCamera();
    _startCameraCheckTimer();
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
      return await _controller.takePicture();
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

  // Освобождение ресурсов
  void dispose() {
    print('StreamPageModel disposed');

    _controller.dispose();
    _isInitialized = false;
    _cameraCheckTimer?.cancel();
  }
}

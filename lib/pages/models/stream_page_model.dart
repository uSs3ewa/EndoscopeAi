// ====================================================
//  Страница для просмотра стриммингого видео
//  Тут имплементировано взаимодействие с логикой, не касающейся UI
// ====================================================

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../../shared/widget/screenshot_preview.dart';

class StreamPageModel {
  final CameraDescription cameraDescription; // данные о камере
  late CameraController _controller;
  bool _isInitialized = false; // инициализированная ли камера
  final List<ScreenshotPreviewModel> _shots = []; // список миниатюр
  late final Future<void> cameraInitialized; // состояние инициализации камеры

  // Геттеры/сеттеры
  bool get isInitialized => _isInitialized;
  CameraController get controller => _controller;
  List<ScreenshotPreviewModel> get shots => _shots;

  // `cameraDescription` -  данные о камере
  StreamPageModel({required this.cameraDescription}) {
    cameraInitialized = _initializeCamera();
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
  }
}

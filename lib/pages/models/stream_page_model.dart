// ====================================================
//  Страница для просмотра стриммингого видео
//  Тут имплементировано взаимодействие с логикой, не касающейся UI
// ====================================================
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../../shared/widget/screenshot_preview.dart';

class StreamPageModel {
  final CameraDescription cameraDescription;
  late CameraController _controller;
  CameraController get controller => _controller;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  final List<ScreenshotPreviewModel> _shots = []; // список миниатюр
  late final Future<void> cameraInitialized;

  List<ScreenshotPreviewModel> get shots => _shots;

  StreamPageModel({required this.cameraDescription}) {
    cameraInitialized = _initializeCamera(cameraDescription);
  }

  Future<void> _initializeCamera(CameraDescription camera) async {
    try {
      _controller = CameraController(
        camera,
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

  void saveScreenshot(XFile file) {
    _shots.add(
      ScreenshotPreviewModel(
        file.path,
        Duration.zero /* TODO: implement stopwatch */,
      ),
    );
  }

  void dispose() {
    print('StreamPageModel disposed');

    _controller.dispose();
    _isInitialized = false;
  }
}

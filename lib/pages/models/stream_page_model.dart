// ====================================================
//  Страница для просмотра стриммингого видео
//  Тут имплементировано взаимодействие с логикой, не касающейся UI
// ====================================================
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class StreamPageModel {
  late CameraController _controller;
  CameraController get controller => _controller;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initializeCamera(CameraDescription camera) async {
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

  void dispose() {
    _controller.dispose();
    _isInitialized = false;
  }
}

// ====================================================
//  Global Camera Manager - Singleton to prevent multiple camera instances
// ====================================================

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:endoscopy_ai/shared/camera/windows_camera_helper.dart';

class CameraManager {
  static CameraManager? _instance;
  static CameraManager get instance => _instance ??= CameraManager._();

  CameraManager._();

  CameraController? _controller;
  CameraDescription? _currentCamera;
  bool _isInitializing = false;
  Completer<CameraController>? _initializationCompleter;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get isInitializing => _isInitializing;

  /// Initialize camera with the given description
  Future<CameraController> initializeCamera(
    CameraDescription cameraDescription,
  ) async {
    // If already initializing, wait for completion
    if (_isInitializing && _initializationCompleter != null) {
      return await _initializationCompleter!.future;
    }

    // If already initialized with same camera, return existing controller
    if (_controller != null &&
        _currentCamera != null &&
        _currentCamera!.name == cameraDescription.name &&
        _controller!.value.isInitialized) {
      return _controller!;
    }

    // Dispose existing controller if different camera
    if (_controller != null) {
      await disposeCamera();
    }

    _isInitializing = true;
    _initializationCompleter = Completer<CameraController>();

    try {
      if (kDebugMode) {
        print('CameraManager: Initializing camera ${cameraDescription.name}');
      }

      _controller = await WindowsCameraHelper.initializeCamera(
        cameraDescription,
        resolution: ResolutionPreset.medium,
        enableAudio: true,
      );

      _currentCamera = cameraDescription;

      if (kDebugMode) {
        print('CameraManager: Camera initialized successfully');
      }

      _initializationCompleter!.complete(_controller!);
      return _controller!;
    } catch (e) {
      if (kDebugMode) {
        print('CameraManager: Failed to initialize camera: $e');
      }

      _controller = null;
      _currentCamera = null;
      _initializationCompleter!.completeError(e);
      rethrow;
    } finally {
      _isInitializing = false;
      _initializationCompleter = null;
    }
  }

  /// Dispose current camera controller
  Future<void> disposeCamera() async {
    if (_controller != null) {
      if (kDebugMode) {
        print('CameraManager: Disposing camera');
      }

      await WindowsCameraHelper.disposeCamera(_controller);
      _controller = null;
      _currentCamera = null;
    }
  }

  /// Reset the camera manager (useful for error recovery)
  Future<void> reset() async {
    _isInitializing = false;
    _initializationCompleter = null;
    await disposeCamera();
  }
}

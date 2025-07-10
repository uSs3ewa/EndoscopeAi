// ====================================================
//  Страница для просмотра стриммингого видео
// ====================================================

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'stream_model.dart';
import 'stream_view.dart';
import 'package:endoscopy_ai/features/record_data.dart';

// Страница просмотра потокового видео с камеры
class StreamPage extends StatefulWidget {
  final CameraDescription camera; // Данные о камере
  final RecordData recordData;

  // `camera` - данные о камеры, с которой будет браться видеопоток
  const StreamPage({Key? key, required this.camera, required this.recordData})
      : super(key: key);

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  late final StreamPageModel _model;
  late final StreamPageView _view;
  bool _isModelInitialized = false;

  // Инициализация ресурсов
  @override
  void initState() {
    super.initState();

    _model = StreamPageModel(
      cameraDescription: widget.camera,
      recordData: widget.recordData,
    ); // создание модели
    _view = StreamPageView(
      // создание визуальной части
      model: _model,
      camera: widget.camera,
      onBackPressed: () => Navigator.pop(context),
      onPictureTaken: _handlePictureTaken,
    );
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      await _model.initialize();
      setState(() {
        _isModelInitialized = true;
      });
    } catch (e) {
      debugPrint('Model initialization error: $e');
      // Можно добавить обработку ошибки
    }
  }

  // Освобождение ресурсов
  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Обработка сохраненного скриншота по пути `image`
  Future<void> _handlePictureTaken(XFile image) async {
    await _model.saveScreenshot(image);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isModelInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _view;
  }
}

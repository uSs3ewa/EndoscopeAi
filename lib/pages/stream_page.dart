// ====================================================
//  Страница для просмотра стриммингого видео
// ====================================================

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'models/stream_page_model.dart';
import 'views/stream_page_view.dart';
import '../shared/widget/buttons.dart';

class StreamPlayerPage extends StatelessWidget {
  late final StreamPlayerPageModel _model;
  late final StreamPlayerPageView _view;

  StreamPlayerPage() {
    _model = StreamPlayerPageModel();
    _view = StreamPlayerPageView(_model);
// Страница просмотра потокового видео с камеры
class StreamPage extends StatefulWidget {
  final CameraDescription camera; // Данные о камере

  // `camera` - данные о камеры, с которой будет браться видеопоток
  const StreamPage({Key? key, required this.camera}) : super(key: key);

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  late final StreamPageModel _model;
  late final StreamPageView _view;

  // Инициализация ресурсов
  @override
  void initState() {
    super.initState();

    _model = StreamPageModel(
      cameraDescription: widget.camera,
    ); // создание модели
    _view = StreamPageView(
      // создание визуальной части
      model: _model,
      camera: widget.camera,
      onBackPressed: () => Navigator.pop(context),
      onPictureTaken: _handlePictureTaken,
    );
  }

  // Освобождение ресурсов
  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Обработка сохраненного скриншота по пути `image`
  void _handlePictureTaken(XFile image) {
    setState(
      () => _model.saveScreenshot(image),
    ); // добавляем в ленту скриншотов новую фотографию

    // Navigator.pushNamed(
    //   context,
    //   Routes.annotate,
    //   arguments: image.path,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return _view.build(context);
  }
}

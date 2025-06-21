// ====================================================
//  Страница для вопроизведения зяписанного видео
// ====================================================
import 'dart:io';
import 'package:flutter/material.dart';
import 'models/file_video_page_model.dart';
import 'views/file_video_page_view.dart';

// Страница с воспроизведением видео с файла
class FileVidePlayerPage extends StatefulWidget {
  const FileVidePlayerPage({super.key});

  @override
  State<FileVidePlayerPage> createState() => _FileVidePlayerPageState();
}

class _FileVidePlayerPageState extends State<FileVidePlayerPage> {
  late final _model; // бэкенд логика
  late final _view; // фронтенд логика

  _FileVidePlayerPageState() {
    _model = FileVideoPlayerPageStateModel(setState);
    _view = FileVidePlayerPageStateView(setState, _model);
  }

  @override
  void initState() {
    super.initState();

    _model.initState();

    // Обновляем позицию каждые 100 мс
    _model.controller.addListener(_updateProgress);
  }

  @override
  Widget build(BuildContext context) {
    return _view.build(context);
  }

  // Освободть ресурсы
  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Обновить состояние videoplayer
  void _updateProgress() {
    if (mounted) {
      setState(() {
        _model.currentPosition = _model.controller.value.position;
        _model.totalDuration = _model.controller.value.duration;
      });
    }
  }
}

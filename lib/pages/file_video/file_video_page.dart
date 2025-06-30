// ====================================================
//  Страница для вопроизведения зяписанного видео
// ====================================================
import 'package:flutter/material.dart';
import 'file_video_model.dart';
import 'file_video_view.dart';
import '../recordings/recordings_model.dart';
import 'package:endoscopy_ai/shared/file_choser.dart';

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

    // Добавляем запись в список записей, если файл валиден
    if (FilePicker.checkFile() && FilePicker.filePath != null) {
      final filePath = FilePicker.filePath!;
      RecordingsPageModel().addRecording(
        Recording(filePath: filePath, timestamp: DateTime.now()),
      );
    }

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

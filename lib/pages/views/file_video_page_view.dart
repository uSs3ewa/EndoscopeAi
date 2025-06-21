// ====================================================
//  Страница для вопроизведения зяписанного видео
//  Логика, содержащая логику, связанную с UI
// ====================================================
import 'package:fvp/fvp.dart' as fvp;
import 'package:namer_app/shared/utility/strings.dart';
import 'package:namer_app/shared/widget/play_pause_button.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import '../models/file_video_page_model.dart';
import '../../shared/widget/spacing.dart';
import '../../shared/widget/screenshot_preview.dart';
import '../../shared/widget/custom_slider.dart';
import '../../shared/widget/gallery_of_screenshot.dart';

//  Логика, содержащая логику, связанную с UI
class FileVidePlayerPageStateView {
  final Function setState; // callback для обновления состояния
  final FileVideoPlayerPageStateModel _model;

  FileVidePlayerPageStateView(this.setState, this._model);

  Widget _buildVideo(BuildContext context) =>
      _createGestureRecognition(context);

  // сборка пользовательского интерфейса
  Widget build(BuildContext context) {
    if (!_model.isValidFile) return _createErrorScaffold();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Видеоплеер'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            /// ВИДЕО
            _buildVideo(context),

            createIndention(),

            /// ЛЕНТА СКРИНШОТОВ
            Expanded(
              child: GalleryOfScreenshot(modelVideoPlayer: _model),
            ),
          ],
        ),
      ),
      floatingActionButton: _createScreenshotButton(),
    );
  }

  // Создание ливетирующей кнопки для скриншотов
  Widget _createScreenshotButton() {
    return FloatingActionButton(
      onPressed: _model.makeScreenshot,
      backgroundColor: const Color.fromARGB(255, 252, 232, 232),
      child: Icon(
        Icons.camera_alt,
        color: const Color.fromARGB(255, 65, 63, 63),
      ),
    );
  }

  // создание.... эээ.. чего это....
  Widget _createGestureRecognition(context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _model.showControls = !_model.showControls;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _model.controller.value.aspectRatio,
            child: VideoPlayer(_model.controller),
          ),
          if (_model.showControls) PlayPauseButton(model: _model,),
          if (_model.showControls) CustomSlider(modelVideoPlayer: _model,),
        ],
      ),
    );
  }

  // открывает окно с ошибкой
  Widget _createErrorMessageBox(AsyncSnapshot snapshot) {
    return Center(child: Text('Ошибка загрузки видео: ${snapshot.error}'));
  }

  // создает штуку, где пишутся ошибки
  Widget _createErrorScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text('Ошибка')),
      body: const Center(child: Text('Не удалось открыть файл')),
    );
  }
  }

// ====================================================
//  Страница для вопроизведения зяписанного видео
//  Логика, содержащая логику, связанную с UI
// ====================================================
import 'package:fvp/fvp.dart' as fvp;
import 'package:namer_app/shared/utility/strings.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import '../models/file_video_page_model.dart';
import '../../shared/widget/spacing.dart';
import '../../shared/widget/screenshot_preview.dart';

//  Логика, содержащая логику, связанную с UI
class FileVidePlayerPageStateView {
  final Function setState; // callback для обновления состояния
  final FileVidePlayerPageStateModel _model;

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
              child: Card(
                color: const Color.fromARGB(255, 228, 226, 226),
                child: Padding(
                  padding: EdgeInsets.all(7),
                  child: _model.shots.isEmpty
                      ? const Center(child: Text('Нет скриншотов'))
                      : ListView.builder(
                          itemCount: _model.shots.length,
                          itemBuilder: (ctx, i) => ScreenshotPreviewView(
                            model: _model.shots[i],
                            onTap: _model.seekTo,
                          ),
                        ),
                ),
              ),
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
          if (_model.showControls) _createPauseButton(),
          if (_model.showControls) _createCustomSlider(context),
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

  // создает кнопку паузы
  Widget _createPauseButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 167, 38, 29),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          _model.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
        onPressed: _model.togglePlayPause,
      ),
    );
  }

  // создает полоску прогресса в произрывателе
  Widget _createCustomSlider(BuildContext context) {
    // Полоска прогресса
    return Positioned(
      bottom: 5,
      left: 5,
      right: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                // ignore: deprecated_member_use
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.60),
                const Color.fromARGB(0, 61, 60, 60),
              ],
            ),
          ),
          child: Row(
            children: [
              Text(
                formatDuration(_model.currentPosition),
                style: TextStyle(
                  color: const Color.fromARGB(255, 221, 217, 217),
                ),
              ),
              Expanded(child: _createSlider()),
              Text(
                formatDuration(_model.totalDuration),
                style: TextStyle(
                  color: const Color.fromARGB(255, 175, 171, 171),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // просто создает слайдер?
  StatefulWidget _createSlider() {
    return Slider(
      activeColor: const Color.fromARGB(255, 167, 38, 29),
      value: _model.currentPosition.inMilliseconds.toDouble(),
      min: 0,
      max: _model.totalDuration.inMilliseconds.toDouble(),
      onChangeStart: (_) {
        if (!_model.isPlaying) _model.controller.pause();
      },
      onChangeEnd: (_) {
        if (_model.isPlaying) _model.controller.play();
      },
      onChanged: (value) {
        setState(() {
          _model.currentPosition = Duration(milliseconds: value.toInt());
          _model.controller.seekTo(_model.currentPosition);
        });
      },
    );
  }
}

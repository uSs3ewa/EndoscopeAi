import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:screenshot/screenshot.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:image/image.dart' as img;

import 'fileChoser.dart';

class FileVideoApp extends StatefulWidget {
  const FileVideoApp({super.key});

  @override
  State<FileVideoApp> createState() => _FileVideoAppState();
}

class _FileVideoAppState extends State<FileVideoApp> {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  bool _showControls = false;
  bool _isValidFile = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late ScreenshotController _screenshotController;

  @override
  void initState() {
    super.initState();

    if (FilePicker.checkFile()) {
      _isValidFile = true;
      _screenshotController = ScreenshotController();
      _controller =
          VideoPlayerController.file(File(FilePicker.filePath.toString()))
            ..initialize().then((_) {
              setState(() {
                _totalDuration = _controller.value.duration;
              });
              // Обновляем позицию каждые 100 мс
              _controller.addListener(_updateProgress);
            });

      _initializeVideoPlayerFuture = _controller
          .initialize()
          .catchError((error) {
            debugPrint('Ошибка инициализации видео: $error');
          });
    }
  }

  void _updateProgress() {
    if (mounted) {
      setState(() {
        _currentPosition = _controller.value.position;
        _totalDuration = _controller.value.duration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidFile) {
      return Center(
        child: Screenshot(
          controller: _screenshotController,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Видеоплеер'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            floatingActionButton: getScreenshotButton(),
            body: Center(
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      getErrorMessage(snapshot);
                    }
                    return getGestureRecognition();
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
          ),
        ),
        body: const Text('Ошибка во время открытия файла'),
      );
    }
  }

  Widget getGestureRecognition() {
    return GestureDetector(
      onTap: () {
        setState(() {_showControls = !_showControls;}
        );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
              ),
              if (_showControls || !_isPlaying) getPauseButton(),
              if (_showControls || !_isPlaying) getCustomSlider(context),
              ],
              )
              );
  }

  Widget getErrorMessage(AsyncSnapshot snapshot) {
    return Center(
      child: Text('Ошибка загрузки видео: ${snapshot.error}'
      ),
      );
  }

  Widget getPauseButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 167, 38, 29),
        shape: BoxShape.circle,),
        child: IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,color: Colors.white,
          size: 40,
          ),
          onPressed: _togglePlayPause,)
          ,);
  }

  Widget getScreenshotButton() {
    return FloatingActionButton(
              onPressed: _makeScreenshot,
              backgroundColor: const Color.fromARGB(255, 252, 232, 232),
              child: Icon(
                Icons.camera_alt,
                color: const Color.fromARGB(255, 65, 63, 63),
              ),
            );
  }

  Widget getCustomSlider(BuildContext context){ // Полоска прогресса
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          ),
          child: Row(
            children: [
              Text(_formatDuration(_currentPosition)),
              Expanded(
                child: getSlider(),
                              ),
                              Text(_formatDuration(_totalDuration)),
                              ],
                              ),
                              ),
                              );
  }

  Widget getSlider(){
    return Slider(
      activeColor: const Color.fromARGB(255, 167, 38, 29,),
      value: _currentPosition.inMilliseconds.toDouble(),
      min: 0,
      max: _totalDuration.inMilliseconds.toDouble(),
      onChangeStart: (_) {if (!_isPlaying) _controller.pause();},
      onChangeEnd: (_) {if (_isPlaying) _controller.play();},
      onChanged: (value) {
        setState(() {
        _currentPosition = Duration(milliseconds: value.toInt(),);
        _controller.seekTo(_currentPosition,);
        });
        },
        );
  }

  void _makeScreenshot() async {
    final width = _controller.getMediaInfo()!.video![0].codec.width;
    final height = _controller.getMediaInfo()!.video![0].codec.height;

    await _controller.snapshot(width: width, height: height).then((pixelData) {
      if (pixelData == null) {
        print('Ой, что-то пошло не так в сохранения снимка');
      } else {
        final image = img.Image.fromBytes(
          width: width,
          height: height,
          bytes: pixelData.buffer,
          // According to https://pub.dev/documentation/fvp/latest/fvp/FVPControllerExtensions/snapshot.html :
          // rowStride: 4,
          numChannels: 4,
        );

        final directory = Directory.current;
        final filePath =
            '${directory.path}/data/screenshots/screenshot.png'; // Создайте имя файла // TODO: добавить реализацию отслеживания количества созданных скриншотов, для этого нужно создать отдельную функцию

        img.encodePngFile(filePath, image);
        print("Сохранено $filePath");
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller.play() : _controller.pause();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
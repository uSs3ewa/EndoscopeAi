import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:screenshot/screenshot.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';


import 'fileChoser.dart';

class FileVideoApp extends StatefulWidget {
  const FileVideoApp({super.key});

  @override
  State<FileVideoApp> createState() => _FileVideoAppState();
}
class _Shot {
  final String path;          // путь к PNG
  final Duration position;    // время, где сделан кадр

  _Shot(this.path, this.position);
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
  final List<_Shot> _shots = [];   // список миниатюр
  late Directory _shotsDir;        // директория …/screenshots

  @override
  void initState() {
    super.initState();
    _prepareDir();  
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
  Future<void> _prepareDir() async {
  final base = await getApplicationDocumentsDirectory();   // path_provider
  _shotsDir = Directory('${base.path}/screenshots');
  if (!await _shotsDir.exists()) {
    await _shotsDir.create(recursive: true);
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
void _seekTo(Duration pos) {
  _controller.seekTo(pos);
  if (_isPlaying) _togglePlayPause();   // если было включено - поставим на паузу
}

Widget _buildVideo() => getGestureRecognition();
@override
Widget build(BuildContext context) {
  if (!_isValidFile) return _errorScaffold();

  return Scaffold(
    floatingActionButton: getScreenshotButton(),
    appBar: AppBar(
      title: const Text('Видеоплеер'),
      leading: BackButton(onPressed: () => Navigator.pop(context)),
    ),
    body: Row(
      children: [
        /// ВИДЕО (растягивается)
        Expanded(child: _buildVideo()),
        /// ЛЕНТА СКРИНШОТОВ
        Container(
          width: 120,
          color: Colors.black12,
          child: _shots.isEmpty
              ? const Center(child: Text('Нет скриншотов'))
              : ListView.builder(
                  itemCount: _shots.length,
                  itemBuilder: (ctx, i) => _Scrin(shot: _shots[i], onTap: _seekTo),
                ),
        ),
      ],
    ),
  );
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
  Widget _errorScaffold() {
  return Scaffold(
    appBar: AppBar(title: const Text('Ошибка')),
    body: const Center(child: Text('Не удалось открыть файл')),
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

    await _controller.snapshot(width: width, height: height).then((pixelData) async {
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

        final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        final filePath = '${_shotsDir.path}/$fileName';
        // СОХРАНЯЕМ В ФАЙЛ
        final pngBytes = img.encodePng(image);
        final outFile = File(filePath);
        await outFile.writeAsBytes(pngBytes);

        // ДИАГНОСТИКА
        print('Файл записан: $filePath');
        print('Существует? ${outFile.existsSync()}');

       setState(() {
        _shots.add(_Shot(filePath, _controller.value.position));
      });
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

class _Scrin extends StatelessWidget {
  const _Scrin({
    Key? key,
    required this.shot,
    required this.onTap,
  }) : super(key: key);

  final _Shot shot;
  final void Function(Duration) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        elevation: 1,                       // лёгкая «тень» карточки
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,       // обрезаем по радиусу
        child: InkWell(
          onTap: () => onTap(shot.position),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              //миниатюра
              AspectRatio(                   // фиксированное соотношение сторон (16:9)
                aspectRatio: 16 / 9,
                child: Image.file(
                  File(shot.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              // лёгкий градиент для читаемости текста 
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.60),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // тайм-код
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  _hhmmss(shot.position),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 1, offset: Offset(0, 0))],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // helper
  String _hhmmss(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return d.inHours > 0
        ? '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}'
        : '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}




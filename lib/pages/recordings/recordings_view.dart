import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'recordings_model.dart';
import 'package:path/path.dart' as p;

class RecordingsPageView extends StatefulWidget {
  final RecordingsPageModel model;
  final VoidCallback refresh;

  RecordingsPageView({required this.model, required this.refresh});

  @override
  _RecordingsPageViewState createState() => _RecordingsPageViewState();
}

class _RecordingsPageViewState extends State<RecordingsPageView> {
  bool _editMode = false;
  Set<String> _selectedPaths = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recording>>(
      future: widget.model.getRecordings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки записей'));
        }

        final recordings = snapshot.data ?? [];

        return Column(
          children: [
            Expanded(
              child: recordings.isEmpty
                  ? Center(child: Text('Нет записей'))
                  : ListView.builder(
                      itemCount: recordings.length,
                      itemBuilder: (context, index) =>
                          _buildRecordingItem(context, recordings[index]),
                    ),
            ),
            if (_editMode && _selectedPaths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.delete),
                      label: Text('Удалить выбранные'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        final toDelete = recordings
                            .where((r) => _selectedPaths.contains(r.filePath))
                            .toList();
                        await widget.model.deleteRecordings(toDelete);
                        setState(() {
                          _selectedPaths.clear();
                          _editMode = false;
                        });
                        widget.refresh();
                      },
                    ),
                  ],
                ),
              ),
            _buildActionButtons(context),
          ],
        );
      },
    );
  }

  Widget _buildRecordingItem(BuildContext context, Recording recording) {
    final displayName =
        (recording.fileName != null && recording.fileName.isNotEmpty)
            ? recording.fileName
            : 'Запись ${recording.timestamp.toString()}';
    if (_editMode) {
      return CheckboxListTile(
        value: _selectedPaths.contains(recording.filePath),
        onChanged: (selected) {
          setState(() {
            if (selected == true) {
              _selectedPaths.add(recording.filePath);
            } else {
              _selectedPaths.remove(recording.filePath);
            }
          });
        },
        title: Text(displayName),
        subtitle: Text(recording.filePath),
        secondary: Icon(Icons.video_library, size: 40),
      );
    }
    return ListTile(
      leading: Icon(Icons.video_library, size: 40),
      title: Text(displayName),
      subtitle: Text(recording.filePath),
      trailing: Icon(Icons.play_arrow),
      onTap: () => _playVideo(context, recording.filePath),
      onLongPress: () {
        setState(() {
          _editMode = true;
          _selectedPaths.add(recording.filePath);
        });
      },
    );
  }

  void _playVideo(BuildContext context, String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(filePath: filePath),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.videocam),
            label: Text('Сделать запись'),
            onPressed: () {
              Navigator.pushNamed(context, '/streamVideoPlayer');
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          SizedBox(width: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.video_library),
            label: Text('Импортировать видео'),
            onPressed: () => _importVideo(context),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          SizedBox(width: 20),
          ElevatedButton.icon(
            icon: Icon(_editMode ? Icons.close : Icons.edit),
            label: Text(_editMode ? 'Отмена' : 'Редактировать'),
            onPressed: () {
              setState(() {
                if (_editMode) {
                  _editMode = false;
                  _selectedPaths.clear();
                } else {
                  _editMode = true;
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _editMode ? Colors.grey : Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordingOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Создать запись'),
        content: Text('Выберите способ создания записи'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _importVideo(context);
            },
            child: Text('Импортировать видео'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Запись с камеры будет реализована в будущем'),
                ),
              );
            },
            child: Text('Запись с камеры'),
          ),
        ],
      ),
    );
  }

  Future<void> _importVideo(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.single.path!;
        final fileName = p.basename(filePath);
        await widget.model.addRecording(
          Recording(
            filePath: filePath,
            timestamp: DateTime.now(),
            fileName: fileName,
          ),
        );
        widget.refresh();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка импорта: $e')));
    }
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String filePath;

  VideoPlayerScreen({required this.filePath});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _controller = VideoPlayerController.file(File(widget.filePath));
    await _controller.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Воспроизведение записи')),
      body: Center(
        child: _isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    if (!_isPlaying)
                      IconButton(
                        icon: Icon(Icons.play_arrow, size: 60),
                        color: Colors.white,
                        onPressed: _togglePlay,
                      ),
                  ],
                ),
              )
            : CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePlay,
        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

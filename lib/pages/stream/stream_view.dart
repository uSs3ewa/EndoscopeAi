// ====================================================
//  Страница для просмотра стриммингого видео
//  Тут имплементировано взаимодействие с UI
// ====================================================
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:endoscopy_ai/shared/widget/screenshot_feed.dart';
import 'package:endoscopy_ai/shared/widget/spacing.dart';
import 'package:provider/provider.dart';
import 'package:endoscopy_ai/pages/stream/stream_model.dart';

import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';

//  Логика, содержащая логику, связанную с UI
class StreamPageView extends StatefulWidget {
  final StreamPageModel model;
  final CameraDescription camera; // Данные о камере

  // Ф-ия, вызываемая при нажатии на кнопку назад
  final VoidCallback onBackPressed;
  // Ф-ия, вызываемая при сохранении фотографии
  final Function(XFile) onPictureTaken;

  /*
    * `model` - модель с т��кущей страницы
    * `camera` - данные о камере, с которой будет браться видеопоток
    * `onBackPressed` - ф-ия, вызываемая при нажатии на кнопку назад
    * `onPictureTaken` - ф-ия вызываемая после сохрания изображения
  */
  const StreamPageView({
    Key? key,
    required this.model,
    required this.camera,
    required this.onBackPressed,
    required this.onPictureTaken,
  }) : super(key: key);

  @override
  _StreamPageViewState createState() => _StreamPageViewState();
}

class _StreamPageViewState extends State<StreamPageView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.model,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Поток с камеры'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBackPressed,
          ),
          actions: [
            // WebSocket connection status indicator
            Consumer<StreamPageModel>(
              builder: (context, model, child) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        model.websocketConnected ? Icons.mic : Icons.mic_off,
                        color: model.websocketConnected
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'STT',
                        style: TextStyle(
                          color: model.websocketConnected
                              ? Colors.green
                              : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<StreamPageModel>(
          builder: (context, model, child) {
            return Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (model.isInitialized && model.controller != null) {
                            return CameraPreview(model.controller!);
                          } else if (!model.cameraAvailable) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.videocam_off, size: 50),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Камера недоступна',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  const Text(
                                    'Попробуйте проверить подключение',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await model.reinitializeCamera();
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Повторить попытку'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Инициализация камеры...'),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    createIndention(),
                    Expanded(
                      child: Column(
                        children: [
                          ScreenshotFeed(onFetchScreenshots: () => model.shots),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Распознанная речь:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    const Divider(),
                                    Expanded(
                                      child:
                                          Consumer<StreamPageModel>(
                                        builder: (context, model, child) {
                                          if (model.transcripts.isEmpty) {
                                            return const Center(
                                              child: Text(
                                                'Ожидание речи...',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            );
                                          }
                                          return ListView.builder(
                                            itemCount: model.transcripts.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0),
                                                child: Text(
                                                  model.transcripts[index],
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Субтитры поверх видео
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 32,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: model.currentSubtitle.isNotEmpty ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          model.currentSubtitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        // Решение для FloatingActionButton:
        // Используем Builder и Consumer для условного отображения
        floatingActionButton: Builder(
          builder: (context) {
            final model = Provider.of<StreamPageModel>(context, listen: true);
            if (!model.isInitialized || model.controller == null)
              return const SizedBox.shrink();
            final buttons = <Widget>[
              FloatingActionButton(
                heroTag: 'shot_btn',
                onPressed: () async {
                  final image = await model.takePicture();
                  if (image != null) {
                    widget.onPictureTaken(image);
                  }
                },
                child: const Icon(Icons.camera_alt),
              ),
            ];

            void addSpace() => buttons.add(const SizedBox(height: 8));

            if (!model.recording) {
              addSpace();
              buttons.add(
                FloatingActionButton.extended(
                  heroTag: 'start_rec_btn',
                  icon: const Icon(Icons.fiber_manual_record),
                  label: const Text('Начать видеозапись'),
                  backgroundColor: Colors.red,
                  onPressed: () async {
                    await model.startRecording();
                  },
                ),
              );
            } else {
              addSpace();
              buttons.add(
                FloatingActionButton.extended(
                  heroTag: 'finish_rec_btn',
                  icon: const Icon(Icons.stop),
                  label: const Text('Завершить запись'),
                  backgroundColor: Colors.red,
                  onPressed: () async {
                    final recordedPath = await model.stopRecording();
                    if (recordedPath == null) return;
                    final savePath = await FilePicker.platform.saveFile(
                      dialogTitle: 'Сохранить видео',
                      fileName: p.basename(recordedPath),
                      type: FileType.custom,
                      allowedExtensions: ['mp4'],
                    );
                    String finalPath = recordedPath;
                    if (savePath != null) {
                      final normalized = savePath.toLowerCase().endsWith('.mp4')
                          ? savePath
                          : '$savePath.mp4';
                      await File(recordedPath).copy(normalized);
                      finalPath = normalized;
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Сохранено в "$finalPath"')),
                      );
                    }
                  },
                ),
              );
            }

            return Column(mainAxisSize: MainAxisSize.min, children: buttons);
          },
        ),
      ),
    );
  }
}

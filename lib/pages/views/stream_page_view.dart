// ====================================================
//  Страница для просмотра стриммингого видео
//  Тут имплементировано взаимодействие с UI
// ====================================================
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/shared/widget/screenshot_feed.dart';
import 'package:namer_app/shared/widget/spacing.dart';
import '../models/stream_page_model.dart';

class StreamPageView extends StatelessWidget {
  final StreamPageModel model;
  final CameraDescription camera; // Данные о камере

  // Ф-ия, вызываемая при нажатии на кнопку назад

  final VoidCallback onBackPressed;
  // Ф-ия, вызываемая при сохранении фотографии
  final Function(XFile) onPictureTaken;

  /*
    * `model` - модель с текущей страницы
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поток с камеры'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackPressed,
        ),
      ),
      body: Row(
        children: [
          // Камера
          FutureBuilder(
            future: model.cameraInitialized,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (model.isInitialized) {
                  return CameraPreview(model.controller);
                } else {
                  return const Center(
                    child: Text('Ошибка инициализации камеры'),
                  );
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),

          // Отступ
          createIndention(),

          // Лента скриншотов
          ScreenshotFeed(onFetchScreenshots: () => model.shots),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final image = await model.takePicture();
          if (image != null) {
            onPictureTaken(image);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

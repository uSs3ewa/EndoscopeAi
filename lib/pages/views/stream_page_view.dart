// ====================================================
//  Страница для просмотра стриммингого видео
//  Тут имплементировано взаимодействие с UI
// ====================================================
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:endoscopy_ai/shared/widget/screenshot_feed.dart';
import 'package:endoscopy_ai/shared/widget/spacing.dart';
import 'package:provider/provider.dart';
import 'package:endoscopy_ai/pages/models/stream_page_model.dart';
import 'package:endoscopy_ai/shared/widget/buttons.dart';

//  Логика, содержащая логику, связанную с UI
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

  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StreamPageModel(cameraDescription: camera),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Поток с камеры'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackPressed,
          ),
        ),
        body: Consumer<StreamPageModel>(
          builder: (context, model, child) {
            return Row(
              children: [
                Expanded(
                  child: FutureBuilder(
                    future: model.cameraInitialized,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (model.isInitialized) {
                          return CameraPreview(model.controller);
                        }
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam_off, size: 50),
                              SizedBox(height: 16),
                              Text(
                                'Камера недоступна',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                'Попробуйте проверить подключение',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }
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
                    },
                  ),
                ),
                createIndention(),
                ScreenshotFeed(onFetchScreenshots: () => model.shots),
              ],
            );
          },
        ),
        // Решение для FloatingActionButton:
        // Используем Builder и Consumer для условного отображения
        floatingActionButton: Builder(
          builder: (context) {
            final model = Provider.of<StreamPageModel>(context, listen: true);
            return model.isInitialized
                ? FloatingActionButton(
                    onPressed: () async {
                      final image = await model.takePicture();
                      if (image != null) {
                        onPictureTaken(image);
                      }
                    },
                    child: const Icon(Icons.camera_alt),
                  )
                : const SizedBox.shrink(); // Возвращаем пустой виджет вместо null
          },
        ),
      ),
    );
  }
}

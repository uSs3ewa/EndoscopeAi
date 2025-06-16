// ====================================================
//  Страница для просмотра стриммингого видео
//  Тут имплементировано взаимодействие с UI
// ====================================================
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/stream_page_model.dart';

class StreamPageView extends StatelessWidget {
  final StreamPageModel model;
  final CameraDescription camera;
  final VoidCallback onBackPressed;
  final Function(XFile) onPictureTaken;

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
      body: FutureBuilder(
        future: model.initializeCamera(camera),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (model.isInitialized) {
              return CameraPreview(model.controller);
            } else {
              return const Center(child: Text('Ошибка инициализации камеры'));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
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
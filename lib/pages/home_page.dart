// ====================================================
//  Главное окно для выбора режима: запись, просмотр, импорт
// ====================================================
import 'package:flutter/material.dart';

import '../routes.dart';
import '../shared/file_choser.dart';
import '../shared/widget/buttons.dart';
import '../shared/widget/spacing.dart';

// Страница начального окна
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная страница')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _createStreamVideoPlayerButton(context),
            createIndention(),
            _createVideoPlayerButton(context),
            createIndention(),
            _createRecordingsButton(context),
          ],
        ),
      ),
    );
  }

  // Импорт
  Widget _createVideoPlayerButton(context) {
    return ElevatedButton(
      onPressed: () async {
        FilePicker.pickFile()
            .then((_) {
              Navigator.pushNamed(context, Routes.fileVideoPlayer);
            })
            .onError(
              (error, tr) => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Ошибка открытия файла'),
                  content: Text('$error'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Ok'),
                    ),
                  ],
                ),
              ),
            );
      },
      child: const Text('Открыть видеоплеер'),
    );
  }

  // Запись
  Widget _createRecordingsButton(context) {
    return createRedirectButton(
      context,
      'Открыть видеозаписи',
      Routes.recordings,
    );
  }

  // Просмотр
  Widget _createStreamVideoPlayerButton(context) {
    return createRedirectButton(
      context,
      'Открыть стриминговый плеер',
      Routes.streamVideoPlayer,
    );
  }
}

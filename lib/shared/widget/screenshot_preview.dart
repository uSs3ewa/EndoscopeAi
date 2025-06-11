// ====================================================
//  Файл содержит ui для отобрадения скриншота
// ====================================================
import 'package:flutter/material.dart';
import 'dart:io';

// Состояние, определяющее степень загрузки миниатюры
enum ScreenshotPreviewState { good, pending, error }

// Модель с данными о превьюшки камшота
class ScreenshotPreviewModel {
  final String path; // путь к PNG
  final Duration position; // время, где сделан кадр
  ScreenshotPreviewState state; // состояние загрузки

  ScreenshotPreviewModel(
    this.path,
    this.position, {
    this.state = ScreenshotPreviewState.good,
  });
}

// UI превьюшка миниатюры скриншоты
class ScreenshotPreviewView extends StatelessWidget {
  /* 
   * `model` - модель с данными о миниатюре
   * `onTab` - действие при нажатии
  */
  const ScreenshotPreviewView({
    super.key,
    required this.model,
    required this.onTap,
  });

  final ScreenshotPreviewModel model;
  final void Function(Duration) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        elevation: 1, // лёгкая «тень» карточки
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias, // обрезаем по радиусу
        child: InkWell(
          onTap: () => onTap(model.position),
          child: _createMinimalisticPreview(),
        ),
      ),
    );
  }

  // Создать миниатюру
  Widget _createMinimalisticPreview() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        //миниатюра
        AspectRatio(
          // фиксированное соотношение сторон (16:9)
          aspectRatio: 16 / 9,
          child: _createPreview(),
        ),
        // лёгкий градиент для читаемости текста
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.60), Colors.transparent],
              ),
            ),
          ),
        ),
        // тайм-код
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            _hhmmss(model.position),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 1, offset: Offset(0, 0))],
            ),
          ),
        ),
      ],
    );
  }

  // Создать изображение
  Widget _createPreview() {
    switch (model.state) {
      case ScreenshotPreviewState.good: // Изображение успешно згрузилось
        return Image.file(
          File(model.path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      case ScreenshotPreviewState.pending: // Изображение все еще загружается
        return SizedBox.square(
          dimension: 5,
          child: CircularProgressIndicator(),
        );
      case ScreenshotPreviewState.error: // Ошибка загрузки
        // TODO: Handle this case.
        throw Icon(Icons.error, color: Colors.red);
    }
  }

  // Перевод duration в строку
  String _hhmmss(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return d.inHours > 0
        ? '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}'
        : '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}

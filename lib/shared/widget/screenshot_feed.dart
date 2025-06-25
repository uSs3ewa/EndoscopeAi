// ====================================================
//  Виджет ленты просмотра скриншотов
// ====================================================

import 'package:flutter/material.dart';
import 'package:endoscopy_ai/shared/widget/screenshot_preview.dart';

class ScreenshotFeed extends StatelessWidget {
  late List<ScreenshotPreviewModel>
  _screenshotsCache; // ссылка на текущий список скриншотов
  late final List<ScreenshotPreviewModel> Function()
  _fetchScreenshots; // ф-ия для загрузки скриншотов
  late final Function(Duration) _onTap; // обратный вызов при нажатии

  /*
    * `onFetchScreenshots` - ф-ия для загрузки скриншотов
    * `onTap` - ф-ия, вызываемая, при нажатии
  */
  ScreenshotFeed({
    required List<ScreenshotPreviewModel> Function() onFetchScreenshots,
    super.key,
    Function(Duration)? onTap,
  }) {
    _fetchScreenshots = onFetchScreenshots;
    _onTap = onTap ?? (_) {};
  }

  @override
  Widget build(BuildContext context) {
    _screenshotsCache = _fetchScreenshots(); // загружаем скриншоты

    return Expanded(
      child: Card(
        color: const Color.fromARGB(255, 228, 226, 226),
        child: Padding(
          padding: EdgeInsets.all(7),
          child: _screenshotsCache.isEmpty
              ? const Center(child: Text('Нет скриншотов'))
              : ListView.builder(
                  itemCount: _screenshotsCache.length,
                  itemBuilder: (ctx, i) => ScreenshotPreviewView(
                    model: _screenshotsCache[i],
                    onTap: _onTap,
                  ),
                ),
        ),
      ),
    );
  }
}

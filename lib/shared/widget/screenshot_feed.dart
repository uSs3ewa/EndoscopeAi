import 'package:namer_app/shared/widget/screenshot_preview.dart';
import 'package:flutter/material.dart';

class ScreenshotFeed extends StatelessWidget {
  late List<ScreenshotPreviewModel> _screenshotsCache;
  late final List<ScreenshotPreviewModel> Function() _fetchScreenshots;
  late final Function(Duration) _onTap;

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
    _screenshotsCache = _fetchScreenshots();

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

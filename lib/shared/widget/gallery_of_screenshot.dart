import 'package:flutter/material.dart';
import 'package:namer_app/pages/models/file_video_page_model.dart';
import 'package:namer_app/shared/widget/screenshot_preview.dart';

class GalleryOfScreenshot extends StatelessWidget{
  final FileVideoPlayerPageStateModel modelVideoPlayer;

  GalleryOfScreenshot({
    required this.modelVideoPlayer,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
                color: const Color.fromARGB(255, 228, 226, 226),
                child: Padding(
                  padding: EdgeInsets.all(7),
                  child: modelVideoPlayer.shots.isEmpty
                      ? const Center(child: Text('Нет скриншотов'))
                      : ListView.builder(
                          itemCount: modelVideoPlayer.shots.length,
                          itemBuilder: (ctx, i) => ScreenshotPreviewView(
                            model: modelVideoPlayer.shots[i],
                            onTap: modelVideoPlayer.seekTo,
                          ),
                        ),
                ),
              );
  }
}
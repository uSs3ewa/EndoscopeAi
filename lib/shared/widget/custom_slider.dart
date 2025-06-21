import 'package:flutter/material.dart';
import 'package:namer_app/pages/models/file_video_page_model.dart';
import 'package:namer_app/shared/widget/slider.dart';
import '../../shared/utility/strings.dart';

class CustomSlider extends StatelessWidget{
  final FileVideoPlayerPageStateModel modelVideoPlayer;

  const CustomSlider({
    required this.modelVideoPlayer,
    });

  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 5,
      right: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.60),
                const Color.fromARGB(0, 61, 60, 60),
              ],
            ),
          ),
          child: Row(
            children: [
              Text(
                formatDuration(modelVideoPlayer.currentPosition),
                style: TextStyle(
                  color: const Color.fromARGB(255, 221, 217, 217),
                ),
              ),
              Expanded(child: getSlider()),
              Text(
                formatDuration(modelVideoPlayer.totalDuration),
                style: TextStyle(
                  color: const Color.fromARGB(255, 175, 171, 171),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  StatefulWidget getSlider() {
    return CustomSliderWithMarks(
      currentPosition: modelVideoPlayer.currentPosition,
      totalDuration: modelVideoPlayer.totalDuration,
      shots: modelVideoPlayer.shots,
      modelVideoPlayer: this.modelVideoPlayer,
    );
  }
}
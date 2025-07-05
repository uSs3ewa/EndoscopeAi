import 'package:flutter/services.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class MockVideoPlayerPlatform extends VideoPlayerPlatform {
  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async => 1;

  @override
  Future<void> dispose(int textureId) async {}

  @override
  Future<void> initVideo(int textureId) async {}

  @override
  Future<void> pause(int textureId) async {}

  @override
  Future<void> play(int textureId) async {}

  @override
  Future<Duration> getPosition(int textureId) async => Duration.zero;

  @override
  Future<void> seekTo(int textureId, Duration position) async {}

  @override
  Future<void> setLooping(int textureId, bool looping) async {}

  @override
  Future<void> setVolume(int textureId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {}

  @override
  Future<Duration> getDuration(int textureId) async => Duration(seconds: 60);

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) => 
      Stream.value(VideoEvent(
        eventType: VideoEventType.initialized,
        duration: Duration(seconds: 60),
        size: Size(1920, 1080),
      ));
}
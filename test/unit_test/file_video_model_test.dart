import 'package:flutter_test/flutter_test.dart';
import 'timecode_sync_test.dart' show FakeVideoPlayerModel;

void main() {
  test('togglePlayPause toggles state', () {
    final model = FakeVideoPlayerModel([]);
    expect(model.isPlaying, isFalse);
    model.togglePlayPause();
    expect(model.isPlaying, isTrue);
    model.togglePlayPause();
    expect(model.isPlaying, isFalse);
  });

  test('seekTo pauses when playing', () {
    final model = FakeVideoPlayerModel([]);
    model.togglePlayPause();
    expect(model.isPlaying, isTrue);
    model.seekTo(const Duration(seconds: 2));
    expect(model.isPlaying, isFalse);
    expect(model.controllerFake.lastPosition, const Duration(seconds: 2));
  });
}

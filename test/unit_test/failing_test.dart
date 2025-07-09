import 'package:flutter_test/flutter_test.dart';
// reuse the fake model defined for widget tests
import '../widget_test/timecode_sync_test.dart' show FakeVideoPlayerModel;

void main() {
  test('video starts playing automatically', () {
    final model = FakeVideoPlayerModel([]);

    // Correct: newly created model should not be playing initially
    expect(model.isPlaying, isTrue);
  }, tags: 'failing');
}

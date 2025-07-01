import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:endoscopy_ai/shared/widget/markers_model.dart';
import 'package:endoscopy_ai/shared/widget/screenshot_preview.dart';
import '../test/timecode_sync_test.dart' show FakeVideoPlayerModel;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('drag updates position', (tester) async {
    final key = GlobalKey();
    final model = FakeVideoPlayerModel([])
      ..totalDuration = const Duration(seconds: 10);
    final markers = MarkersModel(
      0,
      0,
      sliderKey: key,
      modelVideoPlayer: model,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(width: 100, height: 20, key: key),
      ),
    );

    final box = key.currentContext!.findRenderObject() as RenderBox;
    final sliderWidth = box.size.width;
    final totalMs = model.totalDuration.inMilliseconds.toDouble();
    final dx = (5 * 1000 / totalMs) * sliderWidth; // drag to 5s
    final global = box.localToGlobal(Offset(dx, 1));

    markers.dragSlider(DragUpdateDetails(globalPosition: global));

    expect(model.currentPosition, const Duration(seconds: 5));
    expect(model.controllerFake.lastPosition, const Duration(seconds: 5));
  });
}

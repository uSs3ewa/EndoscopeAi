import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:endoscopy_ai/shared/widget/screenshot_preview.dart';

void main() {
  test('model default state is good', () {
    final model = ScreenshotPreviewModel('path', Duration.zero);
    expect(model.state, ScreenshotPreviewState.good);
  });

  testWidgets('pending state shows progress', (tester) async {
    final tempFile = File('${Directory.systemTemp.path}/temp.png');
    await tempFile.writeAsBytes(List.filled(10, 0));
    final model = ScreenshotPreviewModel(tempFile.path, Duration.zero,
        state: ScreenshotPreviewState.pending);
    await tester.pumpWidget(MaterialApp(
      home: ScreenshotPreviewView(
        model: model,
        onTap: (_) {},
      ),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tempFile.delete();
  });
}

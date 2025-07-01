import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:endoscopy_ai/shared/widget/screenshot_preview.dart';
import 'package:endoscopy_ai/routes.dart';

class TestObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushed = [];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
  }
}

void main() {
  testWidgets('double tap opens annotate route', (tester) async {
    final tempFile = File('${Directory.systemTemp.path}/temp2.png');
    await tempFile.writeAsBytes(List.filled(10, 0));
    final observer = TestObserver();
    await tester.pumpWidget(MaterialApp(
      navigatorObservers: [observer],
      routes: {Routes.annotate: (context) => const Text('annotated')},
      home: ScreenshotPreviewView(
        model: ScreenshotPreviewModel(tempFile.path, Duration.zero),
        onTap: (_) {},
      ),
    ));

    await tester.tap(find.byType(ScreenshotPreviewView));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(ScreenshotPreviewView));
    await tester.pumpAndSettle();

    expect(observer.pushed.any((r) => r.settings.name == Routes.annotate), isTrue);
    await tempFile.delete();
  });
}

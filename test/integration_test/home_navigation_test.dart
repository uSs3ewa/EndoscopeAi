import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:endoscopy_ai/pages/home/home_page.dart';
import 'package:endoscopy_ai/pages/recordings/recordings_page.dart';
import 'package:endoscopy_ai/routes.dart';

void main() {
  testWidgets('navigate to recordings page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: Routes.homePage,
      routes: {
        Routes.homePage: (context) => const HomePage(),
        Routes.recordings: (context) => RecordingsPage(),
      },
    ));

    await tester.tap(find.text('Открыть видеоплеер'));
    await tester.pumpAndSettle();

    expect(find.byType(RecordingsPage), findsOneWidget);
  });
}

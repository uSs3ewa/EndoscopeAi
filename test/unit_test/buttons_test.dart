import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:endoscopy_ai/shared/widget/buttons.dart';

void main() {
  testWidgets('createRedirectButton enabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => createRedirectButton(
            context,
            'Go',
            '/next',
          ),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('createRedirectButton disabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => createRedirectButton(
            context,
            'Go',
            '/next',
            disable: true,
          ),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}

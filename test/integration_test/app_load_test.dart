import 'package:flutter_test/flutter_test.dart';
import 'package:endoscopy_ai/app.dart';

void main() {
  testWidgets('app builds', (tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}

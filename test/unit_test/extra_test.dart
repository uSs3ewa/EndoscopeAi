import 'package:flutter_test/flutter_test.dart';
import 'package:endoscopy_ai/shared/utility/strings.dart';

void main() {
  test('formatDuration zero', () {
    expect(formatDuration(Duration.zero), equals('00:00'));
  });
}

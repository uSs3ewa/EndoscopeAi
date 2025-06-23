import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('file saved to selected location', () async {
    final dir = await Directory.systemTemp.createTemp('save_test');
    final path = '${dir.path}/out.txt';
    final file = File(path);
    await file.writeAsString('data');

    expect(file.existsSync(), isTrue);

    await dir.delete(recursive: true);
  });
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SttService {
  final String scriptPath;
  Process? _process;
  StreamController<String>? _controller;

  SttService(this.scriptPath);

  Stream<String> get stream => _controller!.stream;

  Future<void> start(String transcriptPath) async {
    _controller = StreamController<String>.broadcast();
    final python = Platform.isWindows ? 'python' : 'python3';
    _process = await Process.start(python, [scriptPath, '--output', transcriptPath]);
    _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          final text = line.trim();
          if (text.isNotEmpty) {
            _controller?.add(text);
          }
        }, onError: (e) {
          _controller?.addError(e);
        });
    _process!.stderr.transform(utf8.decoder).listen((err) {
      _controller?.addError(err);
    });
  }

  Future<void> stop() async {
    _process?.kill();
    await _controller?.close();
  }
}

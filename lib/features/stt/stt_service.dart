import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:web_socket_channel/web_socket_channel.dart';

class SttService {
  WebSocketChannel? _channel;
  StreamController<String>? _controller;
  Process? _process;

  SttService();

  Stream<String> get stream => _controller!.stream;

  Future<void> start(String transcriptPath) async {
    _controller = StreamController<String>.broadcast();

    // 1. Start the Python server
    try {
      final pythonExecutable = Platform.isWindows ? 'python' : 'python3';
      final scriptPath = p.join(Directory.current.path, 'python', 'whisper_server.py');
      _process = await Process.start(pythonExecutable, [scriptPath]);

      // Log stdout and stderr for debugging
      _process!.stdout.transform(utf8.decoder).listen(print);
      _process!.stderr.transform(utf8.decoder).listen(print);

    } catch (e) {
      print('Error starting python server: $e');
      _controller?.addError('Failed to start STT server: $e');
      return;
    }

    // 2. Wait a moment for the server to initialize
    await Future.delayed(const Duration(seconds: 5));

    // 3. Connect to the WebSocket
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8765'));
      _channel!.stream.listen((message) {
        _controller?.add(message);
      }, onError: (error) {
        print('WebSocket error: $error');
        _controller?.addError(error);
      }, onDone: () {
        print('WebSocket connection closed.');
        _controller?.close();
      });
    } catch (e) {
        print('Error connecting to WebSocket: $e');
       _controller?.addError('Failed to connect to STT server: $e');
    }
  }

  void sendAudio(Uint8List audio) {
    if (_channel != null && _channel!.sink.done == null) {
      _channel!.sink.add(audio);
    }
  }

  Future<void> stop() async {
    // Kill the python process first
    _process?.kill();
    print('Python server process killed.');

    // Then close the connection and controller
    await _channel?.sink.close();
    await _controller?.close();
  }
}

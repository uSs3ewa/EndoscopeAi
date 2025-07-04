import 'dart:async';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';

class SttService {
  WebSocketChannel? _channel;
  StreamController<String>? _controller;

  SttService();

  Stream<String> get stream => _controller!.stream;

  Future<void> start(String transcriptPath) async {
    _controller = StreamController<String>.broadcast();
    _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8765'));
    _channel!.stream.listen((message) {
      _controller?.add(message);
    }, onError: (error) {
      _controller?.addError(error);
    }, onDone: () {
      _controller?.close();
    });
  }

  void sendAudio(Uint8List audio) {
    if (_channel != null) {
      _channel!.sink.add(audio);
    }
  }

  Future<void> stop() async {
    await _channel?.sink.close();
    await _controller?.close();
  }
}

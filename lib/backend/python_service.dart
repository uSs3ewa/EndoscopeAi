import 'dart:convert';
import 'dart:io';

/// Helper for invoking Python scripts containing the AI models.
class PythonService {
  final String scriptPath;
  Process? _listenProcess;

  const PythonService({this.scriptPath = 'python_backend/endoscope_ai.py'});

  Future<String> transcribe(String audioPath, {String modelPath = 'python_backend/models/vosk'}) async {
    final result = await Process.run(
      'python',
      [scriptPath, 'stt', modelPath, audioPath],
      runInShell: true,
    );
    return result.stdout.toString().trim();
  }

  Future<List<dynamic>> detectImage(String imagePath, {String weightsPath = 'python_backend/models/endoscope.pt'}) async {
    final result = await Process.run(
      'python',
      [scriptPath, 'detect', weightsPath, imagePath],
      runInShell: true,
    );
    return jsonDecode(result.stdout.toString()) as List<dynamic>;
  }

  Future<void> processVideo(String input, String output, {String weightsPath = 'python_backend/models/endoscope.pt'}) async {
    await Process.run(
      'python',
      [scriptPath, 'video', weightsPath, input, output],
      runInShell: true,
    );
  }

  Stream<String> listen({String modelPath = 'python_backend/models/vosk'}) async* {
    _listenProcess = await Process.start(
      'python',
      [scriptPath, 'listen', modelPath],
      runInShell: true,
    );
    yield* _listenProcess!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter());
  }

  void stopListening() {
    _listenProcess?.kill();
    _listenProcess = null;
  }
}

import 'package:flutter/services.dart';
import 'package:vosk_flutter/vosk_flutter.dart';


Future<String> transcribeWavFromAssets({
  required String audioAssetPath,
  String modelAssetPath = 'models/vosk-model-small-ru-0.22.zip',
  int sampleRate = 16000,
}) async {
  final vosk = VoskFlutterPlugin.instance();

  final modelPath = await ModelLoader().loadFromAssets(modelAssetPath);
  final model = await vosk.createModel(modelPath);

  final recognizer = await vosk.createRecognizer(
    model: model,
    sampleRate: sampleRate,
  );

  final bytes = await rootBundle.load(audioAssetPath);
  final audioBytes = bytes.buffer.asUint8List();

  const chunkSize = 4096;
  int pos = 0;

  while (pos + chunkSize < audioBytes.length) {
    final chunk = audioBytes.sublist(pos, pos + chunkSize);
    await recognizer.acceptWaveformBytes(Uint8List.fromList(chunk));
    pos += chunkSize;
  }

  final remaining = audioBytes.sublist(pos);
  await recognizer.acceptWaveformBytes(Uint8List.fromList(remaining));

  final finalResult = await recognizer.getFinalResult();
  return finalResult;
}

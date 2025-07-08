import 'dart:io';
import 'package:image/image.dart' as img;
import '../../rust/lib/yolo_bridge.dart/frb_generated.dart';

class YoloService {
  YoloService._();
  static final instance = YoloService._();
  bool _initialized = false;
  late YoloHandle _handle;

  Future<void> init({
    String modelPath = 'rust/best.onnx',
    List<String> labels = const ['polyp'],
  }) async {
    if (_initialized) return;
    await RustLib.init();
    _handle = await yoloNew(
      modelPath: modelPath,
      classLabels: labels,
      confidenceThreshold: 0.25,
      nmsThreshold: 0.7,
    );
    _initialized = true;
  }

  Future<List<FFIDetectionResult>> analyzeImage(img.Image image) async {
    await init();
    final rgb = img.copyResize(image, width: image.width, height: image.height);
    final bytes = rgb.toRgb().getBytes(format: img.Format.rgb);
    return await yoloPredict(
      yoloHandle: _handle,
      width: rgb.width,
      height: rgb.height,
      pixels: bytes,
    );
  }

  Future<List<FFIDetectionResult>> analyzeFile(String path) async {
    final data = await File(path).readAsBytes();
    final image = img.decodeImage(data);
    if (image == null) return [];
    return analyzeImage(image);
  }
}

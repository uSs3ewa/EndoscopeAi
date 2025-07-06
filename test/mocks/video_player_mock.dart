import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';
import 'package:video_player/video_player.dart';
import 'package:endoscopy_ai/features/patient/record_data.dart';
import 'package:endoscopy_ai/pages/file_video/file_video_model.dart';

class MockVideoPlayerController extends Mock implements VideoPlayerController {
  final VideoPlayerValue _value;

  MockVideoPlayerController({
    Duration duration = const Duration(seconds: 60),
    Size size = const Size(1920, 1080),
    bool isInitialized = true,
  }) : _value = VideoPlayerValue(
          duration: duration,
          size: size,
          isInitialized: isInitialized,
        );

  @override
  Future<void> initialize() async {
    await Future.delayed(Duration.zero);
  }

  @override
  VideoPlayerValue get value => _value;

  @override
  Future<Uint8List?> snapshot() async {
    return Uint8List.fromList(List.generate(
      1920 * 1080 * 4,
      (index) => index % 256,
    ));
  }

   @override
  Future<void> seekTo(Duration position) async {
    super.noSuchMethod(
      Invocation.method(#seekTo, [position]),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }
}

class MockRecordData extends Mock implements RecordData {
  @override
  int get id => 1;

  @override
  String get filePath => 'test_video.mp4';

  @override
  DateTime get createdAt => DateTime.now();
}

class FakeFilePicker {
  static String? filePath = 'test_video.mp4';

  static bool checkFile() => filePath != null;

  static Future<FilePickerResult?> pickFiles() async {
    return filePath != null
        ? FilePickerResult([PlatformFile(path: filePath, size: 1024, name: '')])
        : null;
  }
}
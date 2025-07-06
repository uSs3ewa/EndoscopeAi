import 'package:endoscopy_ai/shared/widget/screenshot_preview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:video_player/video_player.dart';
import 'package:endoscopy_ai/pages/file_video/file_video_model.dart';
import '../mocks/video_player_mock.dart';
import '../matchers/custom_matchers.dart';

void main() {
  late FileVideoPlayerPageStateModel model;
  late MockVideoPlayerController mockController;
  late MockRecordData mockRecordData;
  bool stateUpdated = false;

  setUp(() async {
    mockController = MockVideoPlayerController();
    mockRecordData = MockRecordData();
    
    model = FileVideoPlayerPageStateModel(
      (_) => stateUpdated = true,
      mockRecordData
    );

    when(mockController.initialize()).thenAnswer((_) async {});
    when(mockController.play()).thenAnswer((_) async {});
    when(mockController.pause()).thenAnswer((_) async {});
  
    when(mockController.seekTo(anyDuration() as Duration)).thenAnswer((invocation) async {
    final duration = invocation.positionalArguments[0] as Duration;
    return;
    });
    
    when(mockController.dispose()).thenAnswer((_) async {});
  });


  test('Initialization with valid file', () async {
    FakeFilePicker.filePath = 'test_video.mp4';
    model.initState();
    await model.initializeFuture;
    expect(model.isValidFile, true);
  });

  test('Initialization with invalid file', () async {
    FakeFilePicker.filePath = null;
    model.initState();
    expect(model.isValidFile, false);
  });

  test('Play/pause functionality', () async {
    model.controllerForTest = mockController;
    
    model.togglePlayPause();
    verify(mockController.play()).called(1);
    expect(model.isPlaying, true);
    
    model.togglePlayPause();
    verify(mockController.pause()).called(1);
    expect(model.isPlaying, false);
  });

  test('Seek functionality', () async {
    model.controllerForTest = mockController;
    const testPosition = Duration(seconds: 30);
    
    model.seekTo(testPosition);
    verify(mockController.seekTo(testPosition)).called(1);
  });

  test('Screenshot creation', () async {
    model.controllerForTest = mockController;
    expect(model.shots.isEmpty, true);
    
    model.makeScreenshot();
    await Future.delayed(Duration.zero);
    
    expect(model.shots.isNotEmpty, true);
    expect(model.shots.last.state, ScreenshotPreviewState.good);
  });

  test('Dispose releases resources', () {
    model.controllerForTest = mockController;
    model.dispose();
    verify(mockController.dispose()).called(1);
  });
}
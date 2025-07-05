import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:video_player/video_player.dart';
import 'package:endoscopy_ai/features/patient/record_data.dart';
import 'package:endoscopy_ai/pages/file_video/file_video_model.dart';

class MockVideoPlayerController extends Mock implements VideoPlayerController {}

class MockRecordData extends Mock implements RecordData {}

void main() {
  late FileVideoPlayerPageStateModel model;
  late MockVideoPlayerController mockController;
  late MockRecordData mockRecordData;
  bool stateUpdated = false;

  setUp(() {
    mockController = MockVideoPlayerController();
    mockRecordData = MockRecordData();
    
    model = FileVideoPlayerPageStateModel(
      (_) => stateUpdated = true,
      mockRecordData
    );

    // Правильная настройка моков
    when(mockController.initialize()).thenAnswer((_) async {});
    when(mockController.value).thenReturn(VideoPlayerValue(
      duration: Duration(seconds: 60),
      position: Duration.zero, // Явно указываем начальную позицию
      isInitialized: true,
    ));
    when(mockController.play()).thenAnswer((_) async {});
    when(mockController.pause()).thenAnswer((_) async {});
  });

  test('Initialization sets correct duration', () async {
    model.controllerForTest = mockController;
    await model.initializeFuture;
    
    expect(model.totalDuration, Duration(seconds: 60));
    expect(model.currentPosition, Duration.zero);
  });

  test('Play/pause toggles correctly', () async {
    model.controllerForTest = mockController;
    
    model.togglePlayPause();
    verify(mockController.play()).called(1);
    expect(model.isPlaying, true);
    
    model.togglePlayPause();
    verify(mockController.pause()).called(1);
    expect(model.isPlaying, false);
  });

  test('Seek to position works', () async {
    model.controllerForTest = mockController;
    final testPosition = Duration(seconds: 30);
    
    model.seekTo(testPosition);
    verify(mockController.seekTo(testPosition)).called(1);
  });
}
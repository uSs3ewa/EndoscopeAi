import 'package:shared_preferences/shared_preferences.dart';
import 'recordings_model.dart';

class RecordingService {
  static const _key = 'recordings';

  Future<List<Recording>> getRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    final recordingsJson = prefs.getStringList(_key) ?? [];
    return recordingsJson.map((json) {
      final parts = json.split('|');
      return Recording(filePath: parts[0], timestamp: DateTime.parse(parts[1]));
    }).toList();
  }

  Future<void> saveRecording(Recording recording) async {
    final prefs = await SharedPreferences.getInstance();
    final recordings = await getRecordings();
    final newRecording =
        '${recording.filePath}|${recording.timestamp.toIso8601String()}';
    recordings.add(recording);
    await prefs.setStringList(
      _key,
      recordings
          .map((r) => '${r.filePath}|${r.timestamp.toIso8601String()}')
          .toList(),
    );
  }
}

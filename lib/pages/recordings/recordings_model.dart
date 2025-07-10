import 'package:shared_preferences/shared_preferences.dart';

class RecordingsPageModel {
  static const _recordingsKey = 'recordings';

  Future<List<Recording>> getRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    final recordingsJson = prefs.getStringList(_recordingsKey) ?? [];
    return recordingsJson.map((json) {
      final parts = json.split('|');
      return Recording(
        filePath: parts[0],
        timestamp: DateTime.parse(parts[1]),
        fileName: parts.length > 2 ? parts[2] : '',
      );
    }).toList();
  }

  Future<void> deleteRecordings(List<Recording> toDelete) async {
    final prefs = await SharedPreferences.getInstance();
    final recordings = await getRecordings();
    recordings.removeWhere(
      (r) => toDelete.any((d) => d.filePath == r.filePath),
    );
    await prefs.setStringList(
      _recordingsKey,
      recordings
          .map((r) => '${r.filePath}|${r.timestamp.toIso8601String()}')
          .toList(),
    );
  }

  Future<void> addRecording(Recording recording) async {
    final prefs = await SharedPreferences.getInstance();
    final recordings = await getRecordings();
    // Убираем дубликаты по filePath
    if (recordings.any((r) => r.filePath == recording.filePath)) {
      // Уже есть такая запись, не добавляем
      return;
    }
    recordings.add(recording);
    await prefs.setStringList(
      _recordingsKey,
      recordings
          .map((r) =>
              '${r.filePath}|${r.timestamp.toIso8601String()}|${r.fileName}')
          .toList(),
    );
  }
}

class Recording {
  final String filePath;
  final DateTime timestamp;
  final String fileName;

  Recording({
    required this.filePath,
    required this.timestamp,
    required this.fileName,
  });
}

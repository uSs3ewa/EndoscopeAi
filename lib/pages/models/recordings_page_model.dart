// ====================================================
//  Окно просмотра записей
//  Здесь описан UI
// ====================================================
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class RecordingsPageModel with ChangeNotifier {
  late Directory _dir;
  List<FileSystemEntity> _videos = [];
  late final Future<void> initialized;

  List<FileSystemEntity> get videos => _videos;

  RecordingsPageModel() {
    initialized = _init();
  }

  Future<void> _init() async {
    final base = await getApplicationDocumentsDirectory();
    _dir = Directory(p.join(base.path, 'recordings'));
    if (!await _dir.exists()) {
      await _dir.create(recursive: true);
    }
    _videos = _dir
        .listSync()
        .where((e) => e.path.toLowerCase().endsWith('.mp4'))
        .toList();
  }
}

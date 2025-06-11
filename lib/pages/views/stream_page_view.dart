// ====================================================
//  Страница для просмотра стриммингого видео
//  Тут имплементировано взаимодействие с UI
// ====================================================
import 'package:flutter/material.dart';
import '../models/stream_page_model.dart';
import '../../shared/widget/buttons.dart';

//  Логика, содержащая логику, связанную с UI
class StreamPlayerPageView {
  final StreamPlayerPageModel _model;

  StreamPlayerPageView(this._model);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Стриминг плеер:')),
      body: Column(children: [createBackHomeButton(context)]),
    );
  }
}

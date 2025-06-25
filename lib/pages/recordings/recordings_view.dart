// ====================================================
//  Окно просмотра записей
//  Здесь описан UI
// ====================================================
import 'package:flutter/material.dart';
import 'package:endoscopy_ai/shared/widget/buttons.dart';
import 'recordings_model.dart';

//  Логика, содержащая логику, связанную с UI
class RecordingsPageView {
  final RecordingsPageModel _model;

  RecordingsPageView(this._model);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Записи:')),
      body: Column(children: [createBackHomeButton(context)]),
    );
  }
}

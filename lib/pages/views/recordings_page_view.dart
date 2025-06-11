// ====================================================
//  Окно просмотра записей
//  Здесь описан UI
// ====================================================
import 'package:flutter/material.dart';
import '../../shared/widget/buttons.dart';
import '../models/recordings_page_model.dart';

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

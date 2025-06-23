// ====================================================
//  Окно просмотра записей
// ====================================================
import 'package:flutter/material.dart';
import 'package:endoscopy_ai/shared/widget/buttons.dart';
import 'views/recordings_page_view.dart';
import 'models/recordings_page_model.dart';

// Страница просмотра записей
class RecordingsPage extends StatelessWidget {
  late final RecordingsPageModel _model;
  late final RecordingsPageView _view;

  RecordingsPage() {
    _model = RecordingsPageModel();
    _view = RecordingsPageView(_model);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Записи:')),
      body: Column(children: [createBackHomeButton(context)]),
    );
  }
}

// ====================================================
//  Страница для просмотра стриммингого видео
// ====================================================
import 'package:flutter/material.dart';
import 'models/stream_page_model.dart';
import 'views/stream_page_view.dart';
import '../shared/widget/buttons.dart';

class StreamPlayerPage extends StatelessWidget {
  late final StreamPlayerPageModel _model;
  late final StreamPlayerPageView _view;

  StreamPlayerPage() {
    _model = StreamPlayerPageModel();
    _view = StreamPlayerPageView(_model);
  }

  @override
  Widget build(BuildContext context) {
    return _view.build(context);
  }
}

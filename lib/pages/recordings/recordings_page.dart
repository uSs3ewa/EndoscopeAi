import 'package:flutter/material.dart';
import 'recordings_view.dart';
import 'recordings_model.dart';

class RecordingsPage extends StatefulWidget {

  @override
  _RecordingsPageState createState() => _RecordingsPageState();
}

class _RecordingsPageState extends State<RecordingsPage> {
  late final RecordingsPageModel _model;

  @override
  void initState() {
    super.initState();
    _model = RecordingsPageModel();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Записи:')),
      body: Column(
        children: [
          Expanded(
            child: RecordingsPageView(model: _model, refresh: _refresh),
          ),
        ],
      ),
    );
  }
}

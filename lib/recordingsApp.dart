import 'package:flutter/material.dart';

import 'backButton.dart';

class RecordingsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Записи:')),
      body: Column(
        children: [
          getBackButton(context),
        ],
      ),
    );
  }
}
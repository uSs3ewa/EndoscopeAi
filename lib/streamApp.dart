import 'package:flutter/material.dart';

import 'backButton.dart';

class StreamPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Стриминг плеер:')),
      body: Column(
        children: [
          getBackButton(context),
        ],
      ),
    );
  }
}
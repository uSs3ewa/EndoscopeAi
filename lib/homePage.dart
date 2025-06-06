import 'package:flutter/material.dart';

import 'customButton.dart';
import 'fileChoser.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная страница')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getStreamVideoPlayerButton(context),
            getIndention(),
            getVideoPlayerButton(context),
            getIndention(),
            getRecordingsButton(context),
          ],
        ),
      ),
    );
  }

  Widget getVideoPlayerButton(context){
    return ElevatedButton(
              onPressed: () async {
                FilePicker.pickFile(context);
              },
              child: const Text('Открыть видеоплеер'),
            );
  }

  Widget getRecordingsButton(context){
    return getCustomButton(context, 'Открыть видеозаписи', '/recordings');
  }

  Widget getStreamVideoPlayerButton(context){
    return getCustomButton(context, 'Открыть стриминговый плеер', '/streamVideoPlayer');
  }

  Widget getIndention(){
    return const SizedBox(height: 20);
  }
}
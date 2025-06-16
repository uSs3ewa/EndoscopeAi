// ====================================================
//  Страница для просмотра стриммингого видео
// ====================================================
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/routes.dart';
import '../pages/models/stream_page_model.dart';
import '../pages/views/stream_page_view.dart';

class StreamPage extends StatefulWidget {
  final CameraDescription camera;

  const StreamPage({Key? key, required this.camera}) : super(key: key);

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  late final StreamPageModel _model;

  @override
  void initState() {
    super.initState();
    _model = StreamPageModel();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _handlePictureTaken(XFile image) {
    Navigator.pushNamed(
      context,
      Routes.annotate,
      arguments: image.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamPageView(
      model: _model,
      camera: widget.camera,
      onBackPressed: () => Navigator.pop(context),
      onPictureTaken: _handlePictureTaken,
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

import 'shapes.dart';

enum Tool { pen, rect, circle, move }

class AnnotatePage extends StatefulWidget {
  const AnnotatePage({super.key, required this.imagePath});
  final String imagePath;

  @override
  State<AnnotatePage> createState() => _AnnotatePageState();
}

class _AnnotatePageState extends State<AnnotatePage> {
  final _globalKey = GlobalKey();

  // палитра и инструменты

  static const _palette = [
    Color(0xFF0072B2),
    Color(0xFFE69F00),
    Color(0xFF009E73),
  ];

  Color _color = _palette.first;
  Tool  _tool  = Tool.pen;

  // холст

  final _elements = <Shape>[];
  Shape? _draft;              // фигура

  // для перемещения
  Shape?  _selected;
  Offset? _lastPos;

  // история

  final _history = <List<Shape>>[];
  int   _histIx  = -1;

  void _commitState() {
    final snap = _elements.map((e) => e.clone()).toList();
    if (_histIx < _history.length - 1) {
      _history.removeRange(_histIx + 1, _history.length);
    }
    _history.add(snap);
    _histIx = _history.length - 1;
  }

  // UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аннотация скрина'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: _redo),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSvg),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _globalKey,
                child: GestureDetector(
                  onPanStart: _onStart,
                  onPanUpdate: _onUpdate,
                  onPanEnd:   _onEnd,
                  child: Stack(
                    children: [
                      Image.file(File(widget.imagePath)),
                      Positioned.fill(
                        child: CustomPaint(painter: _Painter(_elements, _draft)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(children: [
          for (final c in _palette) _colorBtn(c),
          const SizedBox(width: 20),
          _toolBtn(Icons.edit,           Tool.pen),
          _toolBtn(Icons.crop_square,    Tool.rect),
          _toolBtn(Icons.circle_outlined,Tool.circle),
          _toolBtn(Icons.open_with,      Tool.move),
        ]),
      );

  Widget _colorBtn(Color c) => GestureDetector(
        onTap: () => setState(() => _color = c),
        child: Container(
          margin: const EdgeInsets.only(right: 6),
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: c, shape: BoxShape.circle,
            border: Border.all(
              color: _color == c
                  ? Theme.of(context).colorScheme.onPrimary
                  : Colors.black26,
              width: 2,
            ),
          ),
        ),
      );

  Widget _toolBtn(IconData i, Tool t) => IconButton(
        icon: Icon(i, color: _tool == t
            ? Theme.of(context).colorScheme.primary
            : null),
        onPressed: () => setState(() => _tool = t),
      );

  // жесты

  void _onStart(DragStartDetails d) => setState(() {
        if (_tool == Tool.move) {
          for (final s in _elements.reversed) {
            if (s.hitTest(d.localPosition)) {
              _selected = s;
              _lastPos  = d.localPosition;
              break;
            }
          }
          return;
        }

        switch (_tool) {
          case Tool.pen:
            _draft = PenShape([d.localPosition], _color);
          case Tool.rect:
            _draft = RectShape(d.localPosition, d.localPosition, _color);
          case Tool.circle:
            _draft = CircleShape(d.localPosition, d.localPosition, _color);
          default:
            break;
        }
      });

  void _onUpdate(DragUpdateDetails d) => setState(() {
        if (_tool == Tool.move && _selected != null && _lastPos != null) {
          final delta = d.localPosition - _lastPos!;
          _selected!.translate(delta);
          _lastPos = d.localPosition;
          return;
        }

        if (_draft is PenShape) {
          (_draft as PenShape).points.add(d.localPosition);
        } else if (_draft is RectShape) {
          (_draft as RectShape).p2 = d.localPosition;
        } else if (_draft is CircleShape) {
          (_draft as CircleShape).edge = d.localPosition;
        }
      });

  void _onEnd(DragEndDetails d) => setState(() {
        if (_tool == Tool.move) {
          _selected = null;
          _lastPos  = null;
          _commitState();
          return;
        }

        if (_draft != null) {
          _elements.add(_draft!.clone());
          _draft = null;
          _commitState();
        }
      });

  // Undo / Redo



  void _undo() {
    if (_histIx > 0) {
      setState(() {
        _histIx--;
        _elements
          ..clear()
          ..addAll(_history[_histIx].map((e) => e.clone()));
      });
    }
  }

  void _redo() {
    if (_histIx < _history.length - 1) {
      setState(() {
        _histIx++;
        _elements
          ..clear()
          ..addAll(_history[_histIx].map((e) => e.clone()));
      });
    }
  }

  // Сохранение

  Future<void> _saveSvg() async {
    try {
      // 1) снимаем размеры холста
      final boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image img = await boundary.toImage(pixelRatio: 1.0);
      final w = img.width, h = img.height;

      // 2) фон → base64
      final b64 = base64Encode(await File(widget.imagePath).readAsBytes());

      // 3) SVG-контент
      final shapesXml =
          _elements.map((e) => e.toSvg().toXmlString()).join('\n  ');
      final svg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     width="$w" height="$h" viewBox="0 0 $w $h">
  <image xlink:href="data:image/png;base64,$b64"
         x="0" y="0" width="$w" height="$h" />
  $shapesXml
</svg>
''';

      // 4) диалог «Сохранить как…»
      final basename =
          'annotate_${p.basenameWithoutExtension(widget.imagePath)}.svg';
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Сохранить аннотацию',
        fileName: basename,
        type: FileType.custom,
        allowedExtensions: ['svg'],
      );

      if (path == null) return; // нажал «Отмена»

      await File(path).writeAsString(svg);

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Сохранено: ${p.basename(path)}')));
      }
    } catch (e) {
      debugPrint('Save SVG error: $e');
    }
  }
}

// Painter

class _Painter extends CustomPainter {
  final List<Shape> shapes;
  final Shape? draft;
  _Painter(this.shapes, this.draft);

  @override
  void paint(Canvas c, Size s) {
    final p = Paint();
    for (final s in shapes) {
      s.paint(c, p);
    }
    draft?.paint(c, p);
  }

  @override
  bool shouldRepaint(covariant _Painter old) =>
      old.shapes != shapes || old.draft != draft;
}


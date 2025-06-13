import 'dart:ui';
import 'package:xml/xml.dart';

// Базовый класс фигуры
abstract class Shape {
  final Color color;
  Shape(this.color);

  void paint(Canvas canvas, Paint paint);
  XmlNode toSvg();

  // Перемещение
  bool hitTest(Offset p);
  void translate(Offset delta);

  // Undo/Redo
  Shape clone();

  String get _hex =>
      '#${color.value.toRadixString(16).padLeft(8, "0").substring(2)}';
}

// Линия

class PenShape extends Shape {
  final List<Offset> points;
  PenShape(this.points, Color c) : super(c);

  @override
  void paint(Canvas c, Paint p) {
    p
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final pt in points.skip(1)) {
      path.lineTo(pt.dx, pt.dy);
    }
    c.drawPath(path, p);
  }

  @override
  XmlNode toSvg() => XmlElement(
        XmlName('polyline'),
        [
          XmlAttribute(XmlName('points'),
              points.map((e) => '${e.dx},${e.dy}').join(' ')),
          XmlAttribute(XmlName('fill'), 'none'),
          XmlAttribute(XmlName('stroke'), _hex),
          XmlAttribute(XmlName('stroke-width'), '3'),
        ],
      );

  @override
  bool hitTest(Offset p) =>
      points.any((pt) => (pt - p).distance <= 8); // «захват» 8 px

  @override
  void translate(Offset d) {
    for (var i = 0; i < points.length; i++) {
      points[i] += d;
    }
  }

  @override
  Shape clone() => PenShape(List.of(points), color);
}

// Прямоугольник

class RectShape extends Shape {
  Offset p1, p2;
  RectShape(this.p1, this.p2, Color c) : super(c);

  Rect get _rect => Rect.fromPoints(p1, p2);

  @override
  void paint(Canvas c, Paint p) {
    p
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    c.drawRect(_rect, p);
  }

  @override
  XmlNode toSvg() => XmlElement(XmlName('rect'), [
        XmlAttribute(XmlName('x'), _rect.left.toString()),
        XmlAttribute(XmlName('y'), _rect.top.toString()),
        XmlAttribute(XmlName('width'), _rect.width.toString()),
        XmlAttribute(XmlName('height'), _rect.height.toString()),
        XmlAttribute(XmlName('fill'), 'none'),
        XmlAttribute(XmlName('stroke'), _hex),
        XmlAttribute(XmlName('stroke-width'), '3'),
      ]);

  @override
  bool hitTest(Offset p) => _rect.inflate(6).contains(p);

  @override
  void translate(Offset d) {
    p1 += d;
    p2 += d;
  }

  @override
  Shape clone() => RectShape(p1, p2, color);
}


// Круг/овал: центр = точка клика

class CircleShape extends Shape {
  Offset center, edge;                       // edge определяет радиус
  CircleShape(this.center, this.edge, Color c) : super(c);

  double get _radius => (edge - center).distance;

  @override
  void paint(Canvas c, Paint p) {
    p
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    c.drawCircle(center, _radius, p);
  }

  @override
  XmlNode toSvg() => XmlElement(XmlName('circle'), [
        XmlAttribute(XmlName('cx'), center.dx.toString()),
        XmlAttribute(XmlName('cy'), center.dy.toString()),
        XmlAttribute(XmlName('r'),  _radius.toString()),
        XmlAttribute(XmlName('fill'), 'none'),
        XmlAttribute(XmlName('stroke'), _hex),
        XmlAttribute(XmlName('stroke-width'), '3'),
      ]);

  @override
  bool hitTest(Offset p) => (p - center).distance <= _radius + 6;

  @override
  void translate(Offset d) {
    center += d;
    edge   += d;
  }

  @override
  Shape clone() => CircleShape(center, edge, color);
}


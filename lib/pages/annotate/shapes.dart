import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

Offset _abs(Size s, Offset rel) => Offset(rel.dx * s.width, rel.dy * s.height);
String _hx(Color c) => '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';

abstract class Shape {
  Shape(this.color, this.strokeWidth);
  final Color color;
  final double strokeWidth;

  void paint(Canvas c, Paint p, Size cs);
  XmlNode toSvg(Size cs);

  bool hitTest(Offset p, Size cs);
  void translateRel(Offset dRel);
  Shape clone();
  bool compareTo(Shape other);
}

// Pen
class PenShape extends Shape {
  List<Offset> pts; // relative
  PenShape(this.pts, Color col, double strokeWidth) : super(col, strokeWidth);

  @override
  void paint(Canvas c, Paint p, Size cs) {
    p
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(_abs(cs, pts.first).dx, _abs(cs, pts.first).dy);
    for (final rp in pts.skip(1)) {
      final v = _abs(cs, rp);
      path.lineTo(v.dx, v.dy);
    }
    c.drawPath(path, p);
  }

  @override
  XmlNode toSvg(Size cs) => XmlElement(XmlName('polyline'), [
        XmlAttribute(
            XmlName('points'),
            pts
                .map((rp) => _abs(cs, rp))
                .map((v) => '${v.dx},${v.dy}')
                .join(' ')),
        XmlAttribute(XmlName('fill'), 'none'),
        XmlAttribute(XmlName('stroke'), _hx(color)),
        XmlAttribute(XmlName('stroke-width'), strokeWidth.toStringAsFixed(1)),
      ]);

  @override
  bool hitTest(Offset p, Size cs) =>
      pts.any((rp) => (_abs(cs, rp) - p).distance <= 8);

  @override
  void translateRel(Offset d) {
    for (var i = 0; i < pts.length; i++) {
      pts[i] += d;
    }
  }

  @override
  Shape clone() => PenShape(List.of(pts), color, strokeWidth);

  @override
  bool compareTo(Shape other) =>
      other is PenShape &&
      listEquals(other.pts, pts) &&
      other.color == color &&
      other.strokeWidth == strokeWidth;
}

// Rect
class RectShape extends Shape {
  Offset p1, p2; // relative
  RectShape(this.p1, this.p2, Color col, double strokeWidth) : super(col, strokeWidth);

  Rect _rect(Size cs) => Rect.fromPoints(_abs(cs, p1), _abs(cs, p2));

  @override
  void paint(Canvas c, Paint p, Size cs) {
    p
      ..color = color.withOpacity(0.6)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    c.drawRect(_rect(cs), p);
  }

  @override
  XmlNode toSvg(Size cs) {
    final r = _rect(cs);
    return XmlElement(XmlName('rect'), [
      XmlAttribute(XmlName('x'), r.left.toStringAsFixed(1)),
      XmlAttribute(XmlName('y'), r.top.toStringAsFixed(1)),
      XmlAttribute(XmlName('width'), r.width.toStringAsFixed(1)),
      XmlAttribute(XmlName('height'), r.height.toStringAsFixed(1)),
      XmlAttribute(XmlName('fill'), 'none'),
      XmlAttribute(XmlName('stroke'), _hx(color)),
      XmlAttribute(XmlName('stroke-width'), strokeWidth.toStringAsFixed(1)),
    ]);
  }

  @override
  bool hitTest(Offset p, Size cs) => _rect(cs).inflate(6).contains(p);

  @override
  void translateRel(Offset d) {
    p1 += d;
    p2 += d;
  }

  @override
  Shape clone() => RectShape(p1, p2, color, strokeWidth);

  @override
  bool compareTo(Shape o) =>
      o is RectShape &&
      o.p1 == p1 &&
      o.p2 == p2 &&
      o.color == color &&
      o.strokeWidth == strokeWidth;
}

// Circle 
class CircleShape extends Shape {
  Offset a, b; // opposite corners (rel)
  CircleShape(this.a, this.b, Color col, double strokeWidth) : super(col, strokeWidth);

  @override
  void paint(Canvas c, Paint p, Size cs) {
    p
      ..color = color.withOpacity(0.6)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final rect = Rect.fromPoints(_abs(cs, a), _abs(cs, b));
    c.drawCircle(rect.center, rect.shortestSide / 2, p);
  }

  @override
  XmlNode toSvg(Size cs) {
    final rect = Rect.fromPoints(_abs(cs, a), _abs(cs, b));
    return XmlElement(XmlName('circle'), [
      XmlAttribute(XmlName('cx'), rect.center.dx.toStringAsFixed(1)),
      XmlAttribute(XmlName('cy'), rect.center.dy.toStringAsFixed(1)),
      XmlAttribute(XmlName('r'), (rect.shortestSide / 2).toStringAsFixed(1)),
      XmlAttribute(XmlName('fill'), 'none'),
      XmlAttribute(XmlName('stroke'), _hx(color)),
      XmlAttribute(XmlName('stroke-width'), strokeWidth.toStringAsFixed(1)),
    ]);
  }

  @override
  bool hitTest(Offset p, Size cs) {
    final rect = Rect.fromPoints(_abs(cs, a), _abs(cs, b));
    return (p - rect.center).distance <= rect.shortestSide / 2 + 6;
  }

  @override
  void translateRel(Offset d) {
    a += d;
    b += d;
  }

  @override
  Shape clone() => CircleShape(a, b, color, strokeWidth);

  @override
  bool compareTo(Shape o) =>
      o is CircleShape &&
      o.a == a &&
      o.b == b &&
      o.color == color &&
      o.strokeWidth == strokeWidth;
}


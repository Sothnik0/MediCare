import 'package:flutter/material.dart';
import '../../../../core/temas/cores_app.dart';

class LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.55)
        ..quadraticBezierTo(size.width * 0.3, size.height * 0.25, size.width * 0.6, size.height * 0.45)
        ..quadraticBezierTo(size.width * 0.85, size.height * 0.60, size.width, size.height * 0.40)
        ..lineTo(size.width, size.height)..lineTo(0, size.height)..close(),
      Paint()..color = CoresApp.gramaMedio,
    );

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.75)
        ..quadraticBezierTo(size.width * 0.25, size.height * 0.55, size.width * 0.55, size.height * 0.70)
        ..quadraticBezierTo(size.width * 0.80, size.height * 0.85, size.width, size.height * 0.70)
        ..lineTo(size.width, size.height)..lineTo(0, size.height)..close(),
      Paint()..color = CoresApp.gramaDark,
    );

    _drawHouse(canvas, size);
    _drawBush(canvas, size.width * 0.30, size.height * 0.78, 18);
    _drawBush(canvas, size.width * 0.45, size.height * 0.82, 22);
  }

  void _drawHouse(Canvas canvas, Size size) {
    final hx = size.width * 0.25;
    final hy = size.height * 0.45;
    final stroke = Paint()..color = CoresApp.textoDark..style = PaintingStyle.stroke..strokeWidth = 1.5;

    final wallRect = Rect.fromLTWH(hx - 25, hy + 5, 50, 40);
    canvas.drawRect(wallRect, Paint()..color = CoresApp.casaParede);
    canvas.drawRect(wallRect, stroke);

    final roof = Path()..moveTo(hx - 32, hy + 8)..lineTo(hx, hy - 20)..lineTo(hx + 32, hy + 8)..close();
    canvas.drawPath(roof, Paint()..color = CoresApp.casaTelhado);
    canvas.drawPath(roof, stroke);

    final chimneyRect = Rect.fromLTWH(hx - 18, hy - 18, 8, 16);
    canvas.drawRect(chimneyRect, Paint()..color = CoresApp.casaChamine);
    canvas.drawRect(chimneyRect, stroke);

    final smoke = Paint()..color = CoresApp.nuvemBranco.withOpacity(0.9);
    for (final c in [Offset(hx - 14, hy - 24), Offset(hx - 18, hy - 30), Offset(hx - 12, hy - 35)]) {
      canvas.drawCircle(c, 3.5, smoke);
      canvas.drawCircle(c, 3.5, stroke);
    }

    final doorRect = Rect.fromLTWH(hx - 18, hy + 25, 10, 20);
    canvas.drawRect(doorRect, Paint()..color = CoresApp.casaPorta);
    canvas.drawRect(doorRect, stroke);
    canvas.drawCircle(Offset(hx - 11, hy + 35), 1, Paint()..color = CoresApp.textoDark);

    final winRect = Rect.fromLTWH(hx + 2, hy + 18, 14, 14);
    canvas.drawRect(winRect, Paint()..color = CoresApp.nuvemBranco);
    canvas.drawRect(winRect, stroke);
    canvas.drawLine(Offset(hx + 9, hy + 18), Offset(hx + 9, hy + 32), stroke);
    canvas.drawLine(Offset(hx + 2, hy + 25), Offset(hx + 16, hy + 25), stroke);
  }

  void _drawBush(Canvas canvas, double cx, double cy, double r) {
    final fill   = Paint()..color = CoresApp.arbusto;
    final stroke = Paint()..color = CoresApp.textoDark..style = PaintingStyle.stroke..strokeWidth = 1.2;
    final path = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx - r * 0.5, cy), radius: r * 0.7))
      ..addOval(Rect.fromCircle(center: Offset(cx, cy - r * 0.3), radius: r * 0.8))
      ..addOval(Rect.fromCircle(center: Offset(cx + r * 0.5, cy), radius: r * 0.7));
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
import 'package:flutter/material.dart';
import '../../../../core/temas/cores_app.dart';

class DovePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = CoresApp.nuvemBranco..style = PaintingStyle.fill;
    final stroke    = Paint()..color = CoresApp.textoDark..style = PaintingStyle.stroke..strokeWidth = 1.8;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final body = Path()
      ..moveTo(cx - 25, cy + 8)
      ..quadraticBezierTo(cx - 30, cy - 5,  cx - 15, cy - 12)
      ..quadraticBezierTo(cx,      cy - 18,  cx + 18, cy - 10)
      ..quadraticBezierTo(cx + 28, cy - 3,   cx + 25, cy + 5)
      ..quadraticBezierTo(cx + 15, cy + 12,  cx,      cy + 13)
      ..quadraticBezierTo(cx - 18, cy + 14,  cx - 25, cy + 8)
      ..close();
    canvas.drawPath(body, bodyPaint);
    canvas.drawPath(body, stroke);

    canvas.drawPath(
      Path()..moveTo(cx - 10, cy - 8)..quadraticBezierTo(cx, cy + 2, cx + 18, cy - 2),
      stroke,
    );

    canvas.drawCircle(Offset(cx + 20, cy - 8), 5, bodyPaint);
    canvas.drawCircle(Offset(cx + 20, cy - 8), 5, stroke);

    canvas.drawPath(
      Path()..moveTo(cx + 24, cy - 9)..lineTo(cx + 30, cy - 7)..lineTo(cx + 24, cy - 5)..close(),
      stroke,
    );

    canvas.drawCircle(Offset(cx + 21, cy - 9), 1.2, Paint()..color = CoresApp.textoDark);

    final tail = Path()
      ..moveTo(cx - 22, cy + 2)..lineTo(cx - 32, cy - 2)
      ..lineTo(cx - 32, cy + 4)..lineTo(cx - 22, cy + 8)..close();
    canvas.drawPath(tail, bodyPaint);
    canvas.drawPath(tail, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
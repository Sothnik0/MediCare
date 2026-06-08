import 'package:flutter/material.dart';
import '../../../../core/temas/cores_app.dart';

class CloudsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CoresApp.nuvemBranco
      ..style = PaintingStyle.fill;

    final outline = Paint()
      ..color = CoresApp.textoDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.55);

    const segments = 7;
    final sw = size.width / segments;
    for (int i = 0; i < segments; i++) {
      final controlX = i * sw + sw / 2;
      final endX = (i + 1) * sw;
      final isUp = i % 2 == 0;
      path.quadraticBezierTo(
        controlX,
        isUp ? size.height * 0.95 : size.height * 0.30,
        endX,
        size.height * 0.55,
      );
    }
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);

    final outlinePath = Path()..moveTo(0, size.height * 0.55);
    final sw2 = size.width / segments;
    for (int i = 0; i < segments; i++) {
      final controlX = i * sw2 + sw2 / 2;
      final endX = (i + 1) * sw2;
      final isUp = i % 2 == 0;
      outlinePath.quadraticBezierTo(
        controlX,
        isUp ? size.height * 0.95 : size.height * 0.30,
        endX,
        size.height * 0.55,
      );
    }
    canvas.drawPath(outlinePath, outline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
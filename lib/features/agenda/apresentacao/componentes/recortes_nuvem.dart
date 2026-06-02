import 'package:flutter/material.dart';

/// Clippa o container BRANCO do cabeçalho.
/// A borda inferior fica com ondas convexas para BAIXO (bumps brancos caindo no ciano).
class RecorteNuvemSuperior extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const int numOndas = 5;
    final double larguraOnda = size.width / numOndas;
    // Base onde as ondas começam (35px acima do fundo do container)
    final double baseY = size.height - 35;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, baseY);

    // Ondas da direita para a esquerda, convexas para BAIXO
    for (int i = numOndas - 1; i >= 0; i--) {
      final double endX = i * larguraOnda;
      final double midX = i * larguraOnda + larguraOnda / 2;
      // Ponto de controle em size.height (fundo do container) = ondas descem até lá
      path.quadraticBezierTo(midX, size.height, endX, baseY);
    }

    path.close(); // fecha de volta para (0, 0)
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Clippa o container BRANCO do rodapé.
/// A borda superior fica com ondas convexas para CIMA (bumps brancos subindo no ciano).
class RecorteNuvemInferior extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const int numOndas = 5;
    final double larguraOnda = size.width / numOndas;
    // Base onde as ondas terminam (35px abaixo do topo do container)
    const double baseY = 35.0;

    final path = Path();
    path.moveTo(0, baseY);

    // Ondas da esquerda para a direita, convexas para CIMA
    for (int i = 0; i < numOndas; i++) {
      final double endX = (i + 1) * larguraOnda;
      final double midX = i * larguraOnda + larguraOnda / 2;
      // Ponto de controle em y=0 (topo do container) = ondas sobem até lá
      path.quadraticBezierTo(midX, 0, endX, baseY);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
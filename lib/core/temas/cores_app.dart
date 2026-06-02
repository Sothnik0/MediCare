import 'package:flutter/material.dart';

class CoresApp {
  // ── Cores principais do app (agenda / medicamentos) ────────
  static const Color cianoPrincipal  = Color(0xFF00E5FF);
  static const Color cianoClaro      = Color(0xFFCCF7FF);
  static const Color azulCard        = Color(0xFF0099BB);
  static const Color fundoCreme      = Color(0xFFF9F9F7);
  static const Color textoForte      = Colors.black87;
  static const Color textoSecundario = Colors.black54;
  static const Color branco          = Colors.white;

  static const LinearGradient gradienteBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [cianoClaro, cianoPrincipal],
  );

  // ── Cores da tela de Login ──────────────────────────────────
  static const Color loginCianoPrincipal = Color(0xFF26D7D9);
  static const Color loginCianoClaro     = Color(0xFF4FE0E2);
  static const Color nuvemBranco         = Color(0xFFF5F5F0);
  static const Color botaoCreme          = Color(0xFFFAF6E7);
  static const Color textoDark           = Color(0xFF2C2C2C);

  // ── Cores da paisagem (painters) ───────────────────────────
  static const Color gramaDark   = Color(0xFF2E7D32);
  static const Color gramaMedio  = Color(0xFF388E3C);
  static const Color gramaClaro  = Color(0xFF66BB6A);
  static const Color arbusto     = Color(0xFF7CB342);
  static const Color casaTelhado = Color(0xFF5D2E1F);
  static const Color casaParede  = Color(0xFFB8D957);
  static const Color casaPorta   = Color(0xFF8B4513);
  static const Color casaChamine = Color(0xFFB85450);

  // ── Cores da tela de Cadastro ───────────────────────────────
  static const Color soloMarrom     = Color(0xFF6B4226);
  static const Color soloClaro      = Color(0xFF8B5A2B);
  static const Color soloEscuro     = Color(0xFF4A2C18);
  static const Color campoGray      = Color(0xFF9E9E9E);
  static const Color campoGrayClaro = Color(0xFFB0B0B0);
  static const Color inputGray      = Color(0xFFC0C0C0);
  static const Color textoBranco    = Color(0xFFF5F5F0);
}
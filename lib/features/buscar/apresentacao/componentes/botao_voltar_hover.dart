import 'package:flutter/material.dart';
import '../../../../core/temas/cores_app.dart';

class BotaoVoltarHover extends StatefulWidget {
  final VoidCallback onTap;

  const BotaoVoltarHover({
    super.key,
    required this.onTap,
  });

  @override
  State<BotaoVoltarHover> createState() => _BotaoVoltarHoverState();
}

class _BotaoVoltarHoverState extends State<BotaoVoltarHover> {
  bool _hovered = false;

  void _onEnter(PointerEvent e) {
    setState(() {
      _hovered = true;
    });
  }

  void _onExit(PointerEvent e) {
    setState(() {
      _hovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hovered
                ? CoresApp.azulCard.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_back_ios,
            size: 22,
            color: _hovered ? CoresApp.azulCard : CoresApp.textoForte,
          ),
        ),
      ),
    );
  }
}

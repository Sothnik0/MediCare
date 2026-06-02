import 'package:flutter/material.dart';
import '../../../../core/temas/cores_app.dart';

class BotaoNavegacaoHome extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const BotaoNavegacaoHome({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  State<BotaoNavegacaoHome> createState() => _BotaoNavegacaoHomeState();
}

class _BotaoNavegacaoHomeState extends State<BotaoNavegacaoHome> {
  bool _hovering = false;

  // ✅ Métodos separados com tipo explícito — sem erro de assinatura
  void _onEnter(PointerEvent e) => setState(() => _hovering = true);
  void _onExit(PointerEvent e)  => setState(() => _hovering = false);

  @override
  Widget build(BuildContext context) {
    final btn = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: _hovering
                ? CoresApp.cianoPrincipal.withOpacity(0.15)
                : CoresApp.branco,
            borderRadius: BorderRadius.circular(15),
            border: _hovering
                ? Border.all(color: CoresApp.azulCard, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovering ? 0.10 : 0.05),
                blurRadius: _hovering ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: _hovering ? CoresApp.azulCard : CoresApp.textoForte,
            size: 32,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: btn);
    }
    return btn;
  }
}
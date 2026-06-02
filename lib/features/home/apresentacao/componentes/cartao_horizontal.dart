import 'package:flutter/material.dart';

const Color _azulCard = Color(0xFF0099BB);
const Color _amarelo  = Color(0xFFFFCC00);

class CartaoHorizontal extends StatefulWidget {
  final String label;
  final String imgPath;
  final bool mostrarEstrela;
  final VoidCallback? onTap;

  const CartaoHorizontal({
    super.key,
    required this.label,
    required this.imgPath,
    this.mostrarEstrela = true,
    this.onTap,
  });

  @override
  State<CartaoHorizontal> createState() => _CartaoHorizontalState();
}

class _CartaoHorizontalState extends State<CartaoHorizontal> {
  bool _hovering = false;

  void _onEnter(PointerEvent e) => setState(() => _hovering = true);
  void _onExit(PointerEvent e)  => setState(() => _hovering = false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 160,
          height: 130,
          margin: const EdgeInsets.only(right: 14, top: 4, bottom: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: _hovering && widget.onTap != null
                ? Border.all(color: _azulCard, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovering ? 0.25 : 0.15),
                blurRadius: _hovering ? 10 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.imgPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported_outlined,
                            size: 32, color: Colors.grey.shade400),
                        const SizedBox(height: 4),
                        Text(
                          widget.label,
                          style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade500,
                              fontFamily: 'Serif'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
                if (widget.mostrarEstrela)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, color: _amarelo, size: 16),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.88),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
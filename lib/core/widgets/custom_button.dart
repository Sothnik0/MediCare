import 'package:flutter/material.dart';
import '../temas/cores_app.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.label, required this.onPressed});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: _hovering
              ? CoresApp.botaoCreme.withOpacity(0.85)
              : CoresApp.botaoCreme,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovering ? 0.18 : 0.10),
              blurRadius: _hovering ? 10 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              letterSpacing: 1.5,
              color: CoresApp.textoDark,
              fontFamily: 'Serif',
            ),
          ),
        ),
      ),
    );
  }
}
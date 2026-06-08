import 'package:flutter/material.dart';

class RemedioCardHover extends StatefulWidget {
  final VoidCallback onTap;
  final Widget Function(bool hovered) cardBuilder;

  const RemedioCardHover({
    super.key,
    required this.onTap,
    required this.cardBuilder,
  });

  @override
  State<RemedioCardHover> createState() => _RemedioCardHoverState();
}

class _RemedioCardHoverState extends State<RemedioCardHover> {
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
        child: widget.cardBuilder(_hovered),
      ),
    );
  }
}
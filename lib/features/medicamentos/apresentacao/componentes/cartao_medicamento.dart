import 'package:flutter/material.dart';
import '../../../../core/temas/cores_app.dart';

class MedicamentoCard extends StatelessWidget {
  final Color corLateral;
  final String medico;
  final String especialidade;
  final String crm;
  final String receita;
  final String medicamento;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const MedicamentoCard({
    super.key,
    required this.corLateral,
    required this.medico,
    required this.especialidade,
    required this.crm,
    required this.receita,
    required this.medicamento,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: CoresApp.branco,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            decoration: BoxDecoration(
              color: corLateral,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),

          // Conteúdo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 14, top: 10, right: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'MÉDICO(A): $medico',
                          style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: 0.4,
                            color: CoresApp.textoForte,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.notifications_none, size: 22, color: CoresApp.textoForte),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(especialidade,
                          style: const TextStyle(fontSize: 15, letterSpacing: 0.8, color: CoresApp.textoSecundario)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(crm,
                            style: const TextStyle(fontSize: 10, letterSpacing: 0.8, color: CoresApp.textoSecundario)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (receita.isNotEmpty)
                    Text(
                      'RECEITA: $receita',
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.3,
                        letterSpacing: 0.5,
                        color: CoresApp.textoSecundario,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const Spacer(),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'MEDICAMENTO: $medicamento',
                          style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: 0.8,
                            color: CoresApp.textoForte,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _BotaoAcaoCard(
                        icon: Icons.edit,
                        color: CoresApp.azulCard,
                        onTap: onEditar,
                      ),
                      const SizedBox(width: 8),
                      _BotaoAcaoCard(
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        onTap: onExcluir,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotaoAcaoCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BotaoAcaoCard({required this.icon, required this.color, required this.onTap});

  @override
  State<_BotaoAcaoCard> createState() => _BotaoAcaoCardState();
}

class _BotaoAcaoCardState extends State<_BotaoAcaoCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _hovering ? widget.color.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(widget.icon, size: 20, color: widget.color),
        ),
      ),
    );
  }
}
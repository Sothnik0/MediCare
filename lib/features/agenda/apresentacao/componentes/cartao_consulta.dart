import 'package:flutter/material.dart';
import '../../../../core/temas/cores_app.dart';
import '../../dados/consulta_medica.dart';

class CartaoConsulta extends StatefulWidget {
  final ConsultaMedica consulta;
  final VoidCallback aoAlternarNotificacao;

  const CartaoConsulta({
    Key? key,
    required this.consulta,
    required this.aoAlternarNotificacao,
  }) : super(key: key);

  @override
  State<CartaoConsulta> createState() => _CartaoConsultaState();
}

class _CartaoConsultaState extends State<CartaoConsulta> {
  bool _hoveringNotificacao = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      height: 100,
      decoration: BoxDecoration(
        color: CoresApp.branco,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _construirBarraLateral(),
          Expanded(child: _construirConteudoCartao()),
        ],
      ),
    );
  }

  Widget _construirBarraLateral() {
    return Container(
      width: 35,
      decoration: const BoxDecoration(
        color: CoresApp.azulCard,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
    );
  }

  Widget _construirConteudoCartao() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _construirCabecalhoCartao(),
          _construirEspecialidadeRegistro(),
          const Divider(height: 4, thickness: 0.3),
          _construirRodapeCartao(),
        ],
      ),
    );
  }

  Widget _construirCabecalhoCartao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.consulta.nomeMedico,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CoresApp.textoForte,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hoveringNotificacao = true),
          onExit:  (_) => setState(() => _hoveringNotificacao = false),
          child: GestureDetector(
            onTap: widget.aoAlternarNotificacao,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _hoveringNotificacao
                    ? CoresApp.azulCard.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                widget.consulta.notificacaoAtivada
                    ? Icons.notifications_active
                    : Icons.notifications_none_outlined,
                size: 20,
                color: widget.consulta.notificacaoAtivada
                    ? CoresApp.azulCard
                    : _hoveringNotificacao
                        ? CoresApp.azulCard
                        : CoresApp.textoForte,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirEspecialidadeRegistro() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.consulta.especialidade,
          style: const TextStyle(fontSize: 10, color: CoresApp.textoSecundario),
        ),
        Text(
          widget.consulta.crmRqe,
          style: const TextStyle(fontSize: 10, color: CoresApp.textoSecundario),
        ),
      ],
    );
  }

  Widget _construirRodapeCartao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.consulta.data,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: CoresApp.textoSecundario),
        ),
        Text(
          widget.consulta.horario,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: CoresApp.textoSecundario),
        ),
      ],
    );
  }
}
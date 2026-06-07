import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/temas/cores_app.dart';
import '../../../../core/servicos/agenda_service.dart';
import '../componentes/recortes_nuvem.dart';

class TelaAgendaMedica extends StatefulWidget {
  const TelaAgendaMedica({super.key});

  @override
  State<TelaAgendaMedica> createState() => _TelaAgendaMedicaState();
}

class _TelaAgendaMedicaState extends State<TelaAgendaMedica> {
  final _agendaService = AgendaService();
  final List<String> _dias = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB'];
  String _diaSelecionado = 'SEG';

  void _abrirDialogAdicionar() {
    final medicoCtrl = TextEditingController();
    final espCtrl    = TextEditingController();
    final crmCtrl    = TextEditingController();
    final dataCtrl   = TextEditingController();
    final horCtrl    = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Adicionar Nova Consulta',
          style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold, color: CoresApp.textoForte, fontSize: 20),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                _campo(ctrl: medicoCtrl, label: 'Nome do Médico:'),
                const SizedBox(height: 14),
                _campo(ctrl: espCtrl, label: 'Especialidade (Ex: Cardiologista):'),
                const SizedBox(height: 14),
                _campo(ctrl: crmCtrl, label: 'Número do CRM (Opcional):'),
                const SizedBox(height: 14),
                _campo(
                  ctrl: dataCtrl, 
                  label: 'Dia / Data da Consulta:',
                  keyboardType: TextInputType.number,
                  formatters: [MascaraDataHora(isData: true)],
                  hintText: 'DD/MM/AAAA',
                ),
                const SizedBox(height: 14),
                _campo(
                  ctrl: horCtrl, 
                  label: 'Horário:',
                  keyboardType: TextInputType.number,
                  formatters: [MascaraDataHora(isData: false)],
                  hintText: '00:00',
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('Voltar', style: TextStyle(color: Colors.grey.shade800, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CoresApp.azulCard,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (medicoCtrl.text.isNotEmpty) {
                // INÍCIO
                await _agendaService.adicionar(
                  nomeMedico:    medicoCtrl.text,
                  especialidade: espCtrl.text,
                  crmRqe:        crmCtrl.text,
                  data:          dataCtrl.text,
                  horario:       horCtrl.text,
                );
                // FIM
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('GRAVAR', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(String id, String nomeMedico) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Apagar Consulta?', style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold)),
        content: Text('Tem certeza que deseja apagar a consulta com o Dr(a). $nomeMedico?', style: const TextStyle(fontFamily: 'Serif', fontSize: 16)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: CoresApp.azulCard,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text('Não, Cancelar', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            onPressed: () async {
              // INÍCIO
              await _agendaService.excluir(id);
              // FIM
              
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Consulta apagada com sucesso!', style: TextStyle(fontSize: 15)),
                    backgroundColor: Colors.green,
                  )
                );
              }
            },
            child: const Text('Sim, Apagar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _campo({
    required TextEditingController ctrl,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: CoresApp.textoForte, fontFamily: 'Serif'),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade400)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: CoresApp.azulCard, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          style: const TextStyle(fontSize: 16, fontFamily: 'Serif', fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final emailUsuario = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: _abrirDialogAdicionar,
          backgroundColor: CoresApp.fundoCreme,
          foregroundColor: CoresApp.textoForte,
          elevation: 6,
          child: const Icon(Icons.add, size: 36),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: CoresApp.gradienteBackground),
        child: SafeArea(
          top: false, bottom: false,
          child: Column(
            children: [
              _buildHeader(context, emailUsuario),
              Expanded(
                child: Stack(
                  children: [
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _agendaService.consultasStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('Nenhuma consulta marcada.\nToque no botão azul (+) abaixo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Serif', color: CoresApp.textoForte, fontSize: 16, fontWeight: FontWeight.w500)),
                          );
                        }
                        final consultas = snapshot.data!;
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                          children: [
                            _buildSeletorDias(),
                            const SizedBox(height: 16),
                            ...consultas.map((c) => _buildCartao(c)),
                          ],
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: ClipPath(
                        clipper: RecorteNuvemInferior(),
                        child: Container(height: 80, color: CoresApp.fundoCreme),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String email) {
    return Column(
      children: [
        ClipPath(
          clipper: RecorteNuvemSuperior(),
          child: Container(
            height: 125,
            color: CoresApp.fundoCreme,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipOval(
                  child: Image.asset('assets/images/Logo.png', width: 48, height: 48, fit: BoxFit.cover),
                ),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Conta conectada: $email', style: const TextStyle(fontFamily: 'Serif', fontSize: 14)),
                        duration: const Duration(seconds: 3))),
                  child: const Icon(Icons.notifications_none, size: 32, color: CoresApp.textoForte),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _BotaoVoltarHover(onTap: () => Navigator.pop(context)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: CoresApp.fundoCreme,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text('AGENDA MÉDICA',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: CoresApp.textoForte, fontFamily: 'Serif')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeletorDias() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _dias.map((dia) {
        final selecionado = _diaSelecionado == dia;
        return GestureDetector(
          onTap: () => setState(() => _diaSelecionado = dia),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            decoration: BoxDecoration(
              color: CoresApp.branco,
              borderRadius: BorderRadius.circular(10),
              border: selecionado ? Border.all(color: CoresApp.azulCard, width: 2) : null,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Text(dia,
              style: TextStyle(
                fontSize: 13, fontFamily: 'Serif',
                fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                color: selecionado ? CoresApp.azulCard : CoresApp.textoSecundario,
              )),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCartao(Map<String, dynamic> c) {
    final String id          = c['id'] ?? '';
    final String nomeMedico  = c['nomeMedico'] ?? '';
    final String especialidade = c['especialidade'] ?? '';
    final String crmRqe      = c['crmRqe'] ?? '';
    final String data        = c['data'] ?? '';
    final String horario     = c['horario'] ?? '';
    final bool   notif       = c['notificacaoAtivada'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CoresApp.branco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 125,
            decoration: const BoxDecoration(
              color: CoresApp.azulCard,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(nomeMedico,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CoresApp.textoForte, fontFamily: 'Serif'),
                        overflow: TextOverflow.ellipsis),
                    ),
                    _IconeCartaoHover(
                      corFundoHover: CoresApp.azulCard.withOpacity(0.15),
                      onTap: () async {
                        // INÍCIO
                        await _agendaService.alternarNotificacao(id, notif);
                        // FIM
                      },
                      child: Icon(
                        notif ? Icons.notifications_active : Icons.notifications_none_outlined,
                        size: 26,
                        color: notif ? CoresApp.azulCard : CoresApp.textoForte,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _IconeCartaoHover(
                      corFundoHover: Colors.red.withOpacity(0.15),
                      onTap: () => _confirmarExclusao(id, nomeMedico),
                      child: const Icon(Icons.delete_outline, size: 26, color: Colors.red),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      Text(especialidade, style: const TextStyle(fontSize: 13, color: CoresApp.textoSecundario, fontFamily: 'Serif', fontWeight: FontWeight.w500)),
                      if (crmRqe.isNotEmpty)
                        Text(crmRqe, style: const TextStyle(fontSize: 12, color: CoresApp.textoSecundario, fontFamily: 'Serif')),
                    ],
                  ),
                  const Divider(height: 16, thickness: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: CoresApp.textoSecundario),
                          const SizedBox(width: 4),
                          Text(data, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CoresApp.textoForte, fontFamily: 'Serif')),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: CoresApp.textoSecundario),
                          const SizedBox(width: 4),
                          Text(horario, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CoresApp.textoForte, fontFamily: 'Serif')),
                        ],
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

class _BotaoVoltarHover extends StatefulWidget {
  final VoidCallback onTap;
  const _BotaoVoltarHover({required this.onTap});

  @override
  State<_BotaoVoltarHover> createState() => _BotaoVoltarHoverState();
}

class _BotaoVoltarHoverState extends State<_BotaoVoltarHover> {
  bool _hovered = false;

  void _onEnter(PointerEvent e) => setState(() => _hovered = true);
  void _onExit(PointerEvent e)  => setState(() => _hovered = false);

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
            color: _hovered ? CoresApp.azulCard.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.arrow_back_ios, size: 24, color: _hovered ? CoresApp.azulCard : CoresApp.textoForte),
        ),
      ),
    );
  }
}

class _IconeCartaoHover extends StatefulWidget {
  final Widget child;
  final Color corFundoHover;
  final VoidCallback onTap;

  const _IconeCartaoHover({
    required this.child,
    required this.corFundoHover,
    required this.onTap,
  });

  @override
  State<_IconeCartaoHover> createState() => _IconeCartaoHoverState();
}

class _IconeCartaoHoverState extends State<_IconeCartaoHover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _hovered ? widget.corFundoHover : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class MascaraDataHora extends TextInputFormatter {
  final bool isData;
  MascaraDataHora({required this.isData});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String masked = '';
    int i = 0;
    final mask = isData ? '##/##/####' : '##:##';
    
    for (int m = 0; m < mask.length; m++) {
      if (i >= text.length) break;
      if (mask[m] == '#') {
        masked += text[i];
        i++;
      } else {
        masked += mask[m];
      }
    }
    
    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}
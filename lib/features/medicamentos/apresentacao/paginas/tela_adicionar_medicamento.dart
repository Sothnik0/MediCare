import 'package:flutter/material.dart';
import '../../../../core/temas/cores_app.dart';
import '../../dados/medicamento.dart';

class AdicionarMedicamentoPage extends StatefulWidget {
  final Medicamento? medicamentoExistente;

  const AdicionarMedicamentoPage({super.key, this.medicamentoExistente});

  @override
  State<AdicionarMedicamentoPage> createState() => _AdicionarMedicamentoPageState();
}

class _AdicionarMedicamentoPageState extends State<AdicionarMedicamentoPage> {
  final medicoController       = TextEditingController();
  final especialidadeController = TextEditingController();
  final crmController          = TextEditingController();
  final receitaController      = TextEditingController();
  final medicamentoController  = TextEditingController();

  Color corSelecionada = const Color(0xFF08C98E);

  @override
  void initState() {
    super.initState();
    if (widget.medicamentoExistente != null) {
      final item = widget.medicamentoExistente!;
      medicoController.text       = item.medico;
      especialidadeController.text = item.especialidade;
      crmController.text          = item.crm;
      receitaController.text      = item.receita;
      medicamentoController.text  = item.medicamento;
      corSelecionada              = item.corLateral;
    }
  }

  void salvarMedicamento() {
    if (medicoController.text.isEmpty ||
        especialidadeController.text.isEmpty ||
        crmController.text.isEmpty ||
        medicamentoController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Preencha todos os campos obrigatórios')));
      return;
    }

    Navigator.pop(
      context,
      Medicamento(
        corLateral:    corSelecionada,
        medico:        medicoController.text,
        especialidade: especialidadeController.text,
        crm:           crmController.text,
        receita:       receitaController.text,
        medicamento:   medicamentoController.text,
      ),
    );
  }

  @override
  void dispose() {
    medicoController.dispose();
    especialidadeController.dispose();
    crmController.dispose();
    receitaController.dispose();
    medicamentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool editando = widget.medicamentoExistente != null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: CoresApp.gradienteBackground),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios, color: CoresApp.textoForte, size: 22),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: CoresApp.fundoCreme,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        editando ? 'EDITAR MEDICAMENTO' : 'ADICIONAR MEDICAMENTO',
                        style: const TextStyle(fontSize: 13, letterSpacing: 1.2, color: CoresApp.textoForte),
                      ),
                    ),
                  ],
                ),
              ),

              // Formulário
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _campoTexto(controller: medicoController, label: 'Nome do médico'),
                      const SizedBox(height: 12),
                      _campoTexto(controller: especialidadeController, label: 'Especialidade'),
                      const SizedBox(height: 12),
                      _campoTexto(controller: crmController, label: 'CRM / RQE'),
                      const SizedBox(height: 12),
                      _campoTexto(controller: medicamentoController, label: 'Nome do medicamento'),
                      const SizedBox(height: 12),
                      _campoTexto(controller: receitaController, label: 'Receita médica', maxLines: 4),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Text('Cor lateral:',
                              style: TextStyle(fontSize: 15, color: CoresApp.textoForte)),
                          const SizedBox(width: 14),
                          ...[
                            const Color(0xFF08C98E),
                            const Color(0xFFC92323),
                            CoresApp.azulCard,
                            Colors.orange,
                          ].map(_botaoCor),
                        ],
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: salvarMedicamento,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CoresApp.fundoCreme,
                            foregroundColor: CoresApp.textoForte,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            editando ? 'Salvar alterações' : 'Salvar medicamento',
                            style: const TextStyle(fontSize: 16, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto({required TextEditingController controller, required String label, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: CoresApp.textoSecundario, fontSize: 13),
        filled: true,
        fillColor: CoresApp.fundoCreme,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: CoresApp.azulCard, width: 1.5),
        ),
      ),
    );
  }

  Widget _botaoCor(Color cor) {
    final bool selecionada = corSelecionada == cor;
    return GestureDetector(
      onTap: () => setState(() => corSelecionada = cor),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: cor,
          shape: BoxShape.circle,
          border: Border.all(
            color: selecionada ? CoresApp.textoForte : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/temas/cores_app.dart';
import '../../dados/medicamento.dart';
import '../componentes/cartao_medicamento.dart';
import 'tela_adicionar_medicamento.dart';
import '../../../agenda/apresentacao/componentes/recortes_nuvem.dart';

class GerenciarMedicamentosPage extends StatefulWidget {
  const GerenciarMedicamentosPage({super.key});

  @override
  State<GerenciarMedicamentosPage> createState() =>
      _GerenciarMedicamentosPageState();
}

class _GerenciarMedicamentosPageState extends State<GerenciarMedicamentosPage> {
  final CollectionReference<Map<String, dynamic>> medicamentosRef =
      FirebaseFirestore.instance.collection('medicamentos');

  final TextEditingController _buscaController = TextEditingController();

  String termoBusca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _medicamentoToMap(
    Medicamento medicamento, {
    bool criando = false,
  }) {
    final dados = <String, dynamic>{
      'corLateral': medicamento.corLateral.value,
      'medico': medicamento.medico,
      'especialidade': medicamento.especialidade,
      'crm': medicamento.crm,
      'receita': medicamento.receita,
      'medicamento': medicamento.medicamento,
      'atualizadoEm': FieldValue.serverTimestamp(),
    };

    if (criando) {
      dados['criadoEm'] = FieldValue.serverTimestamp();
    }

    return dados;
  }

  Medicamento _medicamentoFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final dados = doc.data();

    return Medicamento(
      corLateral: Color(dados['corLateral'] ?? 0xFF08C98E),
      medico: dados['medico'] ?? '',
      especialidade: dados['especialidade'] ?? '',
      crm: dados['crm'] ?? '',
      receita: dados['receita'] ?? '',
      medicamento: dados['medicamento'] ?? '',
    );
  }

  Future<void> abrirTelaAdicionarMedicamento() async {
    final resultado = await Navigator.push<Medicamento>(
      context,
      MaterialPageRoute(
        builder: (_) => const AdicionarMedicamentoPage(),
      ),
    );

    if (resultado == null) return;

    try {
      await medicamentosRef.add(
        _medicamentoToMap(resultado, criando: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicamento cadastrado com sucesso'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar medicamento: $e'),
        ),
      );
    }
  }

  Future<void> editarMedicamento(
    String docId,
    Medicamento medicamentoAtual,
  ) async {
    final resultado = await Navigator.push<Medicamento>(
      context,
      MaterialPageRoute(
        builder: (_) => AdicionarMedicamentoPage(
          medicamentoExistente: medicamentoAtual,
        ),
      ),
    );

    if (resultado == null) return;

    try {
      await medicamentosRef.doc(docId).update(
            _medicamentoToMap(resultado),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicamento atualizado com sucesso'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar medicamento: $e'),
        ),
      );
    }
  }

  void confirmarExclusao(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: CoresApp.branco,
        title: const Text(
          'Excluir medicamento',
          style: TextStyle(color: CoresApp.textoForte),
        ),
        content: const Text(
          'Tem certeza que deseja excluir?',
          style: TextStyle(color: CoresApp.textoSecundario),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: CoresApp.textoSecundario),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await medicamentosRef.doc(docId).delete();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Medicamento excluído'),
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir medicamento: $e'),
                  ),
                );
              }
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filtrarDocumentos(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documentos,
  ) {
    if (termoBusca.isEmpty) {
      return documentos;
    }

    return documentos.where((doc) {
      final item = _medicamentoFromDoc(doc);

      final nomeMedicamento = item.medicamento.toLowerCase();
      final nomeMedico = item.medico.toLowerCase();
      final especialidade = item.especialidade.toLowerCase();
      final receita = item.receita.toLowerCase();
      final crm = item.crm.toLowerCase();

      return nomeMedicamento.contains(termoBusca) ||
          nomeMedico.contains(termoBusca) ||
          especialidade.contains(termoBusca) ||
          receita.contains(termoBusca) ||
          crm.contains(termoBusca);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: CoresApp.gradienteBackground,
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipPath(
                clipper: RecorteNuvemInferior(),
                child: Container(
                  height: 80,
                  color: CoresApp.fundoCreme,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildSearchBar(),
                  _buildAddButton(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: medicamentosRef
                          .orderBy('criadoEm', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Erro ao carregar medicamentos',
                              style: TextStyle(
                                color: CoresApp.textoForte,
                                fontSize: 18,
                              ),
                            ),
                          );
                        }

                        final todosDocumentos = snapshot.data?.docs ?? [];
                        final documentos = _filtrarDocumentos(todosDocumentos);

                        if (documentos.isEmpty) {
                          return Center(
                            child: Text(
                              termoBusca.isEmpty
                                  ? 'Nenhum medicamento cadastrado'
                                  : 'Nenhum resultado encontrado',
                              style: const TextStyle(
                                color: CoresApp.textoForte,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 100,
                          ),
                          itemCount: documentos.length,
                          itemBuilder: (context, index) {
                            final doc = documentos[index];
                            final item = _medicamentoFromDoc(doc);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: MedicamentoCard(
                                corLateral: item.corLateral,
                                medico: item.medico,
                                especialidade: item.especialidade,
                                crm: item.crm,
                                receita: item.receita,
                                medicamento: item.medicamento,
                                onEditar: () => editarMedicamento(
                                  doc.id,
                                  item,
                                ),
                                onExcluir: () => confirmarExclusao(
                                  doc.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        ClipPath(
          clipper: RecorteNuvemSuperior(),
          child: Container(
            height: 120,
            color: CoresApp.fundoCreme,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const Icon(
                  Icons.notifications_none,
                  size: 30,
                  color: CoresApp.textoForte,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _BotaoVoltarHover(
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: CoresApp.fundoCreme,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: const Text(
                  'GERENCIAR MEDICAMENTOS',
                  style: TextStyle(
                    fontSize: 15,
                    letterSpacing: 1.2,
                    color: CoresApp.textoForte,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      height: 58,
      decoration: BoxDecoration(
        color: CoresApp.branco,
        borderRadius: BorderRadius.circular(29),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _buscaController,
        onChanged: (valor) {
          setState(() {
            termoBusca = valor.toLowerCase().trim();
          });
        },
        style: const TextStyle(
          fontSize: 18,
          color: CoresApp.textoForte,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar medicamento...',
          hintStyle: const TextStyle(
            fontSize: 17,
            color: CoresApp.textoSecundario,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 28,
            color: CoresApp.textoSecundario,
          ),
          suffixIcon: termoBusca.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 26,
                    color: CoresApp.textoSecundario,
                  ),
                  onPressed: () {
                    _buscaController.clear();

                    setState(() {
                      termoBusca = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.only(
        right: 20,
        bottom: 12,
        top: 4,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: _BotaoAdicionarHover(
          onTap: abrirTelaAdicionarMedicamento,
        ),
      ),
    );
  }
}

class _BotaoVoltarHover extends StatefulWidget {
  final VoidCallback onTap;

  const _BotaoVoltarHover({
    required this.onTap,
  });

  @override
  State<_BotaoVoltarHover> createState() => _BotaoVoltarHoverState();
}

class _BotaoVoltarHoverState extends State<_BotaoVoltarHover> {
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _hovering
                ? CoresApp.azulCard.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_back_ios,
            size: 26,
            color: _hovering ? CoresApp.azulCard : CoresApp.textoForte,
          ),
        ),
      ),
    );
  }
}

class _BotaoAdicionarHover extends StatefulWidget {
  final VoidCallback onTap;

  const _BotaoAdicionarHover({
    required this.onTap,
  });

  @override
  State<_BotaoAdicionarHover> createState() => _BotaoAdicionarHoverState();
}

class _BotaoAdicionarHoverState extends State<_BotaoAdicionarHover> {
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
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _hovering ? CoresApp.azulCard : CoresApp.branco,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovering ? 0.14 : 0.06),
                blurRadius: _hovering ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.add,
            size: 32,
            color: _hovering ? CoresApp.branco : CoresApp.textoForte,
          ),
        ),
      ),
    );
  }
}
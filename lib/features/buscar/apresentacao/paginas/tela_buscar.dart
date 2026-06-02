import 'package:flutter/material.dart';
import '../../../../core/temas/cores_app.dart';
import '../../../agenda/apresentacao/componentes/recortes_nuvem.dart';
import '../../dominio/entidades/remedio.dart';
import '../componentes/botao_voltar_hover.dart';
import '../componentes/remedio_card_hover.dart';

class TelaBuscar extends StatefulWidget {
  const TelaBuscar({super.key});

  @override
  State<TelaBuscar> createState() => _TelaBuscarState();
}

class _TelaBuscarState extends State<TelaBuscar> {
  CategoriaRemedio? _filtroSelecionado;
  String _remedioSelecionado = "";
  bool _abaFavoritos = false;

  final _searchCtrl = TextEditingController();
  String _termoBusca = "";

  final Set<String> _favoritos = {};
  final Set<String> _notificacoes = {};

  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _horarioCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  CategoriaRemedio _categoriaForm = CategoriaRemedio.nenhuma;

  final List<Remedio> _remedios = [
    Remedio(
      nome: "CARDALI",
      horario: "14:00",
      categoria: CategoriaRemedio.cardiaco,
      imagem:
          "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=1200&auto=format&fit=crop",
    ),
    Remedio(
      nome: "MEBENDAZOL",
      horario: "18:00",
      categoria: CategoriaRemedio.dor,
      imagem:
          "https://images.unsplash.com/photo-1587854692152-cbe660dbde88?q=80&w=1200&auto=format&fit=crop",
    ),
    Remedio(
      nome: "SÍBUS",
      horario: "22:00",
      categoria: CategoriaRemedio.vitaminina,
      imagem:
          "https://images.unsplash.com/photo-1471864190281-a93a3070b6de?q=80&w=1200&auto=format&fit=crop",
    ),
  ];

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _horarioCtrl.dispose();
    _obsCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Remedio> get _remediosFiltrados {
    List<Remedio> base = _abaFavoritos
        ? _remedios.where((r) => _favoritos.contains(r.nome)).toList()
        : _remedios;

    if (_filtroSelecionado != null) {
      base = base.where((r) => r.categoria == _filtroSelecionado).toList();
    }

    if (_termoBusca.trim().isNotEmpty) {
      base = base
          .where((r) =>
              r.nome.toLowerCase().contains(_termoBusca.trim().toLowerCase()))
          .toList();
    }

    return base;
  }

  void _toggleFavorito(String nome) => setState(() => _favoritos.contains(nome)
      ? _favoritos.remove(nome)
      : _favoritos.add(nome));

  void _toggleNotificacao(String nome) =>
      setState(() => _notificacoes.contains(nome)
          ? _notificacoes.remove(nome)
          : _notificacoes.add(nome));

  void _excluirRemedio(String nome) {
    setState(() {
      _remedios.removeWhere((r) => r.nome == nome);
      _favoritos.remove(nome);
      _notificacoes.remove(nome);
      if (_remedioSelecionado == nome) _remedioSelecionado = "";
    });
  }

  void _confirmarExclusao(String nome) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CoresApp.nuvemBranco,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "EXCLUIR REMÉDIO",
          style: TextStyle(
              fontFamily: 'Serif', fontSize: 17, color: CoresApp.textoForte),
        ),
        content: Text(
          "Deseja excluir o remédio $nome?",
          style: const TextStyle(fontFamily: 'Serif', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR",
                style: TextStyle(color: Colors.grey, fontFamily: 'Serif')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _excluirRemedio(nome);
            },
            child: const Text("EXCLUIR",
                style: TextStyle(color: Colors.white, fontFamily: 'Serif')),
          ),
        ],
      ),
    );
  }

  void _abrirPopUpNotificacoes() {
    final comNotificacao =
        _remedios.where((r) => _notificacoes.contains(r.nome)).toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: CoresApp.nuvemBranco,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active,
                      color: Color(0xFF008D95), size: 24),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "NOTIFICAÇÕES ATIVAS",
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: CoresApp.textoForte,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        size: 22, color: CoresApp.textoForte),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (comNotificacao.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "Nenhuma notificação ativa.\nToque no 🔔 de um remédio para ativar.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 14,
                        color: CoresApp.textoForte.withOpacity(0.5),
                      ),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: comNotificacao.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final r = comNotificacao[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(r.imagem,
                                  width: 52, height: 52, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.nome,
                                      style: const TextStyle(
                                          fontFamily: 'Serif',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: CoresApp.textoForte)),
                                  const SizedBox(height: 2),
                                  Text("HORÁRIO: ${r.horario}",
                                      style: TextStyle(
                                          fontFamily: 'Serif',
                                          fontSize: 13,
                                          color: CoresApp.textoForte
                                              .withOpacity(0.6))),
                                ],
                              ),
                            ),
                            StatefulBuilder(
                              builder: (context, setLocalState) => MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    _toggleNotificacao(r.nome);
                                    if (_notificacoes.isEmpty) {
                                      Navigator.pop(context);
                                    } else {
                                      setLocalState(() {});
                                    }
                                  },
                                  child: const Icon(Icons.notifications_active,
                                      color: Color(0xFF008D95), size: 26),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirDialogAdicionar() {
    _nomeCtrl.clear();
    _horarioCtrl.clear();
    _obsCtrl.clear();
    _categoriaForm = CategoriaRemedio.nenhuma;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: CoresApp.nuvemBranco,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "ADICIONAR REMÉDIO",
            style: TextStyle(
                fontFamily: 'Serif', fontSize: 18, color: CoresApp.textoForte),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nomeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: "Nome do remédio",
                    labelStyle: TextStyle(fontFamily: 'Serif'),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? "Campo obrigatório"
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _horarioCtrl,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: "Horário (ex: 08:00)",
                    labelStyle: TextStyle(fontFamily: 'Serif'),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? "Campo obrigatório"
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _obsCtrl,
                  decoration: const InputDecoration(
                    labelText: "Observação (opcional)",
                    labelStyle: TextStyle(fontFamily: 'Serif'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "CATEGORIA",
                  style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 13,
                      color: CoresApp.textoForte),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    CategoriaRemedio.dor,
                    CategoriaRemedio.vitaminina,
                    CategoriaRemedio.cardiaco,
                  ].map((cat) {
                    final ativo = _categoriaForm == cat;
                    return GestureDetector(
                      onTap: () => setDialogState(() => _categoriaForm =
                          ativo ? CategoriaRemedio.nenhuma : cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: ativo
                              ? const Color(0xFF008D95)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ativo
                                ? const Color(0xFF008D95)
                                : CoresApp.textoForte.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          cat.label,
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 13,
                            color: ativo ? Colors.white : CoresApp.textoForte,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR",
                  style: TextStyle(color: Colors.grey, fontFamily: 'Serif')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008D95),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _salvarRemedio,
              child: const Text("SALVAR",
                  style: TextStyle(color: Colors.white, fontFamily: 'Serif')),
            ),
          ],
        ),
      ),
    );
  }

  void _salvarRemedio() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _remedios.add(Remedio(
          nome: _nomeCtrl.text.trim().toUpperCase(),
          horario: _horarioCtrl.text.trim(),
          obs: _obsCtrl.text.trim().isEmpty
              ? 'NENHUMA'
              : _obsCtrl.text.trim().toUpperCase(),
          categoria: _categoriaForm,
        ));
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF008D95),
        onPressed: _abrirDialogAdicionar,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: CoresApp.gradienteBackground),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeaderNuvem(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 100),
                      children: [
                        _buildBotoesEAbas(),
                        const SizedBox(height: 24),
                        _buildSearchBar(),
                        const SizedBox(height: 24),
                        if (!_abaFavoritos) _buildFiltros(),
                        if (!_abaFavoritos) const SizedBox(height: 24),
                        _buildListaMedicamentos(),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: RecorteNuvemInferior(),
                  child: Container(height: 80, color: CoresApp.nuvemBranco),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderNuvem() {
    return ClipPath(
      clipper: RecorteNuvemSuperior(),
      child: Container(
        height: 120,
        width: double.infinity,
        color: CoresApp.nuvemBranco,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset('assets/images/Logo.png',
                  width: 55, height: 55, fit: BoxFit.cover),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _abrirPopUpNotificacoes,
                child: Stack(
                  children: [
                    Icon(
                      _notificacoes.isNotEmpty
                          ? Icons.notifications
                          : Icons.notifications_none,
                      size: 38,
                      color: CoresApp.textoForte,
                    ),
                    if (_notificacoes.isNotEmpty)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                              color: Color(0xFF008D95), shape: BoxShape.circle),
                          child: Center(
                            child: Text('${_notificacoes.length}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      )
                    else
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                              color: CoresApp.textoForte,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 10),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotoesEAbas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12),
          child: BotaoVoltarHover(onTap: () => Navigator.pop(context)),
        ),
        Row(
          children: [
            _buildAbaWidget(
              texto: "BUSCAR",
              ativo: !_abaFavoritos,
              onTap: () => setState(() {
                _abaFavoritos = false;
                _termoBusca = "";
                _searchCtrl.clear();
              }),
            ),
            _buildAbaWidget(
              texto: "FAVORITOS",
              ativo: _abaFavoritos,
              onTap: () => setState(() {
                _abaFavoritos = true;
                _termoBusca = "";
                _searchCtrl.clear();
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: CoresApp.nuvemBranco,
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: CoresApp.cianoPrincipal),
            child: Text("MENU",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif')),
          ),
          _buildDrawerItem(Icons.medication, "Medicamentos"),
          _buildDrawerItem(Icons.favorite, "Favoritos"),
          _buildDrawerItem(Icons.notifications, "Lembretes"),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: CoresApp.textoForte),
      title: Text(title,
          style: const TextStyle(fontFamily: 'Serif', fontSize: 16)),
      onTap: () {},
    );
  }

  Widget _buildAbaWidget({
    required String texto,
    required bool ativo,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: ativo ? const Color(0xFF008D95) : CoresApp.cianoClaro,
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
              ],
            ),
            child: Center(
              child: Text(
                texto,
                style: TextStyle(
                  color: ativo
                      ? Colors.white
                      : CoresApp.textoForte.withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Serif',
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  width: 45,
                  height: 45,
                  color: Colors.transparent,
                  child: const Icon(Icons.menu,
                      size: 28, color: CoresApp.textoForte),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _termoBusca = v),
                  onSubmitted: (v) => setState(() => _termoBusca = v),
                  decoration: const InputDecoration(
                    hintText: "Buscar medicamento...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        fontFamily: 'Serif', color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _termoBusca = _searchCtrl.text),
                child: const Icon(Icons.search,
                    size: 32, color: CoresApp.textoForte),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFiltroWidget("DOR", CategoriaRemedio.dor),
          _buildFiltroWidget("VITAMINA", CategoriaRemedio.vitaminina),
          _buildFiltroWidget("CARDÍACO", CategoriaRemedio.cardiaco),
        ],
      ),
    );
  }

  Widget _buildFiltroWidget(String texto, CategoriaRemedio cat) {
    final bool ativo = _filtroSelecionado == cat;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _filtroSelecionado = ativo ? null : cat),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: ativo
                ? Border.all(color: const Color(0xFF008D95), width: 1.5)
                : null,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Text(
            texto,
            style: TextStyle(
              color: ativo ? const Color(0xFF008D95) : CoresApp.textoSecundario,
              fontSize: 14,
              fontFamily: 'Serif',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListaMedicamentos() {
    final lista = _remediosFiltrados;

    if (lista.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            _abaFavoritos
                ? "Nenhum favorito ainda.\nToque no ♡ para favoritar."
                : "Nenhum remédio encontrado.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 16,
              color: CoresApp.textoForte.withOpacity(0.5),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: lista.map((r) => _buildRemedioCard(r)).toList(),
      ),
    );
  }

  Widget _buildRemedioCard(Remedio r) {
    final bool selecionado = _remedioSelecionado == r.nome;
    final bool favoritado = _favoritos.contains(r.nome);
    final bool notificacaoAtiva = _notificacoes.contains(r.nome);

    return RemedioCardHover(
      key: ValueKey(r.nome),
      onTap: () => setState(() => _remedioSelecionado = selecionado ? "" : r.nome),
      cardBuilder: (hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 18),
        height: 125,
        decoration: BoxDecoration(
          color: hovered ? const Color(0xFFE0F5F5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: selecionado
              ? Border.all(color: const Color(0xFF008D95), width: 2)
              : hovered
                  ? Border.all(
                      color: const Color(0xFF008D95).withOpacity(0.4), width: 1)
                  : null,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(r.imagem,
                  width: 120, height: double.infinity, fit: BoxFit.cover),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.nome,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Serif',
                              color: CoresApp.textoForte,
                            ),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => _toggleFavorito(r.nome),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                favoritado
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey('fav_$favoritado'),
                                size: 26,
                                color:
                                    favoritado ? Colors.red : CoresApp.textoForte,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => _toggleNotificacao(r.nome),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                notificacaoAtiva
                                    ? Icons.notifications_active
                                    : Icons.notifications_none,
                                key: ValueKey('notif_$notificacaoAtiva'),
                                size: 28,
                                color: notificacaoAtiva
                                    ? const Color(0xFF008D95)
                                    : CoresApp.textoForte,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => _confirmarExclusao(r.nome),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 26,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "OBS: ${r.obs}",
                          style: TextStyle(
                            fontSize: 13,
                            color: CoresApp.textoForte.withOpacity(0.6),
                            fontFamily: 'Serif',
                          ),
                        ),
                        if (r.categoria != CategoriaRemedio.nenhuma) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF008D95).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              r.categoria.label,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF008D95),
                                fontFamily: 'Serif',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "HORÁRIO: ${r.horario}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: CoresApp.textoForte,
                          fontFamily: 'Serif',
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
    );
  }
}
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/temas/cores_app.dart';
import '../../../agenda/apresentacao/componentes/recortes_nuvem.dart';
import '../../dominio/entidades/remedio.dart';
import '../componentes/botao_voltar_hover.dart';
import '../componentes/remedio_card_hover.dart';
import '../../../../core/servicos/remedios_service.dart';

class TelaBuscar extends StatefulWidget {
  const TelaBuscar({super.key});

  @override
  State<TelaBuscar> createState() => _TelaBuscarState();
}

class _TelaBuscarState extends State<TelaBuscar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _usuarioLogado;
  String? _emailUsuarioLogado;
  bool _validandoAcesso = true;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _favoritosSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _notificacoesSub;

  CategoriaRemedio? _filtroSelecionado;
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

  CollectionReference<Map<String, dynamic>> get _usuariosCollection =>
      _firestore.collection('usuarios');

  DocumentReference<Map<String, dynamic>> get _usuarioRef =>
      _usuariosCollection.doc(_usuarioLogado!.uid);

  CollectionReference<Map<String, dynamic>> get _remediosRef =>
      _usuarioRef.collection('remedios');

  CollectionReference<Map<String, dynamic>> get _favoritosRef =>
      _usuarioRef.collection('favoritos');

  CollectionReference<Map<String, dynamic>> get _notificacoesRef =>
      _usuarioRef.collection('notificacoes');

  @override
  void initState() {
    super.initState();
    _validarUsuarioInstitucional();
  }

  @override
  void dispose() {
    _favoritosSub?.cancel();
    _notificacoesSub?.cancel();
    _nomeCtrl.dispose();
    _horarioCtrl.dispose();
    _obsCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _validarUsuarioInstitucional() async {
    final user = _auth.currentUser;
    final email = user?.email?.trim().toLowerCase();

    if (user == null || email == null || !email.endsWith('@souunit.com.br')) {
      await _bloquearAcesso();
      return;
    }

    _usuarioLogado = user;
    _emailUsuarioLogado = email;

    await _usuarioRef.set({
      'uid': user.uid,
      'email': email,
      'dominio_validado': true,
      'ultimoAcesso': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _ouvirDadosUsuario();

    if (mounted) {
      setState(() {
        _validandoAcesso = false;
      });
    }
  }

  Future<void> _bloquearAcesso() async {
    await _auth.signOut();

    if (!mounted) return;

    setState(() {
      _validandoAcesso = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Acesso negado. Use uma conta institucional @souunit.com.br.',
        ),
        backgroundColor: Colors.red,
      ),
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _ouvirDadosUsuario() {
    _favoritosSub?.cancel();
    _notificacoesSub?.cancel();

    _favoritosSub = _favoritosRef.snapshots().listen((snapshot) {
      if (!mounted) return;

      setState(() {
        _favoritos
          ..clear()
          ..addAll(snapshot.docs.map((doc) => doc.id));
      });
    });

    _notificacoesSub = _notificacoesRef.snapshots().listen((snapshot) {
      if (!mounted) return;

      setState(() {
        _notificacoes
          ..clear()
          ..addAll(snapshot.docs.map((doc) => doc.id));
      });
    });
  }

  String _categoriaToString(CategoriaRemedio categoria) {
    if (categoria == CategoriaRemedio.cardiaco) return 'cardiaco';
    if (categoria == CategoriaRemedio.dor) return 'dor';
    if (categoria == CategoriaRemedio.vitaminina) return 'vitaminina';
    return 'nenhuma';
  }

  CategoriaRemedio _stringToCategoria(dynamic valor) {
    if (valor == 'cardiaco') return CategoriaRemedio.cardiaco;
    if (valor == 'dor') return CategoriaRemedio.dor;
    if (valor == 'vitaminina') return CategoriaRemedio.vitaminina;
    return CategoriaRemedio.nenhuma;
  }

  Remedio _remedioFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final dados = doc.data();

    return Remedio(
      nome: dados['nome'] ?? '',
      horario: dados['horario'] ?? '',
      obs: dados['obs'] ?? 'NENHUMA',
      categoria: _stringToCategoria(dados['categoria']),
      imagem: dados['imagem'] ?? '',
    );
  }

  Future<void> _toggleFavorito(String docId, Remedio remedio) async {
    if (_emailUsuarioLogado == null) return;

    try {
      final docRef = _favoritosRef.doc(docId);

      if (_favoritos.contains(docId)) {
        await docRef.delete();
      } else {
        await docRef.set({
          'ativo': true,
          'remedio_id': docId,
          'remedio_nome': remedio.nome,
          'usuario_logado': _emailUsuarioLogado,
          'criado_por': _emailUsuarioLogado,
          'criado_em': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Erro ao favoritar: $e');
    }
  }

  Future<void> _toggleNotificacao(String docId, Remedio remedio) async {
    if (_emailUsuarioLogado == null) return;

    try {
      final docRef = _notificacoesRef.doc(docId);

      if (_notificacoes.contains(docId)) {
        await docRef.delete();
      } else {
        await docRef.set({
          'ativo': true,
          'remedio_id': docId,
          'remedio_nome': remedio.nome,
          'horario': remedio.horario,
          'usuario_logado': _emailUsuarioLogado,
          'criado_por': _emailUsuarioLogado,
          'criado_em': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Erro na notificação: $e');
    }
  }

  Future<void> _excluirRemedio(String docId) async {
    try {
      await _remediosRef.doc(docId).delete();
      await _favoritosRef.doc(docId).delete();
      await _notificacoesRef.doc(docId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remédio excluído com sucesso!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao excluir: $e');
    }
  }

  Future<void> _salvarRemedio() async {
    if (!_formKey.currentState!.validate()) return;
    if (_emailUsuarioLogado == null) return;

    final nomeFormatado = _nomeCtrl.text.trim().toUpperCase();

    try {
      await _usuarioRef.set({
        'email': _emailUsuarioLogado,
        'ultimoAcesso': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _remediosRef.add({
        'nome': nomeFormatado,
        'horario': _horarioCtrl.text.trim(),
        'obs': _obsCtrl.text.trim().isEmpty
            ? 'NENHUMA'
            : _obsCtrl.text.trim().toUpperCase(),
        'categoria': _categoriaToString(_categoriaForm),
        'imagem':
            'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=1200&auto=format&fit=crop',
        'usuario_logado': _emailUsuarioLogado,
        'criado_por': _emailUsuarioLogado,
        'criado_em': FieldValue.serverTimestamp(),
        'atualizado_em': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicamento cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (erro) {
      debugPrint('Erro ao salvar no Firestore: $erro');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $erro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _atualizarRemedio(String docId) async {
    if (!_formKey.currentState!.validate()) return;
    if (_emailUsuarioLogado == null) return;

    final nomeFormatado = _nomeCtrl.text.trim().toUpperCase();

    try {
      await _remediosRef.doc(docId).update({
        'nome': nomeFormatado,
        'horario': _horarioCtrl.text.trim(),
        'obs': _obsCtrl.text.trim().isEmpty
            ? 'NENHUMA'
            : _obsCtrl.text.trim().toUpperCase(),
        'categoria': _categoriaToString(_categoriaForm),
        'usuario_logado': _emailUsuarioLogado,
        'atualizado_por': _emailUsuarioLogado,
        'atualizado_em': FieldValue.serverTimestamp(),
      });

      if (_favoritos.contains(docId)) {
        await _favoritosRef.doc(docId).set({
          'remedio_nome': nomeFormatado,
          'usuario_logado': _emailUsuarioLogado,
          'atualizado_em': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (_notificacoes.contains(docId)) {
        await _notificacoesRef.doc(docId).set({
          'remedio_nome': nomeFormatado,
          'horario': _horarioCtrl.text.trim(),
          'usuario_logado': _emailUsuarioLogado,
          'atualizado_em': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicamento atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (erro) {
      debugPrint('Erro ao atualizar no Firestore: $erro');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $erro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filtrarDocsDoBanco(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> listaFiltrada = [...docs];

    if (_abaFavoritos) {
      listaFiltrada = listaFiltrada
          .where((doc) => _favoritos.contains(doc.id))
          .toList();
    }

    if (_filtroSelecionado != null) {
      listaFiltrada = listaFiltrada.where((doc) {
        final dados = doc.data();
        return _stringToCategoria(dados['categoria']) == _filtroSelecionado;
      }).toList();
    }

    if (_termoBusca.trim().isNotEmpty) {
      final termo = _termoBusca.trim().toLowerCase();

      listaFiltrada = listaFiltrada.where((doc) {
        final dados = doc.data();
        final nome = (dados['nome'] ?? '').toString().toLowerCase();
        return nome.contains(termo);
      }).toList();
    }

    return listaFiltrada;
  }

  void _confirmarExclusao(String nome, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CoresApp.nuvemBranco,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'EXCLUIR REMÉDIO',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 17,
            color: CoresApp.textoForte,
          ),
        ),
        content: Text(
          'Deseja excluir o remédio $nome?',
          style: const TextStyle(fontFamily: 'Serif', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: Colors.grey, fontFamily: 'Serif'),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _excluirRemedio(docId);
            },
            child: const Text(
              'EXCLUIR',
              style: TextStyle(color: Colors.white, fontFamily: 'Serif'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirPopUpNotificacoes() async {
    final snapshot = await _remediosRef.get();

    final docsComNotificacao = snapshot.docs
        .where((doc) => _notificacoes.contains(doc.id))
        .toList();

    if (!mounted) return;

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
                  const Icon(
                    Icons.notifications_active,
                    color: Color(0xFF008D95),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'NOTIFICAÇÕES ATIVAS',
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
                    child: const Icon(
                      Icons.close,
                      size: 22,
                      color: CoresApp.textoForte,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (docsComNotificacao.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Nenhuma notificação ativa.\nToque no 🔔 de um remédio para ativar.',
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
                    itemCount: docsComNotificacao.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final doc = docsComNotificacao[i];
                      final r = _remedioFromDoc(doc);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                r.imagem,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.nome,
                                    style: const TextStyle(
                                      fontFamily: 'Serif',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: CoresApp.textoForte,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'HORÁRIO: ${r.horario}',
                                    style: TextStyle(
                                      fontFamily: 'Serif',
                                      fontSize: 13,
                                      color: CoresApp.textoForte.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_active,
                                color: Color(0xFF008D95),
                                size: 26,
                              ),
                              onPressed: () {
                                _toggleNotificacao(doc.id, r);
                                Navigator.pop(context);
                              },
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

    _abrirFormularioRemedio(
      titulo: 'ADICIONAR REMÉDIO',
      onSalvar: _salvarRemedio,
    );
  }

  void _abrirDialogEditar(Remedio remedio, String docId) {
    _nomeCtrl.text = remedio.nome;
    _horarioCtrl.text = remedio.horario;
    _obsCtrl.text = remedio.obs == 'NENHUMA' ? '' : remedio.obs;
    _categoriaForm = remedio.categoria;

    _abrirFormularioRemedio(
      titulo: 'EDITAR REMÉDIO',
      onSalvar: () => _atualizarRemedio(docId),
    );
  }

  void _abrirFormularioRemedio({
    required String titulo,
    required VoidCallback onSalvar,
  }) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: CoresApp.nuvemBranco,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            titulo,
            style: const TextStyle(
              fontFamily: 'Serif',
              fontSize: 18,
              color: CoresApp.textoForte,
            ),
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
                    labelText: 'Nome do remédio',
                    labelStyle: TextStyle(fontFamily: 'Serif'),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _horarioCtrl,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'Horário (ex: 08:00)',
                    labelStyle: TextStyle(fontFamily: 'Serif'),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _obsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Observação (opcional)',
                    labelStyle: TextStyle(fontFamily: 'Serif'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'CATEGORIA',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 13,
                    color: CoresApp.textoForte,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      [
                        CategoriaRemedio.dor,
                        CategoriaRemedio.vitaminina,
                        CategoriaRemedio.cardiaco,
                      ].map((cat) {
                        final ativo = _categoriaForm == cat;

                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              _categoriaForm = ativo
                                  ? CategoriaRemedio.nenhuma
                                  : cat;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
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
                                color: ativo
                                    ? Colors.white
                                    : CoresApp.textoForte,
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
              child: const Text(
                'CANCELAR',
                style: TextStyle(color: Colors.grey, fontFamily: 'Serif'),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008D95),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onSalvar,
              child: const Text(
                'SALVAR',
                style: TextStyle(color: Colors.white, fontFamily: 'Serif'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_validandoAcesso) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF008D95)),
        ),
      );
    }

    if (_usuarioLogado == null || _emailUsuarioLogado == null) {
      return const Scaffold(
        body: Center(
          child: Text('Acesso bloqueado. Faça login com e-mail institucional.'),
        ),
      );
    }

    return Scaffold(
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
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _remediosRef
                              .orderBy('criado_em', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text('Erro ao carregar dados.'),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF008D95),
                                ),
                              );
                            }

                            final docsFiltrados = _filtrarDocsDoBanco(
                              snapshot.data!.docs,
                            );

                            if (docsFiltrados.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48,
                                ),
                                child: Center(
                                  child: Text(
                                    _abaFavoritos
                                        ? 'Nenhum favorito ainda.\nToque no ♡ para favoritar.'
                                        : 'Nenhum remédio cadastrado.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Serif',
                                      fontSize: 16,
                                      color: CoresApp.textoForte.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              child: Column(
                                children: docsFiltrados.map((doc) {
                                  final remedio = _remedioFromDoc(doc);
                                  return _buildRemedioCard(remedio, doc.id);
                                }).toList(),
                              ),
                            );
                          },
                        ),
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
              child: Image.asset(
                'assets/images/Logo.png',
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              ),
            ),
            Row(
              children: [
                Text(
                  _emailUsuarioLogado ?? '',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 12,
                    color: CoresApp.textoForte.withOpacity(0.65),
                  ),
                ),
                const SizedBox(width: 12),
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
                                color: Color(0xFF008D95),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${_notificacoes.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
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
              texto: 'BUSCAR',
              ativo: !_abaFavoritos,
              onTap: () {
                setState(() {
                  _abaFavoritos = false;
                  _termoBusca = '';
                  _searchCtrl.clear();
                });
              },
            ),
            _buildAbaWidget(
              texto: 'FAVORITOS',
              ativo: _abaFavoritos,
              onTap: () {
                setState(() {
                  _abaFavoritos = true;
                  _termoBusca = '';
                  _searchCtrl.clear();
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAbaWidget({
    required String texto,
    required bool ativo,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: ativo ? const Color(0xFF008D95) : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            texto,
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 15,
              fontWeight: ativo ? FontWeight.w600 : FontWeight.w400,
              color: ativo ? const Color(0xFF008D95) : CoresApp.textoSecundario,
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
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) {
                    setState(() {
                      _termoBusca = v;
                    });
                  },
                  onSubmitted: (v) {
                    setState(() {
                      _termoBusca = v;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Buscar medicamento...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontFamily: 'Serif',
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _termoBusca = _searchCtrl.text;
                });
              },
              child: const Icon(
                Icons.search,
                size: 32,
                color: CoresApp.textoForte,
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
          _buildFiltroWidget('DOR', CategoriaRemedio.dor),
          _buildFiltroWidget('VITAMINA', CategoriaRemedio.vitaminina),
          _buildFiltroWidget('CARDÍACO', CategoriaRemedio.cardiaco),
        ],
      ),
    );
  }

  Widget _buildFiltroWidget(String texto, CategoriaRemedio cat) {
    final bool ativo = _filtroSelecionado == cat;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroSelecionado = ativo ? null : cat;
        });
      },
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
    );
  }

  Widget _buildRemedioCard(Remedio r, String docId) {
    final bool favoritado = _favoritos.contains(docId);
    final bool notificacaoAtiva = _notificacoes.contains(docId);

    return RemedioCardHover(
      key: ValueKey(docId),
      onTap: () {},
      cardBuilder: (hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 18),
        height: 125,
        decoration: BoxDecoration(
          color: hovered ? const Color(0xFFE0F5F5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: hovered
              ? Border.all(
                  color: const Color(0xFF008D95).withOpacity(0.4),
                  width: 1,
                )
              : null,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                r.imagem,
                width: 120,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
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
                        GestureDetector(
                          onTap: () => _toggleFavorito(docId, r),
                          child: Icon(
                            favoritado ? Icons.favorite : Icons.favorite_border,
                            size: 26,
                            color: favoritado
                                ? Colors.red
                                : CoresApp.textoForte,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _toggleNotificacao(docId, r),
                          child: Icon(
                            notificacaoAtiva
                                ? Icons.notifications_active
                                : Icons.notifications_none,
                            size: 28,
                            color: notificacaoAtiva
                                ? const Color(0xFF008D95)
                                : CoresApp.textoForte,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _abrirDialogEditar(r, docId),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 25,
                            color: Color(0xFF008D95),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _confirmarExclusao(r.nome, docId),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 26,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'OBS: ${r.obs}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: CoresApp.textoForte.withOpacity(0.6),
                              fontFamily: 'Serif',
                            ),
                          ),
                        ),
                        if (r.categoria != CategoriaRemedio.nenhuma) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
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
                        'HORÁRIO: ${r.horario}',
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

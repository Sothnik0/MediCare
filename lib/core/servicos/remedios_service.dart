import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:medicare/features/buscar/dominio/entidades/remedio.dart';

class RemediosService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get usuarioAtual => _auth.currentUser;

  String? get emailUsuarioAtual =>
      _auth.currentUser?.email?.trim().toLowerCase();

  bool get usuarioInstitucionalValido {
    final email = emailUsuarioAtual;

    return usuarioAtual != null &&
        email != null &&
        email.endsWith('@souunit.com.br');
  }

  DocumentReference<Map<String, dynamic>> get usuarioRef {
    final user = usuarioAtual;

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    return _firestore.collection('usuarios').doc(user.uid);
  }

  CollectionReference<Map<String, dynamic>> get remediosRef =>
      usuarioRef.collection('remedios');

  CollectionReference<Map<String, dynamic>> get favoritosRef =>
      usuarioRef.collection('favoritos');

  CollectionReference<Map<String, dynamic>> get notificacoesRef =>
      usuarioRef.collection('notificacoes');

  Future<void> validarUsuarioInstitucional() async {
    final user = usuarioAtual;
    final email = emailUsuarioAtual;

    if (user == null || email == null || !email.endsWith('@souunit.com.br')) {
      await logout();
      throw Exception(
        'Acesso negado. Use uma conta institucional @souunit.com.br.',
      );
    }

    await usuarioRef.set({
      'uid': user.uid,
      'email': email,
      'dominio_validado': true,
      'ultimoAcesso': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> ouvirRemedios() {
    return remediosRef.orderBy('criado_em', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> ouvirFavoritos() {
    return favoritosRef.snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> ouvirNotificacoes() {
    return notificacoesRef.snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> buscarRemediosUmaVez() {
    return remediosRef.get();
  }

  Future<void> adicionarRemedio({
    required String nome,
    required String horario,
    required String obs,
    required CategoriaRemedio categoria,
  }) async {
    await validarUsuarioInstitucional();

    final email = emailUsuarioAtual!;

    await remediosRef.add({
      'nome': nome.trim().toUpperCase(),
      'horario': horario.trim(),
      'obs': obs.trim().isEmpty ? 'NENHUMA' : obs.trim().toUpperCase(),
      'categoria': categoriaToString(categoria),
      'imagem':
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=1200&auto=format&fit=crop',
      'usuario_logado': email,
      'criado_por': email,
      'criado_em': FieldValue.serverTimestamp(),
      'atualizado_em': FieldValue.serverTimestamp(),
    });
  }

  Future<void> atualizarRemedio({
    required String docId,
    required String nome,
    required String horario,
    required String obs,
    required CategoriaRemedio categoria,
    required bool favoritado,
    required bool notificacaoAtiva,
  }) async {
    await validarUsuarioInstitucional();

    final email = emailUsuarioAtual!;
    final nomeFormatado = nome.trim().toUpperCase();

    await remediosRef.doc(docId).update({
      'nome': nomeFormatado,
      'horario': horario.trim(),
      'obs': obs.trim().isEmpty ? 'NENHUMA' : obs.trim().toUpperCase(),
      'categoria': categoriaToString(categoria),
      'usuario_logado': email,
      'atualizado_por': email,
      'atualizado_em': FieldValue.serverTimestamp(),
    });

    if (favoritado) {
      await favoritosRef.doc(docId).set({
        'remedio_nome': nomeFormatado,
        'usuario_logado': email,
        'atualizado_em': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (notificacaoAtiva) {
      await notificacoesRef.doc(docId).set({
        'remedio_nome': nomeFormatado,
        'horario': horario.trim(),
        'usuario_logado': email,
        'atualizado_em': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> excluirRemedio(String docId) async {
    await validarUsuarioInstitucional();

    await remediosRef.doc(docId).delete();
    await favoritosRef.doc(docId).delete();
    await notificacoesRef.doc(docId).delete();
  }

  Future<void> alternarFavorito({
    required String docId,
    required Remedio remedio,
    required bool jaEstaFavoritado,
  }) async {
    await validarUsuarioInstitucional();

    final email = emailUsuarioAtual!;
    final docRef = favoritosRef.doc(docId);

    if (jaEstaFavoritado) {
      await docRef.delete();
    } else {
      await docRef.set({
        'ativo': true,
        'remedio_id': docId,
        'remedio_nome': remedio.nome,
        'usuario_logado': email,
        'criado_por': email,
        'criado_em': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> alternarNotificacao({
    required String docId,
    required Remedio remedio,
    required bool jaEstaAtiva,
  }) async {
    await validarUsuarioInstitucional();

    final email = emailUsuarioAtual!;
    final docRef = notificacoesRef.doc(docId);

    if (jaEstaAtiva) {
      await docRef.delete();
    } else {
      await docRef.set({
        'ativo': true,
        'remedio_id': docId,
        'remedio_nome': remedio.nome,
        'horario': remedio.horario,
        'usuario_logado': email,
        'criado_por': email,
        'criado_em': FieldValue.serverTimestamp(),
      });
    }
  }

  Remedio remedioFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final dados = doc.data();

    return Remedio(
      nome: dados['nome'] ?? '',
      horario: dados['horario'] ?? '',
      obs: dados['obs'] ?? 'NENHUMA',
      categoria: stringToCategoria(dados['categoria']),
      imagem: dados['imagem'] ?? '',
    );
  }

  String categoriaToString(CategoriaRemedio categoria) {
    if (categoria == CategoriaRemedio.cardiaco) return 'cardiaco';
    if (categoria == CategoriaRemedio.dor) return 'dor';
    if (categoria == CategoriaRemedio.vitaminina) return 'vitaminina';
    return 'nenhuma';
  }

  CategoriaRemedio stringToCategoria(dynamic valor) {
    if (valor == 'cardiaco') return CategoriaRemedio.cardiaco;
    if (valor == 'dor') return CategoriaRemedio.dor;
    if (valor == 'vitaminina') return CategoriaRemedio.vitaminina;
    return CategoriaRemedio.nenhuma;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

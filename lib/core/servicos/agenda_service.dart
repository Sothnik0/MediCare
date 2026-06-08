import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgendaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _colecao {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não logado');
    }
    return _firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('consultas');
  }

  // INÍCIO
  Stream<List<Map<String, dynamic>>> consultasStream() {
    try {
      return _colecao
          .orderBy('criado_em', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final dados = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'nomeMedico': dados['nomeMedico'] ?? '',
            'especialidade': dados['especialidade'] ?? '',
            'crmRqe': dados['crmRqe'] ?? '',
            'data': dados['data'] ?? '',
            'horario': dados['horario'] ?? '',
            'notificacaoAtivada': dados['notificacaoAtivada'] ?? false,
            'criado_por': dados['criado_por'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print("Erro ao obter stream: $e");
      return Stream.value([]);
    }
  }
  // FIM

  // INÍCIO
  Future<void> adicionar({
    required String nomeMedico,
    required String especialidade,
    required String crmRqe,
    required String data,
    required String horario,
  }) async {
    try {
      final user = _auth.currentUser;
      final String emailLogado = user?.email ?? 'usuario_desconhecido';

      print('☁️ [Firestore] Salvando nova consulta no caminho: usuarios/${user?.uid}/consultas');

      await _colecao.add({
        'nomeMedico': nomeMedico,
        'especialidade': especialidade,
        'crmRqe': crmRqe,
        'data': data,
        'horario': horario,
        'notificacaoAtivada': false,
        'criado_por': emailLogado,
        'criado_em': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Erro ao adicionar consulta: $e");
      rethrow;
    }
  }
  // FIM

  // INÍCIO
  Future<void> alternarNotificacao(String id, bool statusAtual) async {
    try {
      print('☁️ [Firestore] Atualizando notificação da consulta ID: $id');
      await _colecao.doc(id).update({
        'notificacaoAtivada': !statusAtual,
      });
    } catch (e) {
      print("Erro ao atualizar notificação: $e");
      rethrow;
    }
  }
  // FIM

  // INÍCIO
  Future<void> excluir(String id) async {
    try {
      print('☁️ [Firestore] Excluindo consulta ID: $id');
      await _colecao.doc(id).delete();
    } catch (e) {
      print("Erro ao excluir consulta: $e");
      rethrow;
    }
  }
  // FIM
}
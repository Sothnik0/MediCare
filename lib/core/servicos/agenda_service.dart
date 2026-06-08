import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgendaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _colecao = 'consultas';


  Stream<List<Map<String, dynamic>>> consultasStream() {
    return _firestore
        .collection(_colecao)
        .orderBy('criado_em', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final dados = doc.data();
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
  }

  Future<void> adicionar({
    required String nomeMedico,
    required String especialidade,
    required String crmRqe,
    required String data,
    required String horario,
  }) async {
    try { //INICIO
      final String emailLogado = _auth.currentUser?.email ?? 'usuario_desconhecido';

      await _firestore.collection(_colecao).add({
        'nomeMedico': nomeMedico,
        'especialidade': especialidade,
        'crmRqe': crmRqe,
        'data': data,
        'horario': horario,
        'notificacaoAtivada': false,
        'criado_por': emailLogado,
        'criado_em': FieldValue.serverTimestamp(),
      }); //FIM
    } catch (e) {
      print("Erro ao adicionar consulta: $e");
      rethrow;
    }
  }

  Future<void> alternarNotificacao(String id, bool statusAtual) async {
    try { //INICIO
      await _firestore.collection(_colecao).doc(id).update({
        'notificacaoAtivada': !statusAtual,
      });
    } catch (e) {
      print("Erro ao atualizar notificação: $e");
      rethrow;
    }//FIM
  }

  Future<void> excluir(String id) async {
    try {//INICIO
      await _firestore.collection(_colecao).doc(id).delete();
    } catch (e) {
      print("Erro ao excluir consulta: $e");
      rethrow;
    }//FIM
  }
}
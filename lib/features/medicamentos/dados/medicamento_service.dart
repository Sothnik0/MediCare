import 'package:cloud_firestore/cloud_firestore.dart';
import 'medicamento.dart';

class MedicamentoService {
  final CollectionReference medicamentosRef =
      FirebaseFirestore.instance.collection('medicamentos');

  Stream<List<Medicamento>> listarMedicamentos() {
    return medicamentosRef
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Medicamento.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> adicionarMedicamento(Medicamento medicamento) async {
    await medicamentosRef.add(medicamento.toMap());
  }

  Future<void> editarMedicamento(Medicamento medicamento) async {
    if (medicamento.id == null) return;

    await medicamentosRef.doc(medicamento.id).update({
      'corLateral': medicamento.corLateral.value,
      'medico': medicamento.medico,
      'especialidade': medicamento.especialidade,
      'crm': medicamento.crm,
      'receita': medicamento.receita,
      'medicamento': medicamento.medicamento,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> excluirMedicamento(String id) async {
    await medicamentosRef.doc(id).delete();
  }
}
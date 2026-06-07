import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Medicamento {
  final String? id;
  final Color corLateral;
  final String medico;
  final String especialidade;
  final String crm;
  final String receita;
  final String medicamento;

  Medicamento({
    this.id,
    required this.corLateral,
    required this.medico,
    required this.especialidade,
    required this.crm,
    required this.receita,
    required this.medicamento,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'corLateral': corLateral.value,
      'medico': medico,
      'especialidade': especialidade,
      'crm': crm,
      'receita': receita,
      'medicamento': medicamento,
      'criadoEm': FieldValue.serverTimestamp(),
    };
  }

  factory Medicamento.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Medicamento(
      id: doc.id,
      corLateral: Color(data['corLateral'] ?? 0xFF08C98E),
      medico: data['medico'] ?? '',
      especialidade: data['especialidade'] ?? '',
      crm: data['crm'] ?? '',
      receita: data['receita'] ?? '',
      medicamento: data['medicamento'] ?? '',
    );
  }
}
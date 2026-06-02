import 'package:flutter/material.dart';

class Medicamento {
  final Color corLateral;
  final String medico;
  final String especialidade;
  final String crm;
  final String receita;
  final String medicamento;

  Medicamento({
    required this.corLateral,
    required this.medico,
    required this.especialidade,
    required this.crm,
    required this.receita,
    required this.medicamento,
  });
}
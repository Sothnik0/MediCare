class ConsultaMedica {
  final String nomeMedico;
  final String especialidade;
  final String crmRqe;
  final String data;
  final String horario;
  bool notificacaoAtivada;

  ConsultaMedica({
    required this.nomeMedico,
    required this.especialidade,
    required this.crmRqe,
    required this.data,
    required this.horario,
    this.notificacaoAtivada = false,
  });

  void alternarNotificacao() {
    notificacaoAtivada = !notificacaoAtivada;
  }
}

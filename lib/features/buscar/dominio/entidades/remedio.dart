enum CategoriaRemedio { nenhuma, dor, vitaminina, cardiaco }

extension CategoriaLabel on CategoriaRemedio {
  String get label {
    switch (this) {
      case CategoriaRemedio.dor:
        return 'DOR';
      case CategoriaRemedio.vitaminina:
        return 'VITAMINA';
      case CategoriaRemedio.cardiaco:
        return 'CARDÍACO';
      case CategoriaRemedio.nenhuma:
        return 'NENHUMA';
    }
  }
}

class Remedio {
  final String nome;
  final String horario;
  final String obs;
  final String imagem;
  final CategoriaRemedio categoria;

  Remedio({
    required this.nome,
    required this.horario,
    this.obs = 'NENHUMA',
    this.imagem =
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=1200&auto=format&fit=crop',
    this.categoria = CategoriaRemedio.nenhuma,
  });
}

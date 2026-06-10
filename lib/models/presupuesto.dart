import 'categoria.dart';

class Presupuesto {
  final int? id;
  final Categoria categoria;
  final double limite;
  final int mes;
  final int anio;

  Presupuesto({
    this.id,
    required this.categoria,
    required this.limite,
    required this.mes,
    required this.anio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoria': categoria.name,
      'limite': limite,
      'mes': mes,
      'anio': anio,
    };
  }

  factory Presupuesto.fromMap(Map<String, dynamic> map) {
    return Presupuesto(
      id: map['id'] as int?,
      categoria: Categoria.values.byName(map['categoria'] as String),
      limite: (map['limite'] as num).toDouble(),
      mes: map['mes'] as int,
      anio: map['anio'] as int,
    );
  }
}

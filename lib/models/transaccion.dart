import 'categoria.dart';

enum TipoTransaccion { ingreso, egreso }

class Transaccion {
  final int? id;
  final double monto;
  final TipoTransaccion tipo;
  final String descripcion;
  final DateTime fecha;
  final Categoria categoria;

  Transaccion({
    this.id,
    required this.monto,
    required this.tipo,
    required this.descripcion,
    required this.fecha,
    required this.categoria,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monto': monto,
      'tipo': tipo.name,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'categoria': categoria.name,
    };
  }

  factory Transaccion.fromMap(Map<String, dynamic> map) {
    return Transaccion(
      id: map['id'] as int?,
      monto: (map['monto'] as num).toDouble(),
      tipo: TipoTransaccion.values.byName(map['tipo'] as String),
      descripcion: map['descripcion'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      categoria: Categoria.values.byName(map['categoria'] as String),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/transaccion.dart';
import '../models/presupuesto.dart';
import '../models/categoria.dart';
import 'database_service.dart';
import 'notificacion_service.dart';

class FinanzlyState extends ChangeNotifier {
  final _db = DatabaseService();
  final _notif = NotificacionService();

  List<Transaccion> _transacciones = [];
  List<Presupuesto> _presupuestos = [];
  double _ingresos = 0;
  double _egresos = 0;
  Map<Categoria, double> _gastosPorCategoria = {};

  List<Transaccion> get transacciones => _transacciones;
  List<Presupuesto> get presupuestos => _presupuestos;
  double get ingresos => _ingresos;
  double get egresos => _egresos;
  double get saldo => _ingresos - _egresos;
  Map<Categoria, double> get gastosPorCategoria => _gastosPorCategoria;

  int get _mes => DateTime.now().month;
  int get _anio => DateTime.now().year;

  Future<void> cargarDatos() async {
    _transacciones = await _db.obtenerTransaccionesMes(_mes, _anio);
    _presupuestos = await _db.obtenerPresupuestos(_mes, _anio);
    _ingresos = await _db.totalIngresosMes(_mes, _anio);
    _egresos = await _db.totalEgresosMes(_mes, _anio);
    _gastosPorCategoria = await _db.gastosPorCategoria(_mes, _anio);
    notifyListeners();
  }

  Future<void> agregarTransaccion(Transaccion t) async {
    if (t.monto <= 0) throw ArgumentError('El monto debe ser mayor a cero.');
    await _db.insertarTransaccion(t);
    await cargarDatos();
    if (t.tipo == TipoTransaccion.egreso) {
      await _verificarPresupuesto(t.categoria);
    }
  }

  Future<void> guardarPresupuesto(Presupuesto p) async {
    await _db.guardarPresupuesto(p);
    await cargarDatos();
  }

  Future<double> gastoActualCategoria(Categoria cat) async {
    return _db.sumaGastosMesCategoria(cat, _mes, _anio);
  }

  Future<void> _verificarPresupuesto(Categoria cat) async {
    final pres = _presupuestos.where((p) => p.categoria == cat);
    if (pres.isEmpty) return;
    final limite = pres.first.limite;
    final gastado = await _db.sumaGastosMesCategoria(cat, _mes, _anio);
    final porcentaje = ((gastado / limite) * 100).round();
    if (porcentaje >= 80) {
      await _notif.mostrarAlertaPresupuesto(
        categoria: cat.label,
        porcentaje: porcentaje,
      );
    }
  }
}

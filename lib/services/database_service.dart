import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaccion.dart';
import '../models/presupuesto.dart';
import '../models/categoria.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'finanzly.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transacciones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            monto REAL NOT NULL,
            tipo TEXT NOT NULL,
            descripcion TEXT NOT NULL,
            fecha TEXT NOT NULL,
            categoria TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE presupuestos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            categoria TEXT NOT NULL,
            limite REAL NOT NULL,
            mes INTEGER NOT NULL,
            anio INTEGER NOT NULL,
            UNIQUE(categoria, mes, anio)
          )
        ''');
      },
    );
  }

  // ── Transacciones ──────────────────────────────────────────────────────

  Future<int> insertarTransaccion(Transaccion t) async {
    final db = await database;
    return db.insert('transacciones', t.toMap()..remove('id'));
  }

  Future<List<Transaccion>> obtenerTransacciones() async {
    final db = await database;
    final maps = await db.query('transacciones', orderBy: 'fecha DESC');
    return maps.map(Transaccion.fromMap).toList();
  }

  Future<List<Transaccion>> obtenerTransaccionesMes(int mes, int anio) async {
    final db = await database;
    final inicio = DateTime(anio, mes, 1).toIso8601String();
    final fin = DateTime(anio, mes + 1, 1).toIso8601String();
    final maps = await db.query(
      'transacciones',
      where: 'fecha >= ? AND fecha < ?',
      whereArgs: [inicio, fin],
      orderBy: 'fecha DESC',
    );
    return maps.map(Transaccion.fromMap).toList();
  }

  Future<double> sumaGastosMesCategoria(
      Categoria cat, int mes, int anio) async {
    final db = await database;
    final inicio = DateTime(anio, mes, 1).toIso8601String();
    final fin = DateTime(anio, mes + 1, 1).toIso8601String();
    final result = await db.rawQuery(
      '''SELECT COALESCE(SUM(monto), 0) as total
         FROM transacciones
         WHERE tipo = 'egreso'
           AND categoria = ?
           AND fecha >= ? AND fecha < ?''',
      [cat.name, inicio, fin],
    );
    return (result.first['total'] as num).toDouble();
  }

  // ── Presupuestos ──────────────────────────────────────────────────────

  Future<int> guardarPresupuesto(Presupuesto p) async {
    final db = await database;
    return db.insert(
      'presupuestos',
      p.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Presupuesto>> obtenerPresupuestos(int mes, int anio) async {
    final db = await database;
    final maps = await db.query(
      'presupuestos',
      where: 'mes = ? AND anio = ?',
      whereArgs: [mes, anio],
    );
    return maps.map(Presupuesto.fromMap).toList();
  }

  // ── Estadísticas ──────────────────────────────────────────────────────

  Future<Map<Categoria, double>> gastosPorCategoria(
      int mes, int anio) async {
    final db = await database;
    final inicio = DateTime(anio, mes, 1).toIso8601String();
    final fin = DateTime(anio, mes + 1, 1).toIso8601String();
    final results = await db.rawQuery(
      '''SELECT categoria, SUM(monto) as total
         FROM transacciones
         WHERE tipo = 'egreso'
           AND fecha >= ? AND fecha < ?
         GROUP BY categoria''',
      [inicio, fin],
    );
    final map = <Categoria, double>{};
    for (final row in results) {
      final cat = Categoria.values.byName(row['categoria'] as String);
      map[cat] = (row['total'] as num).toDouble();
    }
    return map;
  }

  Future<double> totalIngresosMes(int mes, int anio) async {
    final db = await database;
    final inicio = DateTime(anio, mes, 1).toIso8601String();
    final fin = DateTime(anio, mes + 1, 1).toIso8601String();
    final r = await db.rawQuery(
      '''SELECT COALESCE(SUM(monto), 0) as total
         FROM transacciones WHERE tipo = 'ingreso'
         AND fecha >= ? AND fecha < ?''',
      [inicio, fin],
    );
    return (r.first['total'] as num).toDouble();
  }

  Future<double> totalEgresosMes(int mes, int anio) async {
    final db = await database;
    final inicio = DateTime(anio, mes, 1).toIso8601String();
    final fin = DateTime(anio, mes + 1, 1).toIso8601String();
    final r = await db.rawQuery(
      '''SELECT COALESCE(SUM(monto), 0) as total
         FROM transacciones WHERE tipo = 'egreso'
         AND fecha >= ? AND fecha < ?''',
      [inicio, fin],
    );
    return (r.first['total'] as num).toDouble();
  }
}

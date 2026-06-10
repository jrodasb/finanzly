import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/finanzly_state.dart';
import '../theme.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  static const _colores = [
    AppTheme.esmeralda,
    AppTheme.coral,
    Colors.amber,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.orangeAccent,
    Colors.pinkAccent,
    Colors.cyanAccent,
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FinanzlyState>();
    final gastos = state.gastosPorCategoria;

    if (gastos.isEmpty) {
      return const Center(
        child: Text(
          'Sin datos para mostrar.\nRegistra transacciones primero.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    final total = gastos.values.fold(0.0, (a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución de gastos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          // Gráfico de dona
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 240,
                child: PieChart(
                  PieChartData(
                    sections: gastos.entries.map((e) {
                      final idx = e.key.index % _colores.length;
                      final pct = (e.value / total * 100).round();
                      return PieChartSectionData(
                        value: e.value,
                        title: '$pct%',
                        color: _colores[idx],
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Leyenda
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: gastos.entries.map((e) {
                  final idx = e.key.index % _colores.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _colores[idx],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${e.key.icono} ${e.key.label}',
                          ),
                        ),
                        Text(
                          '\$${e.value.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Resumen
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ResumenRow(
                    label: 'Total ingresos',
                    valor: state.ingresos,
                    color: AppTheme.esmeralda,
                  ),
                  const Divider(color: Colors.white12),
                  _ResumenRow(
                    label: 'Total egresos',
                    valor: state.egresos,
                    color: AppTheme.coral,
                  ),
                  const Divider(color: Colors.white12),
                  _ResumenRow(
                    label: 'Saldo',
                    valor: state.saldo,
                    color: state.saldo >= 0
                        ? AppTheme.esmeralda
                        : AppTheme.coral,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenRow extends StatelessWidget {
  final String label;
  final double valor;
  final Color color;

  const _ResumenRow({
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '\$${valor.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/finanzly_state.dart';
import '../models/transaccion.dart';
import '../theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FinanzlyState>();
    final recientes = state.transacciones.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de saldo
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.esmeralda.withAlpha(51),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo del mes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white60,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${state.saldo.toStringAsFixed(0)}',
                    style:
                        Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: state.saldo >= 0
                                  ? AppTheme.esmeralda
                                  : AppTheme.coral,
                            ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MiniStat(
                        label: 'Ingresos',
                        valor: state.ingresos,
                        color: AppTheme.esmeralda,
                        icono: Icons.arrow_upward,
                      ),
                      const SizedBox(width: 24),
                      _MiniStat(
                        label: 'Egresos',
                        valor: state.egresos,
                        color: AppTheme.coral,
                        icono: Icons.arrow_downward,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Mini gráfico
          if (state.gastosPorCategoria.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sections: state.gastosPorCategoria.entries.map((e) {
                        final colors = [
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
                        final idx = e.key.index % colors.length;
                        return PieChartSectionData(
                          value: e.value,
                          title: e.key.icono,
                          color: colors[idx],
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 16),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Últimas transacciones
          Text(
            'Últimas transacciones',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (recientes.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Sin transacciones este mes.',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            )
          else
            ...recientes.map((t) => _TransaccionTile(transaccion: t)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double valor;
  final Color color;
  final IconData icono;

  const _MiniStat({
    required this.label,
    required this.valor,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          '$label: \$${valor.toStringAsFixed(0)}',
          style: TextStyle(color: color, fontSize: 13),
        ),
      ],
    );
  }
}

class _TransaccionTile extends StatelessWidget {
  final Transaccion transaccion;
  const _TransaccionTile({required this.transaccion});

  @override
  Widget build(BuildContext context) {
    final esIngreso = transaccion.tipo == TipoTransaccion.ingreso;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Text(
          transaccion.categoria.icono,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(transaccion.descripcion),
        subtitle: Text(
          '${transaccion.fecha.day}/${transaccion.fecha.month}/${transaccion.fecha.year}',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing: Text(
          '${esIngreso ? '+' : '-'}\$${transaccion.monto.toStringAsFixed(0)}',
          style: TextStyle(
            color: esIngreso ? AppTheme.esmeralda : AppTheme.coral,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

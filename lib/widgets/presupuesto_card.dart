import 'package:flutter/material.dart';
import '../models/presupuesto.dart';
import '../theme.dart';

class PresupuestoCard extends StatelessWidget {
  final Presupuesto presupuesto;
  final double gastado;

  const PresupuestoCard({
    super.key,
    required this.presupuesto,
    required this.gastado,
  });

  @override
  Widget build(BuildContext context) {
    final porcentaje =
        presupuesto.limite > 0 ? (gastado / presupuesto.limite) : 0.0;
    final porcentajeInt = (porcentaje * 100).round();
    final color = porcentaje < 0.5
        ? AppTheme.esmeralda
        : porcentaje < 0.8
            ? Colors.amber
            : AppTheme.coral;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${presupuesto.categoria.icono} ${presupuesto.categoria.label}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$porcentajeInt%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: porcentaje.clamp(0.0, 1.0),
                backgroundColor: Colors.white12,
                color: color,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '\$${gastado.toStringAsFixed(0)} / \$${presupuesto.limite.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white60,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

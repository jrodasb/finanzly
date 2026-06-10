import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/presupuesto.dart';
import '../models/categoria.dart';
import '../services/finanzly_state.dart';
import '../widgets/presupuesto_card.dart';

class PresupuestosScreen extends StatelessWidget {
  const PresupuestosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FinanzlyState>();
    final presupuestos = state.presupuestos;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Presupuestos del mes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _mostrarDialogoNuevo(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: presupuestos.isEmpty
              ? const Center(
                  child: Text(
                    'Sin presupuestos configurados.\nToca + para agregar uno.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38),
                  ),
                )
              : ListView.builder(
                  itemCount: presupuestos.length,
                  itemBuilder: (_, i) {
                    final p = presupuestos[i];
                    return FutureBuilder<double>(
                      future: state.gastoActualCategoria(p.categoria),
                      builder: (_, snap) {
                        return PresupuestoCard(
                          presupuesto: p,
                          gastado: snap.data ?? 0,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _mostrarDialogoNuevo(BuildContext context) {
    Categoria categoria = Categoria.comida;
    final limiteCtrl = TextEditingController();
    final now = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nuevo presupuesto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Categoria>(
                value: categoria,
                decoration:
                    const InputDecoration(labelText: 'Categoría'),
                items: Categoria.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${c.icono} ${c.label}'),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setDialogState(() => categoria = v);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: limiteCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Límite mensual',
                  prefixText: '\$ ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final limite = double.tryParse(limiteCtrl.text);
                if (limite == null || limite <= 0) return;
                final p = Presupuesto(
                  categoria: categoria,
                  limite: limite,
                  mes: now.month,
                  anio: now.year,
                );
                context.read<FinanzlyState>().guardarPresupuesto(p);
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

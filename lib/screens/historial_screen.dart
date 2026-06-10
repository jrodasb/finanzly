import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaccion.dart';
import '../models/categoria.dart';
import '../services/finanzly_state.dart';
import '../theme.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  Categoria? _filtroCategoria;
  TipoTransaccion? _filtroTipo;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FinanzlyState>();
    var lista = state.transacciones;

    if (_filtroCategoria != null) {
      lista = lista.where((t) => t.categoria == _filtroCategoria).toList();
    }
    if (_filtroTipo != null) {
      lista = lista.where((t) => t.tipo == _filtroTipo).toList();
    }

    return Column(
      children: [
        // Filtros
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Categoria?>(
                  value: _filtroCategoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas')),
                    ...Categoria.values.map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${c.icono} ${c.label}'),
                        )),
                  ],
                  onChanged: (v) => setState(() => _filtroCategoria = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<TipoTransaccion?>(
                  value: _filtroTipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(
                        value: TipoTransaccion.ingreso,
                        child: Text('Ingresos')),
                    DropdownMenuItem(
                        value: TipoTransaccion.egreso,
                        child: Text('Egresos')),
                  ],
                  onChanged: (v) => setState(() => _filtroTipo = v),
                ),
              ),
            ],
          ),
        ),
        // Lista
        Expanded(
          child: lista.isEmpty
              ? const Center(
                  child: Text(
                    'Sin transacciones con estos filtros.',
                    style: TextStyle(color: Colors.white38),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: lista.length,
                  itemBuilder: (_, i) {
                    final t = lista[i];
                    final esIngreso = t.tipo == TipoTransaccion.ingreso;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading: Text(t.categoria.icono,
                            style: const TextStyle(fontSize: 24)),
                        title: Text(t.descripcion),
                        subtitle: Text(
                          '${t.categoria.label} · ${t.fecha.day}/${t.fecha.month}/${t.fecha.year}',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12),
                        ),
                        trailing: Text(
                          '${esIngreso ? '+' : '-'}\$${t.monto.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: esIngreso
                                ? AppTheme.esmeralda
                                : AppTheme.coral,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

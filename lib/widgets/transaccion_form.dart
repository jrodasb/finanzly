import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaccion.dart';
import '../models/categoria.dart';
import '../services/finanzly_state.dart';
import '../theme.dart';

class TransaccionForm extends StatefulWidget {
  const TransaccionForm({super.key});

  @override
  State<TransaccionForm> createState() => _TransaccionFormState();
}

class _TransaccionFormState extends State<TransaccionForm> {
  final _formKey = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TipoTransaccion _tipo = TipoTransaccion.egreso;
  Categoria _categoria = Categoria.comida;
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _montoCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final t = Transaccion(
      monto: double.parse(_montoCtrl.text),
      tipo: _tipo,
      descripcion: _descCtrl.text.trim(),
      fecha: _fecha,
      categoria: _categoria,
    );
    await context.read<FinanzlyState>().agregarTransaccion(t);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nueva transacción',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              // Tipo
              SegmentedButton<TipoTransaccion>(
                segments: const [
                  ButtonSegment(
                    value: TipoTransaccion.ingreso,
                    label: Text('Ingreso'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: TipoTransaccion.egreso,
                    label: Text('Egreso'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_tipo},
                onSelectionChanged: (s) => setState(() => _tipo = s.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _tipo == TipoTransaccion.ingreso
                          ? AppTheme.esmeralda.withAlpha(51)
                          : AppTheme.coral.withAlpha(51);
                    }
                    return null;
                  }),
                ),
              ),
              const SizedBox(height: 12),
              // Monto
              TextFormField(
                controller: _montoCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$ ',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa un monto';
                  final monto = double.tryParse(v);
                  if (monto == null || monto <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Descripción
              TextFormField(
                controller: _descCtrl,
                decoration:
                    const InputDecoration(labelText: 'Descripción'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Agrega una descripción' : null,
              ),
              const SizedBox(height: 12),
              // Categoría
              DropdownButtonFormField<Categoria>(
                value: _categoria,
                decoration:
                    const InputDecoration(labelText: 'Categoría'),
                items: Categoria.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${c.icono} ${c.label}'),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _categoria = v);
                },
              ),
              const SizedBox(height: 12),
              // Fecha
              OutlinedButton.icon(
                onPressed: _seleccionarFecha,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                ),
              ),
              const SizedBox(height: 8),
              // Stub OCR
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Escaneo OCR disponible en la próxima versión.'),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Escanear recibo'),
              ),
              const SizedBox(height: 16),
              // Guardar
              FilledButton(
                onPressed: _guardar,
                child: const Text('Guardar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

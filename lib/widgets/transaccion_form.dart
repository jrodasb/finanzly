import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaccion.dart';
import '../models/categoria.dart';
import '../services/finanzly_state.dart';
import '../services/ocr_service.dart';
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
  final _ocrService = OcrService();
  bool _escaneando = false;

  @override
  void dispose() {
    _montoCtrl.dispose();
    _descCtrl.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _escanearRecibo() async {
    if (!_ocrService.disponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El escaneo OCR requiere cámara — disponible en Android e iOS.',
          ),
        ),
      );
      return;
    }

    setState(() => _escaneando = true);
    try {
      final recibo = await _ocrService.escanearRecibo();
      if (recibo == null) return;

      setState(() {
        if (recibo.monto != null) {
          _montoCtrl.text = recibo.monto!.toStringAsFixed(0);
        }
        if (recibo.fecha != null) {
          _fecha = recibo.fecha!;
        }
        if (_descCtrl.text.isEmpty) {
          _descCtrl.text = 'Recibo escaneado';
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              recibo.monto != null
                  ? 'Datos extraídos del recibo. Verifica antes de guardar.'
                  : 'No se detectó un monto claro — completa manualmente.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo procesar el recibo. Intenta de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _escaneando = false);
    }
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
              // Escaneo OCR de recibos (Google ML Kit, on-device)
              OutlinedButton.icon(
                onPressed: _escaneando ? null : _escanearRecibo,
                icon: _escaneando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera_alt_outlined, size: 18),
                label: Text(
                  _escaneando ? 'Procesando recibo...' : 'Escanear recibo',
                ),
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

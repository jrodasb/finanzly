import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ReciboEscaneado {
  final double? monto;
  final DateTime? fecha;
  final String textoCompleto;

  ReciboEscaneado({this.monto, this.fecha, required this.textoCompleto});
}

/// Captura un recibo con la cámara y extrae monto y fecha mediante
/// reconocimiento de texto on-device (Google ML Kit). Disponible en
/// Android e iOS; en otras plataformas no hay cámara nativa soportada.
class OcrService {
  final _picker = ImagePicker();
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  bool get disponible =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<ReciboEscaneado?> escanearRecibo() async {
    if (!disponible) return null;

    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto == null) return null;

    final inputImage = InputImage.fromFile(File(foto.path));
    final resultado = await _recognizer.processImage(inputImage);
    final texto = resultado.text;

    return ReciboEscaneado(
      monto: _extraerMonto(texto),
      fecha: _extraerFecha(texto),
      textoCompleto: texto,
    );
  }

  double? _extraerMonto(String texto) {
    // Busca el patrón monetario más alto del recibo (total a pagar).
    final regex = RegExp(r'[\$]?\s?(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)');
    final candidatos = regex
        .allMatches(texto)
        .map((m) => m.group(1)!.replaceAll('.', '').replaceAll(',', '.'))
        .map((s) => double.tryParse(s))
        .whereType<double>()
        .where((v) => v > 0)
        .toList();
    if (candidatos.isEmpty) return null;
    candidatos.sort();
    return candidatos.last;
  }

  DateTime? _extraerFecha(String texto) {
    final regex = RegExp(r'(\d{1,2})[/\-](\d{1,2})[/\-](\d{2,4})');
    final match = regex.firstMatch(texto);
    if (match == null) return null;
    try {
      final dia = int.parse(match.group(1)!);
      final mes = int.parse(match.group(2)!);
      var anio = int.parse(match.group(3)!);
      if (anio < 100) anio += 2000;
      return DateTime(anio, mes, dia);
    } catch (_) {
      return null;
    }
  }

  void dispose() => _recognizer.close();
}

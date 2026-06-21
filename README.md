# Finanzly

Gestor de finanzas personales móvil multiplataforma, desarrollado con Flutter.

## Descargar APK

**[Descargar Finanzly-v2.0.0.apk](https://github.com/jrodasb/finanzly/releases/download/v2.0.0/Finanzly-v2.0.0.apk)** — versión final, 100% de requerimientos implementados

## Descripción

Finanzly es una aplicación 100% offline y standalone para el control de finanzas personales. Permite registrar ingresos y egresos, categorizar transacciones, establecer presupuestos mensuales con alertas automáticas y visualizar reportes gráficos de distribución de gastos.

## Funcionalidades implementadas

| RF | Nombre | Estado |
|---|---|---|
| RF-01 | Registrar Transacción | Implementado |
| RF-02 | Categorizar Transacciones | Implementado |
| RF-03 | Establecer Presupuestos | Implementado |
| RF-04 | Captura y OCR | Implementado |
| RF-05 | Alertas de Presupuesto | Implementado |
| RF-06 | Reportes Gráficos | Implementado |

## Tecnologías

- **Framework**: Flutter 3.32.1 / Dart 3.8.1
- **Almacenamiento**: SQLite local (sqflite)
- **Estado**: Provider (MVVM simplificado)
- **Gráficos**: fl_chart
- **Notificaciones**: flutter_local_notifications
- **OCR**: google_mlkit_text_recognition (on-device) + image_picker

## Arquitectura

```
lib/
├── models/      — Transaccion, Categoria, Presupuesto
├── services/    — DatabaseService, NotificacionService, FinanzlyState
├── screens/     — Dashboard, Historial, Presupuestos, Estadísticas
└── widgets/     — TransaccionForm, PresupuestoCard

lib/services/ocr_service.dart  — captura y OCR de recibos
```

## Instalación

```bash
flutter pub get
flutter run
```

Para Android, el APK release está disponible en la sección de Releases.

## Autor

Julian Rodas Bedoya — Programación Móvil, Politécnico Grancolombiano 2026

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificacionService {
  static final NotificacionService _instance = NotificacionService._internal();
  factory NotificacionService() => _instance;
  NotificacionService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Abrir Finanzly');
    const settings = InitializationSettings(
      android: androidSettings,
      linux: linuxSettings,
    );
    await _plugin.initialize(settings);
  }

  Future<void> mostrarAlertaPresupuesto({
    required String categoria,
    required int porcentaje,
  }) async {
    final titulo = porcentaje >= 100
        ? '¡Límite superado! — $categoria'
        : 'Alerta de presupuesto — $categoria';
    final cuerpo = porcentaje >= 100
        ? 'Has superado el 100% del presupuesto en $categoria.'
        : 'Llevas el $porcentaje% del presupuesto en $categoria.';

    final details = defaultTargetPlatform == TargetPlatform.linux
        ? const NotificationDetails(
            linux: LinuxNotificationDetails(),
          )
        : const NotificationDetails(
            android: AndroidNotificationDetails(
              'presupuesto_alertas',
              'Alertas de presupuesto',
              channelDescription: 'Notificaciones al superar límites de gasto.',
              importance: Importance.high,
              priority: Priority.high,
            ),
          );

    await _plugin.show(categoria.hashCode, titulo, cuerpo, details);
  }
}

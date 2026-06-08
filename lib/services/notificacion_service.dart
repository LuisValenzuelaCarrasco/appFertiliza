import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/recordatorio.dart';
import 'recordatorio_service.dart';

class NotificacionService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _inicializado = false;

  static Future<void> init() async {
    if (_inicializado) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Santiago'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    _inicializado = true;
    await reprogramarTodos();
  }

  static Future<void> programar({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fecha,
  }) async {
    await init();

    // ← USA la hora real del usuario, no las 08:00
    final fechaNotificacion = tz.TZDateTime(
      tz.local,
      fecha.year,
      fecha.month,
      fecha.day,
      fecha.hour, // ← corregido
      fecha.minute, // ← corregido
      0,
    );

    await _plugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      fechaNotificacion,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recordatorios',
          'Recordatorios Fertiliza',
          channelDescription: 'Recordatorios de mantenimiento del acuario',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // ← más confiable
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelar(int id) async {
    await _plugin.cancel(id);
    await RecordatorioService.eliminar(id);
  }

  static Future<void> reprogramarTodos() async {
    await RecordatorioService.limpiarVencidos();
    final recordatorios = await RecordatorioService.cargar();
    final ahora = DateTime.now();

    for (final Recordatorio r in recordatorios) {
      if (r.fecha.isAfter(ahora)) {
        // ← USA la hora real guardada, no las 08:00
        final fechaNotificacion = tz.TZDateTime(
          tz.local,
          r.fecha.year,
          r.fecha.month,
          r.fecha.day,
          r.fecha.hour, // ← corregido
          r.fecha.minute, // ← corregido
          0,
        );

        await _plugin.zonedSchedule(
          r.id,
          r.titulo,
          r.cuerpo,
          fechaNotificacion,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'recordatorios',
              'Recordatorios Fertiliza',
              channelDescription: 'Recordatorios de mantenimiento del acuario',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode:
              AndroidScheduleMode.exactAllowWhileIdle, // ← corregido
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }
}

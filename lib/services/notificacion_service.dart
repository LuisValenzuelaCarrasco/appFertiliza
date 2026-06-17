import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../models/recordatorio.dart';
import 'recordatorio_service.dart';

class NotificacionService {
  static bool _inicializado = false;

  static Future<void> init() async {
    if (_inicializado) return;

    await AwesomeNotifications().initialize(
      null, // null = ícono por defecto de la app
      [
        NotificationChannel(
          channelKey: 'recordatorios_fertiliza',
          channelName: 'Recordatorios Fertiliza',
          channelDescription: 'Recordatorios de mantenimiento del acuario',
          importance: NotificationImportance.Max,
          defaultPrivacy: NotificationPrivacy.Public,
          enableVibration: true,
          playSound: true,
        ),
      ],
    );

    _inicializado = true;
  }

  // Llama esto desde la pantalla antes de abrir el diálogo
  static Future<bool> pedirPermisos(BuildContext context) async {
    await init();

    final permitido =
        await AwesomeNotifications().requestPermissionToSendNotifications();

    if (!permitido && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Activa las notificaciones para Fertiliza en Ajustes.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }

    return permitido;
  }

  static Future<void> programar({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fecha,
  }) async {
    await init();

    final ahora = DateTime.now();
    if (!fecha.isAfter(ahora.add(const Duration(minutes: 1)))) {
      debugPrint('⚠️ Notificación #$id ignorada: fecha ya pasó');
      return;
    }

    debugPrint('✅ Programando notificación #$id para $fecha');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'recordatorios_fertiliza',
        title: titulo,
        body: cuerpo,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar.fromDate(
        date: fecha,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  }

  static Future<void> cancelar(int id) async {
    await AwesomeNotifications().cancel(id);
    await RecordatorioService.eliminar(id);
  }

  static Future<void> reprogramarTodos() async {
    try {
      await RecordatorioService.limpiarVencidos();
      final recordatorios = await RecordatorioService.cargar();
      final ahora = DateTime.now();

      for (final Recordatorio r in recordatorios) {
        if (r.fecha.isAfter(ahora)) {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: r.id,
              channelKey: 'recordatorios_fertiliza',
              title: r.titulo,
              body: r.cuerpo,
              wakeUpScreen: true,
              category: NotificationCategory.Reminder,
            ),
            schedule: NotificationCalendar.fromDate(
              date: r.fecha,
              allowWhileIdle: true,
              preciseAlarm: true,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error reprogramando: $e');
    }
  }
}

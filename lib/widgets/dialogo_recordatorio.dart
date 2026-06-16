import 'package:flutter/material.dart';
import '../services/notificacion_service.dart';
import '../services/recordatorio_service.dart';
import '../models/recordatorio.dart';

class DialogoRecordatorio extends StatefulWidget {
  final DateTime fechaInicial;

  const DialogoRecordatorio({
    super.key,
    required this.fechaInicial,
  });

  @override
  State<DialogoRecordatorio> createState() => _DialogoRecordatorioState();
}

class _DialogoRecordatorioState extends State<DialogoRecordatorio> {
  late DateTime _fechaSeleccionada;
  TimeOfDay _horaSeleccionada = const TimeOfDay(hour: 8, minute: 0);
  final _notasController = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = widget.fechaInicial;
    _guardando = false;
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada.isBefore(hoy) ? hoy : _fechaSeleccionada,
      firstDate: hoy, // hoy es el mínimo, no fechas pasadas
      lastDate: hoy.add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );
    if (fecha != null) setState(() => _fechaSeleccionada = fecha);
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
    );
    if (hora != null) setState(() => _horaSeleccionada = hora);
  }

  Future<void> _guardar() async {
    if (_guardando) return;

    if (_notasController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe qué debes recordar')),
      );
      return;
    }

    var fechaConHora = DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      _horaSeleccionada.hour,
      _horaSeleccionada.minute,
    ).toLocal();
    // Si la fecha ya pasó o está a menos de 1 minuto, avisa
    if (fechaConHora
        .isBefore(DateTime.now().toLocal().add(const Duration(minutes: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Elige una hora al menos 1 minuto en el futuro.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    final id = DateTime.now().microsecondsSinceEpoch;
    final cuerpo = _notasController.text.trim();

    // Guarda en el calendario siempre, independiente de la notificación
    await RecordatorioService.guardar(
      Recordatorio(
        id: id,
        titulo: '🌿 Recordatorio Fertiliza',
        cuerpo: cuerpo,
        fecha: fechaConHora,
      ),
    );

    // Intenta programar la notificación del sistema
    try {
      await NotificacionService.programar(
        id: id,
        titulo: '🌿 Recordatorio Fertiliza',
        cuerpo: cuerpo,
        fecha: fechaConHora,
      );
    } catch (e) {
      debugPrint('Notificación no programada: $e');
      // No es fatal — el recordatorio ya quedó guardado en el calendario
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Recordatorio guardado para el '
              '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year} '
              'a las ${_horaSeleccionada.format(context)}',
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
    }
  }

  String _formatFecha(DateTime fecha) {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    const dias = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo'
    ];
    return '${dias[fecha.weekday - 1]} ${fecha.day} de ${meses[fecha.month - 1]}';
  }

  String _formatHora(TimeOfDay hora) {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            16,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.alarm, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Programar recordatorio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: _seleccionarFecha,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cs.primary, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          _formatFecha(_fechaSeleccionada),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _seleccionarHora,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cs.primary, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 14, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          _formatHora(_horaSeleccionada),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notasController,
              maxLines: 4,
              autofocus: false,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: '¿Qué debes recordar?',
                hintText:
                    'Ej: Abonar con 15 ml de nitrógeno y hierro el acuario Jhu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(14),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.alarm_add),
                label: const Text('Programar recordatorio'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medicion.dart';
import '../models/recordatorio.dart';
import '../services/historial_service.dart';
import '../services/historial_notifier.dart';
import '../services/recordatorio_service.dart';
import '../models/tank_model.dart';
import '../widgets/dialogo_recordatorio.dart';

class MedicionesScreen extends StatefulWidget {
  final TankModel tank;
  final void Function(DateTime fecha)? onIrACalculadoraConFecha;

  const MedicionesScreen({
    super.key,
    required this.tank,
    this.onIrACalculadoraConFecha,
  });

  @override
  State<MedicionesScreen> createState() => _MedicionesScreenState();
}

class _MedicionesScreenState extends State<MedicionesScreen>
    with WidgetsBindingObserver {
  List<Medicion> _historial = [];
  List<Recordatorio> _recordatorios = [];
  bool _cargando = true;
  DateTime _mesActual = DateTime.now();
  DateTime? _diaSeleccionado;

  final Set<String> _seleccionados = {};
  bool get _modoSeleccion => _seleccionados.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    historialNotifier.addListener(_cargar);
    _cargar();
  }

  @override
  void dispose() {
    historialNotifier.removeListener(_cargar);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _cargar();
  }

  Future<void> _cargar() async {
    final data = await HistorialService.cargar(widget.tank.id);
    final recs = await RecordatorioService.cargar();
    if (!mounted) return;
    setState(() {
      _historial = data;
      _recordatorios = recs;
      _cargando = false;
    });
  }

  String _claveNutriente(String medicionId, String nutriente) =>
      '$medicionId::$nutriente';
  String _claveEvento(String medicionId) => medicionId;

  bool _nutrienteSeleccionado(String medicionId, String nutriente) =>
      _seleccionados.contains(_claveNutriente(medicionId, nutriente));
  bool _eventoSeleccionado(String medicionId) =>
      _seleccionados.contains(_claveEvento(medicionId));

  void _toggleNutriente(String medicionId, String nutriente) {
    setState(() {
      final clave = _claveNutriente(medicionId, nutriente);
      if (_seleccionados.contains(clave)) {
        _seleccionados.remove(clave);
      } else {
        _seleccionados.add(clave);
      }
    });
  }

  void _toggleEvento(String medicionId) {
    setState(() {
      final clave = _claveEvento(medicionId);
      if (_seleccionados.contains(clave)) {
        _seleccionados.remove(clave);
      } else {
        _seleccionados.add(clave);
      }
    });
  }

  void _cancelarSeleccion() => setState(() => _seleccionados.clear());
  int get _cantidadSeleccionados => _seleccionados.length;

  Future<void> _eliminarSeleccionados() async {
    if (_seleccionados.isEmpty) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar elementos'),
        content: Text(
          'Se eliminarán $_cantidadSeleccionados '
          'elemento${_cantidadSeleccionados > 1 ? 's' : ''} seleccionado${_cantidadSeleccionados > 1 ? 's' : ''}. ¿Continuar?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar != true) return;

    final clavesNutriente =
        _seleccionados.where((c) => c.contains('::')).toList();
    final clavesEvento =
        _seleccionados.where((c) => !c.contains('::')).toList();

    final Map<String, Set<String>> nutrientesPorMedicion = {};
    for (final clave in clavesNutriente) {
      final partes = clave.split('::');
      nutrientesPorMedicion.putIfAbsent(partes[0], () => {}).add(partes[1]);
    }

    for (final entry in nutrientesPorMedicion.entries) {
      final medicion = _historial.firstWhere((m) => m.id == entry.key,
          orElse: () => throw Exception());
      final nuevosNiveles = Map<String, double>.from(medicion.niveles)
        ..removeWhere((k, _) => entry.value.contains(k));
      final nuevosActuales = Map<String, double>.from(medicion.nivelesActuales)
        ..removeWhere((k, _) => entry.value.contains(k));
      final nuevosObjetivos = Map<String, double>.from(medicion.objetivos)
        ..removeWhere((k, _) => entry.value.contains(k));

      if (nuevosNiveles.isEmpty) {
        await HistorialService.eliminar(widget.tank.id, entry.key);
      } else {
        await HistorialService.actualizar(
          widget.tank.id,
          entry.key,
          Medicion(
            id: medicion.id,
            fecha: medicion.fecha,
            litros: medicion.litros,
            niveles: nuevosNiveles,
            nivelesActuales: nuevosActuales,
            objetivos: nuevosObjetivos,
            tipoEvento: medicion.tipoEvento,
            porcentajeCambioAgua: medicion.porcentajeCambioAgua,
            notasPoda: medicion.notasPoda,
          ),
        );
      }
    }

    for (final id in clavesEvento) {
      await HistorialService.eliminar(widget.tank.id, id);
    }

    setState(() {
      _historial.removeWhere((m) => clavesEvento.contains(m.id));
      _seleccionados.clear();
    });

    await _cargar();
  }

  Future<void> _confirmarLimpiarHoy() async {
    final fecha = _diaSeleccionado ?? DateTime.now();
    final registrosDelDia = _historial
        .where((m) =>
            m.fecha.year == fecha.year &&
            m.fecha.month == fecha.month &&
            m.fecha.day == fecha.day)
        .toList();

    if (registrosDelDia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'No hay registros del ${fecha.day}/${fecha.month}/${fecha.year}')));
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            'Borrar registros del ${fecha.day}/${fecha.month}/${fecha.year}'),
        content: Text(
          'Se eliminarán ${registrosDelDia.length} '
          'registro${registrosDelDia.length > 1 ? 's' : ''}. ¿Continuar?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Borrar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar != true) return;

    await HistorialService.borrarPorFecha(widget.tank.id, fecha);

    setState(() {
      _historial.removeWhere((m) =>
          m.fecha.year == fecha.year &&
          m.fecha.month == fecha.month &&
          m.fecha.day == fecha.day);
      _diaSeleccionado = null;
      _seleccionados.clear();
    });
  }

  Future<void> _confirmarBorrarEvento(Medicion medicion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar evento'),
        content: const Text(
            '¿Eliminar este evento? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Borrar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar != true) return;
    await HistorialService.eliminar(widget.tank.id, medicion.id);
    await _cargar();
  }

  Future<void> _borrarNutriente(Medicion medicion, String nutriente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar nutriente'),
        content: Text('¿Eliminar "$nutriente" de este registro?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Borrar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar != true) return;

    final nuevosNiveles = Map<String, double>.from(medicion.niveles)
      ..remove(nutriente);
    final nuevosActuales = Map<String, double>.from(medicion.nivelesActuales)
      ..remove(nutriente);
    final nuevosObjetivos = Map<String, double>.from(medicion.objetivos)
      ..remove(nutriente);

    if (nuevosNiveles.isEmpty) {
      await HistorialService.eliminar(widget.tank.id, medicion.id);
    } else {
      await HistorialService.actualizar(
        widget.tank.id,
        medicion.id,
        Medicion(
          id: medicion.id,
          fecha: medicion.fecha,
          litros: medicion.litros,
          niveles: nuevosNiveles,
          nivelesActuales: nuevosActuales,
          objetivos: nuevosObjetivos,
          tipoEvento: medicion.tipoEvento,
          porcentajeCambioAgua: medicion.porcentajeCambioAgua,
          notasPoda: medicion.notasPoda,
        ),
      );
    }
    await _cargar();
  }

  void _editarNutriente(Medicion medicion, String nutriente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DialogoEditarNutriente(
        medicion: medicion,
        nutriente: nutriente,
        onGuardar: (medicionEditada) async {
          await HistorialService.actualizar(
              widget.tank.id, medicion.id, medicionEditada);
          await _cargar();
        },
      ),
    );
  }

  void _mostrarDialogoEvento(DateTime dia) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DialogoNuevoEvento(
        dia: dia,
        litrosIniciales: widget.tank.volume.toStringAsFixed(0),
        onGuardar: (medicion) async {
          await HistorialService.guardar(widget.tank.id, medicion);
          await _cargar();
        },
      ),
    );
  }

  void _mostrarDialogoEditar(Medicion medicion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DialogoEditarEvento(
        medicion: medicion,
        onGuardar: (medicionEditada) async {
          await HistorialService.actualizar(
              widget.tank.id, medicion.id, medicionEditada);
          await _cargar();
        },
      ),
    );
  }

  Future<void> _abrirRecordatorio(DateTime dia) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DialogoRecordatorio(fechaInicial: dia),
    );
    await _cargar();
  }

  // ── Helpers de calendario ──────────────────────────────────────────────────

  bool _tieneAbono(DateTime dia) =>
      _eventosDelDia(dia, TipoEvento.abono).isNotEmpty;
  bool _tieneCambioAgua(DateTime dia) =>
      _eventosDelDia(dia, TipoEvento.cambioAgua).isNotEmpty;
  bool _tienePoda(DateTime dia) =>
      _eventosDelDia(dia, TipoEvento.poda).isNotEmpty;
  bool _tieneNota(DateTime dia) =>
      _eventosDelDia(dia, TipoEvento.nota).isNotEmpty;
  bool _tieneRecordatorio(DateTime dia) => _recordatorios.any((r) =>
      r.fecha.year == dia.year &&
      r.fecha.month == dia.month &&
      r.fecha.day == dia.day);

  List<Medicion> _medicionesDelDia(DateTime dia) => _historial
      .where((m) =>
          m.fecha.year == dia.year &&
          m.fecha.month == dia.month &&
          m.fecha.day == dia.day)
      .toList();

  List<Medicion> _eventosDelDia(DateTime dia, TipoEvento tipo) =>
      _medicionesDelDia(dia).where((m) => m.tipoEvento == tipo).toList();

  List<Recordatorio> _recordatoriosDelDia(DateTime dia) => _recordatorios
      .where((r) =>
          r.fecha.year == dia.year &&
          r.fecha.month == dia.month &&
          r.fecha.day == dia.day)
      .toList();

  // ── Formato ───────────────────────────────────────────────────────────────

  String _nombreMes(int mes) {
    const nombres = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return nombres[mes - 1];
  }

  String _formatHora(DateTime fecha) {
    final h = fecha.hour.toString().padLeft(2, '0');
    final m = fecha.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_modoSeleccion) {
      return AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancelarSeleccion,
        ),
        title: Text(
            '$_cantidadSeleccionados seleccionado${_cantidadSeleccionados > 1 ? 's' : ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar seleccionados',
            onPressed: _eliminarSeleccionados,
          ),
        ],
      );
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E8449), Color(0xFF145A32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              const SizedBox(width: 8),
              Image.asset(
                'lib/assets/logotipo/fertilizacompletologotipo.png',
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.eco, color: Colors.white70, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tank.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.tank.volumeLabel,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              if (_historial.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.white),
                  tooltip: _diaSeleccionado != null
                      ? 'Borrar registros del ${_diaSeleccionado!.day}/${_diaSeleccionado!.month}'
                      : 'Borrar registros de hoy',
                  onPressed: _confirmarLimpiarHoy,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primerDia = DateTime(_mesActual.year, _mesActual.month, 1);
    final diasEnMes = DateTime(_mesActual.year, _mesActual.month + 1, 0).day;
    final offsetInicio = primerDia.weekday % 7;
    final medicionesSeleccionadas = _diaSeleccionado != null
        ? _medicionesDelDia(_diaSeleccionado!)
        : <Medicion>[];
    final recordatoriosSeleccionados = _diaSeleccionado != null
        ? _recordatoriosDelDia(_diaSeleccionado!)
        : <Recordatorio>[];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(context),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Navegación de mes ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() {
                          _mesActual =
                              DateTime(_mesActual.year, _mesActual.month - 1);
                          _diaSeleccionado = null;
                          _seleccionados.clear();
                        }),
                      ),
                      Text(
                        '${_nombreMes(_mesActual.month)} ${_mesActual.year}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() {
                          _mesActual =
                              DateTime(_mesActual.year, _mesActual.month + 1);
                          _diaSeleccionado = null;
                          _seleccionados.clear();
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Cabecera días de semana ────────────────────────────
                  Row(
                    children: ['D', 'L', 'M', 'M', 'J', 'V', 'S']
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(d,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: cs.onSurfaceVariant)),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 6),

                  // ── Grid del calendario ───────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 0.85,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: offsetInicio + diasEnMes,
                        itemBuilder: (context, index) {
                          if (index < offsetInicio) return const SizedBox();
                          final dia = DateTime(_mesActual.year,
                              _mesActual.month, index - offsetInicio + 1);
                          final abono = _tieneAbono(dia);
                          final agua = _tieneCambioAgua(dia);
                          final poda = _tienePoda(dia);
                          final nota = _tieneNota(dia);
                          final recordatorio = _tieneRecordatorio(dia);
                          final esHoy = dia.year == DateTime.now().year &&
                              dia.month == DateTime.now().month &&
                              dia.day == DateTime.now().day;
                          final seleccionado =
                              _diaSeleccionado?.day == dia.day &&
                                  _diaSeleccionado?.month == dia.month &&
                                  _diaSeleccionado?.year == dia.year;

                          return GestureDetector(
                            onTap: () => setState(() {
                              _seleccionados.clear();
                              _diaSeleccionado = seleccionado ? null : dia;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: seleccionado
                                    ? cs.primary
                                    : esHoy
                                        ? cs.surfaceContainerHighest
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: esHoy && !seleccionado
                                    ? Border.all(color: cs.primary, width: 1.5)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${dia.day}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: (abono ||
                                                agua ||
                                                poda ||
                                                nota ||
                                                recordatorio)
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                        color: seleccionado
                                            ? Colors.white
                                            : cs.onSurface,
                                      )),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (abono)
                                        _Dot(
                                            color: seleccionado
                                                ? Colors.white
                                                : cs.primary),
                                      if (agua)
                                        _Dot(
                                            color: seleccionado
                                                ? Colors.white70
                                                : Colors.blue.shade400),
                                      if (poda)
                                        _Dot(
                                            color: seleccionado
                                                ? Colors.white70
                                                : Colors.green.shade500),
                                      if (nota)
                                        _Dot(
                                            color: seleccionado
                                                ? Colors.white70
                                                : Colors.amber.shade600),
                                      if (recordatorio)
                                        _Dot(
                                            color: seleccionado
                                                ? Colors.white70
                                                : Colors.orange.shade500),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Leyenda ───────────────────────────────────────────
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      _LeyendaItem(color: cs.primary, label: 'Abono'),
                      _LeyendaItem(
                          color: Colors.blue.shade400, label: 'Cambio de agua'),
                      _LeyendaItem(color: Colors.green.shade500, label: 'Poda'),
                      _LeyendaItem(color: Colors.amber.shade600, label: 'Nota'),
                      _LeyendaItem(
                          color: Colors.orange.shade500, label: 'Recordatorio'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Botón agregar evento ──────────────────────────────
                  if (_diaSeleccionado != null)
                    _BotonAgregarEvento(
                      dia: _diaSeleccionado!,
                      onAgregarOtro: () =>
                          _mostrarDialogoEvento(_diaSeleccionado!),
                      onAgregarAbono: widget.onIrACalculadoraConFecha != null
                          ? () => widget
                              .onIrACalculadoraConFecha!(_diaSeleccionado!)
                          : null,
                      onAgregarRecordatorio: () =>
                          _abrirRecordatorio(_diaSeleccionado!),
                    ),
                  const SizedBox(height: 12),

                  // ── Lista de eventos y recordatorios del día ──────────
                  if (_diaSeleccionado != null) ...[
                    if (medicionesSeleccionadas.isEmpty &&
                        recordatoriosSeleccionados.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                            'Sin eventos el ${_diaSeleccionado!.day}/${_diaSeleccionado!.month}',
                            style: TextStyle(
                                color: cs.onSurfaceVariant, fontSize: 13)),
                      )
                    else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(medicionesSeleccionadas.length + recordatoriosSeleccionados.length) == 1 ? '1 evento' : '${medicionesSeleccionadas.length + recordatoriosSeleccionados.length} eventos'} — ${_diaSeleccionado!.day}/${_diaSeleccionado!.month}/${_diaSeleccionado!.year}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          if (!_modoSeleccion &&
                              medicionesSeleccionadas.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  for (final m in medicionesSeleccionadas) {
                                    if (m.tipoEvento == TipoEvento.abono) {
                                      for (final n in m.niveles.keys) {
                                        _seleccionados
                                            .add(_claveNutriente(m.id, n));
                                      }
                                    } else {
                                      _seleccionados.add(_claveEvento(m.id));
                                    }
                                  }
                                });
                              },
                              icon: const Icon(Icons.checklist, size: 16),
                              label: const Text('Seleccionar todo',
                                  style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Eventos normales
                      ...medicionesSeleccionadas.map((m) => _TarjetaEvento(
                            m: m,
                            hora: _formatHora(m.fecha),
                            modoSeleccion: _modoSeleccion,
                            eventoSeleccionado: _eventoSeleccionado(m.id),
                            onToggleEvento: () => _toggleEvento(m.id),
                            nutrienteSeleccionado: (nutriente) =>
                                _nutrienteSeleccionado(m.id, nutriente),
                            onToggleNutriente: (nutriente) =>
                                _toggleNutriente(m.id, nutriente),
                            onEditar: () => _mostrarDialogoEditar(m),
                            onBorrar: () => _confirmarBorrarEvento(m),
                            onBorrarNutriente: (nutriente) =>
                                _borrarNutriente(m, nutriente),
                            onEditarNutriente: (nutriente) =>
                                _editarNutriente(m, nutriente),
                          )),

                      // Recordatorios del día
                      ...recordatoriosSeleccionados
                          .map((r) => _TarjetaRecordatorio(
                                recordatorio: r,
                                onEditar: (editado) async {
                                  await RecordatorioService.actualizar(editado);
                                  await _cargar();
                                },
                                onBorrar: () async {
                                  final confirmar = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Borrar recordatorio'),
                                      content: const Text(
                                          '¿Eliminar este recordatorio? No se puede deshacer.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancelar')),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Borrar',
                                                style: TextStyle(
                                                    color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirmar != true) return;
                                  await RecordatorioService.eliminar(r.id);
                                  await _cargar();
                                },
                              )),

                      if (_modoSeleccion)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _eliminarSeleccionados,
                              icon: const Icon(Icons.delete),
                              label: Text(
                                  'Eliminar $_cantidadSeleccionados seleccionado${_cantidadSeleccionados > 1 ? 's' : ''}'),
                            ),
                          ),
                        ),
                    ],
                  ] else if (_historial.isEmpty && _recordatorios.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Column(
                          children: [
                            Icon(Icons.history,
                                size: 56,
                                color:
                                    cs.onSurfaceVariant.withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text('Sin eventos registrados',
                                style: TextStyle(color: cs.onSurfaceVariant)),
                            const SizedBox(height: 6),
                            Text('Toca un día para agregar un evento',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurfaceVariant
                                        .withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                    )
                  else
                    Center(
                        child: Text('Toca un día para ver o agregar eventos',
                            style: TextStyle(
                                fontSize: 13, color: cs.onSurfaceVariant))),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: 5,
        height: 5,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _LeyendaItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LeyendaItem({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      );
}

class _MiniCheckbox extends StatelessWidget {
  final bool seleccionado;
  final VoidCallback onTap;

  const _MiniCheckbox({required this.seleccionado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: seleccionado ? Colors.red.shade400 : Colors.transparent,
          border: Border.all(
            color: seleccionado
                ? Colors.red.shade400
                : cs.onSurfaceVariant.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: seleccionado
            ? const Icon(Icons.check, size: 13, color: Colors.white)
            : null,
      ),
    );
  }
}

// ── Tarjeta Recordatorio ──────────────────────────────────────────────────────

class _TarjetaRecordatorio extends StatelessWidget {
  final Recordatorio recordatorio;
  final VoidCallback onBorrar;
  final Future<void> Function(Recordatorio) onEditar;

  const _TarjetaRecordatorio({
    required this.recordatorio,
    required this.onBorrar,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final h = recordatorio.fecha.hour.toString().padLeft(2, '0');
    final m = recordatorio.fecha.minute.toString().padLeft(2, '0');
    final hora = '$h:$m';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.alarm, color: Colors.orange.shade500, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Recordatorio',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.orange.shade500,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(hora,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (_) => _DialogoEditarRecordatorio(
                      recordatorio: recordatorio,
                      onGuardar: onEditar,
                    ),
                  ),
                  child: Icon(Icons.edit_outlined,
                      size: 22, color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onBorrar,
                  child: Icon(Icons.delete_outline,
                      size: 22, color: Colors.red.shade400),
                ),
              ],
            ),
            const Divider(height: 14),
            Text(
              recordatorio.titulo,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            if (recordatorio.cuerpo.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade500.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.orange.shade500.withValues(alpha: 0.3)),
                ),
                child: Text(recordatorio.cuerpo,
                    style: const TextStyle(fontSize: 13, height: 1.45)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Diálogo editar recordatorio ───────────────────────────────────────────────

class _DialogoEditarRecordatorio extends StatefulWidget {
  final Recordatorio recordatorio;
  final Future<void> Function(Recordatorio) onGuardar;

  const _DialogoEditarRecordatorio({
    required this.recordatorio,
    required this.onGuardar,
  });

  @override
  State<_DialogoEditarRecordatorio> createState() =>
      _DialogoEditarRecordatorioState();
}

class _DialogoEditarRecordatorioState
    extends State<_DialogoEditarRecordatorio> {
  late TextEditingController _tituloCtrl;
  late TextEditingController _cuerpoCtrl;
  late TimeOfDay _hora;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.recordatorio.titulo);
    _cuerpoCtrl = TextEditingController(text: widget.recordatorio.cuerpo);
    _hora = TimeOfDay(
      hour: widget.recordatorio.fecha.hour,
      minute: widget.recordatorio.fecha.minute,
    );
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _cuerpoCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarHora() async {
    final picked = await showTimePicker(context: context, initialTime: _hora);
    if (picked != null) setState(() => _hora = picked);
  }

  Future<void> _guardar() async {
    if (_tituloCtrl.text.trim().isEmpty) return;
    setState(() => _guardando = true);

    final fecha = DateTime(
      widget.recordatorio.fecha.year,
      widget.recordatorio.fecha.month,
      widget.recordatorio.fecha.day,
      _hora.hour,
      _hora.minute,
    );

    final editado = Recordatorio(
      id: widget.recordatorio.id,
      titulo: _tituloCtrl.text.trim(),
      cuerpo: _cuerpoCtrl.text.trim(),
      fecha: fecha,
    );

    await widget.onGuardar(editado);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                Icon(Icons.alarm, color: Colors.orange.shade500, size: 18),
                const SizedBox(width: 8),
                const Text('Editar recordatorio',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tituloCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Título',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cuerpoCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.access_time, color: Colors.orange.shade500),
              title: Text(
                  'Hora: ${_hora.hour.toString().padLeft(2, '0')}:${_hora.minute.toString().padLeft(2, '0')}'),
              onTap: _seleccionarHora,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Guardar cambios'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta Evento ────────────────────────────────────────────────────────────

class _TarjetaEvento extends StatelessWidget {
  final Medicion m;
  final String hora;
  final bool modoSeleccion;
  final bool eventoSeleccionado;
  final VoidCallback onToggleEvento;
  final bool Function(String nutriente) nutrienteSeleccionado;
  final void Function(String nutriente) onToggleNutriente;
  final VoidCallback onEditar;
  final VoidCallback onBorrar;
  final Future<void> Function(String nutriente) onBorrarNutriente;
  final void Function(String nutriente) onEditarNutriente;

  const _TarjetaEvento({
    required this.m,
    required this.hora,
    required this.modoSeleccion,
    required this.eventoSeleccionado,
    required this.onToggleEvento,
    required this.nutrienteSeleccionado,
    required this.onToggleNutriente,
    required this.onEditar,
    required this.onBorrar,
    required this.onBorrarNutriente,
    required this.onEditarNutriente,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    IconData icono;
    Color color;
    String titulo;

    switch (m.tipoEvento) {
      case TipoEvento.abono:
        icono = Icons.science;
        color = cs.primary;
        titulo = 'Abono';
      case TipoEvento.cambioAgua:
        icono = Icons.water_drop;
        color = Colors.blue.shade400;
        titulo = 'Cambio de agua';
      case TipoEvento.poda:
        icono = Icons.content_cut;
        color = Colors.green.shade500;
        titulo = 'Poda';
      case TipoEvento.nota:
        icono = Icons.notes_rounded;
        color = Colors.amber.shade600;
        titulo = 'Nota';
      case TipoEvento.recordatorio:
        icono = Icons.alarm;
        color = Colors.orange.shade500;
        titulo = 'Recordatorio';
    }

    final algunNutrienteSeleccionado = m.tipoEvento == TipoEvento.abono &&
        m.niveles.keys.any((n) => nutrienteSeleccionado(n));

    return GestureDetector(
      onLongPress: m.tipoEvento == TipoEvento.abono
          ? () {
              for (final n in m.niveles.keys) {
                onToggleNutriente(n);
              }
            }
          : onToggleEvento,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: (eventoSeleccionado || algunNutrienteSeleccionado)
              ? Border.all(color: Colors.red.shade400, width: 2)
              : null,
          color: (eventoSeleccionado || algunNutrienteSeleccionado)
              ? Colors.red.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (m.tipoEvento != TipoEvento.abono) ...[
                      _MiniCheckbox(
                        seleccionado: eventoSeleccionado,
                        onTap: onToggleEvento,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(icono, color: color, size: 16),
                    const SizedBox(width: 6),
                    Text(titulo,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: color,
                            fontSize: 14)),
                    const Spacer(),
                    Text(hora,
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurfaceVariant)),
                    if (m.tipoEvento != TipoEvento.abono && !modoSeleccion) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onEditar,
                        child: Icon(Icons.edit_outlined,
                            size: 25, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: onBorrar,
                        child: Icon(Icons.delete_outline,
                            size: 25, color: Colors.red.shade400),
                      ),
                    ],
                  ],
                ),
                if (m.tipoEvento == TipoEvento.abono) ...[
                  const Divider(height: 14),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('${m.litros.toStringAsFixed(0)} L',
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 28),
                      const Expanded(child: SizedBox()),
                      SizedBox(
                        width: 64,
                        child: Text('medido',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10, color: cs.onSurfaceVariant)),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 64,
                        child: Text('objetivo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10, color: cs.onSurfaceVariant)),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 52,
                        child: Text('ml agr.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10, color: cs.onSurfaceVariant)),
                      ),
                      const SizedBox(width: 50),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...m.niveles.entries.map((e) {
                    final actual = m.nivelesActuales[e.key];
                    final objetivo = m.objetivos[e.key];
                    final agregue = e.value;
                    final estaSeleccionado = nutrienteSeleccionado(e.key);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      decoration: BoxDecoration(
                        color: estaSeleccionado
                            ? Colors.red.withValues(alpha: 0.06)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Divider(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _MiniCheckbox(
                                seleccionado: estaSeleccionado,
                                onTap: () => onToggleNutriente(e.key),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  e.key,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: estaSeleccionado
                                        ? Colors.red.shade400
                                        : null,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(
                                width: 64,
                                child: Center(
                                  child: actual != null
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: cs.surfaceContainerHighest,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${actual.toStringAsFixed(1)} mg/L',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: cs.onSurfaceVariant),
                                          ),
                                        )
                                      : Text('—',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: cs.onSurfaceVariant
                                                  .withValues(alpha: 0.4))),
                                ),
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 64,
                                child: Center(
                                  child: objetivo != null
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${objetivo.toStringAsFixed(1)} mg/L',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green.shade700),
                                          ),
                                        )
                                      : Text('—',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: cs.onSurfaceVariant
                                                  .withValues(alpha: 0.4))),
                                ),
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 52,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                        '${agregue.toStringAsFixed(1)} ml',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: cs.primary)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (!modoSeleccion) ...[
                                GestureDetector(
                                  onTap: () => onEditarNutriente(e.key),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(Icons.edit_outlined,
                                        size: 20, color: cs.onSurfaceVariant),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                GestureDetector(
                                  onTap: () => onBorrarNutriente(e.key),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(Icons.delete_outline,
                                        size: 20, color: Colors.red.shade400),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                ],
                if (m.tipoEvento == TipoEvento.cambioAgua &&
                    m.porcentajeCambioAgua != null) ...[
                  const Divider(height: 14),
                  Row(
                    children: [
                      Text('Cambio: ',
                          style: TextStyle(
                              fontSize: 13, color: cs.onSurfaceVariant)),
                      Text('${m.porcentajeCambioAgua!.toStringAsFixed(0)}%',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue.shade400)),
                      Text('  de ${m.litros.toStringAsFixed(0)} L',
                          style: TextStyle(
                              fontSize: 13, color: cs.onSurfaceVariant)),
                      Text(
                          '  = ${(m.litros * m.porcentajeCambioAgua! / 100).toStringAsFixed(0)} L cambiados',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade400)),
                    ],
                  ),
                ],
                if (m.tipoEvento == TipoEvento.poda &&
                    m.notasPoda != null &&
                    m.notasPoda!.isNotEmpty) ...[
                  const Divider(height: 14),
                  Text(m.notasPoda!, style: const TextStyle(fontSize: 13)),
                ],
                if (m.tipoEvento == TipoEvento.nota &&
                    m.notasPoda != null &&
                    m.notasPoda!.isNotEmpty) ...[
                  const Divider(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade600.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.amber.shade600.withValues(alpha: 0.3)),
                    ),
                    child: Text(m.notasPoda!,
                        style: const TextStyle(fontSize: 13, height: 1.45)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Diálogo editar nutriente ──────────────────────────────────────────────────

class _DialogoEditarNutriente extends StatefulWidget {
  final Medicion medicion;
  final String nutriente;
  final Future<void> Function(Medicion) onGuardar;
  const _DialogoEditarNutriente({
    required this.medicion,
    required this.nutriente,
    required this.onGuardar,
  });

  @override
  State<_DialogoEditarNutriente> createState() =>
      _DialogoEditarNutrienteState();
}

class _DialogoEditarNutrienteState extends State<_DialogoEditarNutriente> {
  late TextEditingController _mlController;
  late TextEditingController _medidoController;
  late TextEditingController _objetivoController;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final m = widget.medicion;
    final n = widget.nutriente;
    _mlController =
        TextEditingController(text: (m.niveles[n] ?? 0).toStringAsFixed(1));
    _medidoController = TextEditingController(
        text: (m.nivelesActuales[n] ?? 0).toStringAsFixed(1));
    _objetivoController =
        TextEditingController(text: (m.objetivos[n] ?? 0).toStringAsFixed(1));
  }

  @override
  void dispose() {
    _mlController.dispose();
    _medidoController.dispose();
    _objetivoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final m = widget.medicion;
    final n = widget.nutriente;
    final nuevosNiveles = Map<String, double>.from(m.niveles)
      ..[n] = double.tryParse(_mlController.text) ?? 0;
    final nuevosActuales = Map<String, double>.from(m.nivelesActuales)
      ..[n] = double.tryParse(_medidoController.text) ?? 0;
    final nuevosObjetivos = Map<String, double>.from(m.objetivos)
      ..[n] = double.tryParse(_objetivoController.text) ?? 0;

    await widget.onGuardar(Medicion(
      id: m.id,
      fecha: m.fecha,
      litros: m.litros,
      niveles: nuevosNiveles,
      nivelesActuales: nuevosActuales,
      objetivos: nuevosObjetivos,
      tipoEvento: m.tipoEvento,
      porcentajeCambioAgua: m.porcentajeCambioAgua,
      notasPoda: m.notasPoda,
    ));
    if (mounted) Navigator.pop(context);
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
                Icon(Icons.science, color: cs.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Editar: ${widget.nutriente}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _medidoController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Medido',
                      suffixText: 'mg/L',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _objetivoController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Objetivo',
                      suffixText: 'mg/L',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _mlController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'ml agr.',
                      suffixText: 'ml',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Guardar cambios'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Diálogo editar evento completo ────────────────────────────────────────────

class _DialogoEditarEvento extends StatefulWidget {
  final Medicion medicion;
  final Future<void> Function(Medicion) onGuardar;
  const _DialogoEditarEvento({required this.medicion, required this.onGuardar});

  @override
  State<_DialogoEditarEvento> createState() => _DialogoEditarEventoState();
}

class _DialogoEditarEventoState extends State<_DialogoEditarEvento> {
  late Map<String, TextEditingController> _mlControllers;
  late Map<String, TextEditingController> _medidoControllers;
  late Map<String, TextEditingController> _objetivoControllers;
  late TextEditingController _porcentajeController;
  late TextEditingController _notasController;
  late TextEditingController _litrosController;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final m = widget.medicion;
    _litrosController =
        TextEditingController(text: m.litros.toStringAsFixed(0));
    _porcentajeController = TextEditingController(
        text: m.porcentajeCambioAgua?.toStringAsFixed(0) ?? '30');
    _notasController = TextEditingController(text: m.notasPoda ?? '');
    _mlControllers = {
      for (final e in m.niveles.entries)
        e.key: TextEditingController(text: e.value.toStringAsFixed(1))
    };
    _medidoControllers = {
      for (final e in m.niveles.entries)
        e.key: TextEditingController(
            text: (m.nivelesActuales[e.key] ?? 0).toStringAsFixed(1))
    };
    _objetivoControllers = {
      for (final e in m.niveles.entries)
        e.key: TextEditingController(
            text: (m.objetivos[e.key] ?? 0).toStringAsFixed(1))
    };
  }

  @override
  void dispose() {
    _litrosController.dispose();
    _porcentajeController.dispose();
    _notasController.dispose();
    for (final c in _mlControllers.values) {
      c.dispose();
    }
    for (final c in _medidoControllers.values) {
      c.dispose();
    }
    for (final c in _objetivoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final m = widget.medicion;
    final nivelesEditados = <String, double>{
      for (final e in _mlControllers.entries)
        e.key: double.tryParse(e.value.text) ?? 0,
    };
    final medidoEditado = <String, double>{
      for (final e in _medidoControllers.entries)
        e.key: double.tryParse(e.value.text) ?? 0,
    };
    final objetivoEditado = <String, double>{
      for (final e in _objetivoControllers.entries)
        e.key: double.tryParse(e.value.text) ?? 0,
    };
    await widget.onGuardar(Medicion(
      id: m.id,
      fecha: m.fecha,
      litros: double.tryParse(_litrosController.text) ?? m.litros,
      niveles: nivelesEditados,
      nivelesActuales: medidoEditado,
      objetivos: objetivoEditado,
      tipoEvento: m.tipoEvento,
      porcentajeCambioAgua: m.tipoEvento == TipoEvento.cambioAgua
          ? double.tryParse(_porcentajeController.text)
          : m.porcentajeCambioAgua,
      notasPoda:
          (m.tipoEvento == TipoEvento.poda || m.tipoEvento == TipoEvento.nota)
              ? _notasController.text
              : m.notasPoda,
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final m = widget.medicion;
    IconData icono;
    Color color;
    String titulo;
    switch (m.tipoEvento) {
      case TipoEvento.abono:
        icono = Icons.science;
        color = cs.primary;
        titulo = 'Editar abono';
      case TipoEvento.cambioAgua:
        icono = Icons.water_drop;
        color = Colors.blue.shade400;
        titulo = 'Editar cambio de agua';
      case TipoEvento.poda:
        icono = Icons.content_cut;
        color = Colors.green.shade500;
        titulo = 'Editar poda';
      case TipoEvento.nota:
        icono = Icons.notes_rounded;
        color = Colors.amber.shade600;
        titulo = 'Editar nota';
      case TipoEvento.recordatorio:
        icono = Icons.alarm;
        color = Colors.orange.shade500;
        titulo = 'Editar recordatorio';
    }

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
                Icon(icono, color: color, size: 18),
                const SizedBox(width: 8),
                Text(titulo,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            if (m.tipoEvento != TipoEvento.nota &&
                m.tipoEvento != TipoEvento.recordatorio) ...[
              TextField(
                controller: _litrosController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    labelText: 'Litros del acuario', suffixText: 'L'),
              ),
              const SizedBox(height: 16),
            ],
            if (m.tipoEvento == TipoEvento.abono) ...[
              Text('Productos',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),
              ..._mlControllers.entries.map((e) {
                final nombre = e.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _medidoControllers[nombre],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Medido',
                                suffixText: 'mg/L',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _objetivoControllers[nombre],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Objetivo',
                                suffixText: 'mg/L',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: e.value,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: 'ml agreg.',
                                suffixText: 'ml',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (m.tipoEvento == TipoEvento.cambioAgua)
              TextField(
                controller: _porcentajeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    labelText: 'Porcentaje de cambio', suffixText: '%'),
              ),
            if (m.tipoEvento == TipoEvento.poda)
              TextField(
                controller: _notasController,
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'Notas de la poda'),
              ),
            if (m.tipoEvento == TipoEvento.nota)
              TextField(
                controller: _notasController,
                maxLines: 5,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Nota',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Guardar cambios'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Diálogo nuevo evento ──────────────────────────────────────────────────────

class _DialogoNuevoEvento extends StatefulWidget {
  final DateTime dia;
  final String litrosIniciales;
  final Future<void> Function(Medicion) onGuardar;
  const _DialogoNuevoEvento({
    required this.dia,
    required this.litrosIniciales,
    required this.onGuardar,
  });

  @override
  State<_DialogoNuevoEvento> createState() => _DialogoNuevoEventoState();
}

class _DialogoNuevoEventoState extends State<_DialogoNuevoEvento> {
  TipoEvento _tipo = TipoEvento.cambioAgua;
  late final TextEditingController _litrosController;
  final _porcentajeController = TextEditingController(text: '30');
  final _notasController = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _litrosController = TextEditingController(text: widget.litrosIniciales);
  }

  @override
  void dispose() {
    _litrosController.dispose();
    _porcentajeController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final litros = double.tryParse(_litrosController.text) ?? 0;
    final porcentaje = double.tryParse(_porcentajeController.text);
    final ahora = DateTime(
      widget.dia.year,
      widget.dia.month,
      widget.dia.day,
      DateTime.now().hour,
      DateTime.now().minute,
    );
    await widget.onGuardar(Medicion(
      fecha: ahora,
      litros: _tipo == TipoEvento.nota ? 0 : litros,
      niveles: {},
      tipoEvento: _tipo,
      porcentajeCambioAgua: _tipo == TipoEvento.cambioAgua ? porcentaje : null,
      notasPoda: (_tipo == TipoEvento.poda || _tipo == TipoEvento.nota)
          ? _notasController.text
          : null,
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
                'Nuevo evento — ${widget.dia.day}/${widget.dia.month}/${widget.dia.year}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TipoChip(
                  label: 'Cambio de agua',
                  icono: Icons.water_drop,
                  color: Colors.blue.shade400,
                  seleccionado: _tipo == TipoEvento.cambioAgua,
                  onTap: () => setState(() => _tipo = TipoEvento.cambioAgua),
                ),
                _TipoChip(
                  label: 'Poda',
                  icono: Icons.content_cut,
                  color: Colors.green.shade500,
                  seleccionado: _tipo == TipoEvento.poda,
                  onTap: () => setState(() => _tipo = TipoEvento.poda),
                ),
                _TipoChip(
                  label: 'Nota',
                  icono: Icons.notes_rounded,
                  color: Colors.amber.shade600,
                  seleccionado: _tipo == TipoEvento.nota,
                  onTap: () => setState(() => _tipo = TipoEvento.nota),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_tipo != TipoEvento.nota) ...[
              TextField(
                controller: _litrosController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    labelText: 'Litros del acuario', suffixText: 'L'),
              ),
              const SizedBox(height: 12),
            ],
            if (_tipo == TipoEvento.cambioAgua)
              TextField(
                controller: _porcentajeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    labelText: 'Porcentaje de cambio', suffixText: '%'),
              ),
            if (_tipo == TipoEvento.poda)
              TextField(
                controller: _notasController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notas de la poda (opcional)',
                  hintText: 'Ej: Recorté rotala y anubias...',
                ),
              ),
            if (_tipo == TipoEvento.nota)
              TextField(
                controller: _notasController,
                maxLines: 5,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Escribe tu nota',
                  hintText: 'Ej: Limpié el filtro, cambié el sustrato...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Guardar evento'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── _BotonAgregarEvento ───────────────────────────────────────────────────────

class _BotonAgregarEvento extends StatelessWidget {
  final DateTime dia;
  final VoidCallback onAgregarOtro;
  final VoidCallback? onAgregarAbono;
  final VoidCallback onAgregarRecordatorio;

  const _BotonAgregarEvento({
    required this.dia,
    required this.onAgregarOtro,
    this.onAgregarAbono,
    required this.onAgregarRecordatorio,
  });

  bool get _esPasado {
    final hoy = DateTime.now();
    final soloHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final soloDia = DateTime(dia.year, dia.month, dia.day);
    return soloDia.isBefore(soloHoy);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = '${dia.day}/${dia.month}/${dia.year}';

    if (!_esPasado || onAgregarAbono == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: onAgregarOtro,
            icon: const Icon(Icons.add, size: 18),
            label: Text('Agregar evento el $label'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _esPasado ? null : onAgregarRecordatorio,
            icon: const Icon(Icons.alarm, size: 18),
            label: Text('Agregar recordatorio el $label'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onAgregarAbono,
          icon: const Icon(Icons.science, size: 18),
          label: Text('Agregar abono del $label'),
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onAgregarOtro,
          icon: const Icon(Icons.add, size: 18),
          label: Text('Otro evento el $label'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _esPasado ? null : onAgregarRecordatorio,
          icon: const Icon(Icons.alarm, size: 18),
          label: Text('Agregar recordatorio el $label'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// ── Chip de tipo de evento ────────────────────────────────────────────────────

class _TipoChip extends StatelessWidget {
  final String label;
  final IconData icono;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  const _TipoChip({
    required this.label,
    required this.icono,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado
              ? color.withValues(alpha: 0.15)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: seleccionado ? color : Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono,
                size: 14, color: seleccionado ? color : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      seleccionado ? FontWeight.w700 : FontWeight.normal,
                  color: seleccionado ? color : cs.onSurfaceVariant,
                )),
          ],
        ),
      ),
    );
  }
}

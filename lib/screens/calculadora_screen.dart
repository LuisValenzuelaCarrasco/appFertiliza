// screens/calculadora_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rutina_fertiliza/models/producto.dart';
import 'package:rutina_fertiliza/widgets/resultado_card.dart';
import 'package:rutina_fertiliza/widgets/producto_selector.dart';
import 'package:rutina_fertiliza/widgets/fertiliza_app_bar.dart';
import 'package:rutina_fertiliza/models/medicion.dart';
import 'package:rutina_fertiliza/services/historial_service.dart';
import 'package:rutina_fertiliza/services/historial_notifier.dart';

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  final _litrosController = TextEditingController(text: '100');

  bool _mostrarResultados = false;
  bool _isLoading = false;

  Set<String> _productosCalculados = {};
  Set<String> _adicionalesCalculados = {};
  Map<String, double> _nivelesSnapshot = {};
  Map<String, String> _modalidadesSnapshot = {};
  double _litrosCalculados = 0;

  final Map<String, TextEditingController> _nivelControllers = {
    'nitrogeno': TextEditingController(text: '0'),
    'fosfato': TextEditingController(text: '0'),
    'potasio': TextEditingController(text: '0'),
    'hierro_micro': TextEditingController(text: '0'),
    'hierro_quelatado': TextEditingController(text: '0'),
    'potasio_micro': TextEditingController(text: '0'),
  };

  final Map<String, TextEditingController> _objetivoControllers = {
    'nitrogeno': TextEditingController(),
    'fosfato': TextEditingController(),
    'potasio': TextEditingController(),
    'hierro_micro': TextEditingController(),
    'hierro_quelatado': TextEditingController(),
    'potasio_micro': TextEditingController(),
  };

  final Set<String> _productosSeleccionados = {};
  final Set<String> _productosAdicionalesSeleccionados = {};
  final Map<String, String> _modalidadesSeleccionadas = {};

  @override
  void dispose() {
    _litrosController.dispose();
    for (final c in _nivelControllers.values) {
      c.dispose();
    }
    for (final c in _objetivoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _objetivoEfectivo(Producto p) {
    final ingresado =
        double.tryParse(_objetivoControllers[p.id]?.text ?? '') ?? 0;
    return ingresado > 0 ? ingresado : p.objetivoMgL;
  }

  String _modalidadActual(Producto p) {
    return _modalidadesSeleccionadas[p.id] ??
        (p.modalidades.isNotEmpty ? p.modalidades.first : '');
  }

  Future<void> _calcular() async {
    FocusScope.of(context).unfocus();

    final litros = double.tryParse(_litrosController.text) ?? 0;

    if (litros <= 0) {
      _mostrarError('Ingresa una cantidad válida de litros');
      return;
    }

    if (_productosSeleccionados.isEmpty &&
        _productosAdicionalesSeleccionados.isEmpty) {
      _mostrarError('Selecciona al menos un producto');
      return;
    }

    setState(() {
      _isLoading = true;
      _mostrarResultados = false;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final niveles = <String, double>{};
    final nivelesActuales = <String, double>{};
    final objetivosGuardados = <String, double>{};

    for (final p in productosTesteables
        .where((p) => _productosSeleccionados.contains(p.id))) {
      final nivelActual =
          double.tryParse(_nivelControllers[p.id]?.text ?? '0') ?? 0;
      final objetivo = _objetivoEfectivo(p);
      final dosis =
          p.calcularMlNecesarios(nivelActual, litros, objetivo: objetivo);
      niveles[p.nombre] = dosis;
      nivelesActuales[p.nombre] = nivelActual;
      objetivosGuardados[p.nombre] = objetivo;
    }

    for (final p in productosAdicionales
        .where((p) => _productosAdicionalesSeleccionados.contains(p.id))) {
      final modalidad = _modalidadActual(p);
      final dosis = p.calcularDosisPorModalidad(litros, modalidad);
      final clave =
          p.modalidades.length > 1 ? '${p.nombre} ($modalidad)' : p.nombre;
      niveles[clave] = dosis;
    }

    try {
      await HistorialService.guardar(Medicion(
        fecha: DateTime.now(),
        litros: litros,
        niveles: niveles,
        nivelesActuales: nivelesActuales,
        objetivos: objetivosGuardados,
      ));
      historialNotifier.value++;
    } catch (e) {
      debugPrint('❌ Error historial: $e');
    }

    setState(() {
      _isLoading = false;
      _mostrarResultados = true;
      _productosCalculados = Set.from(_productosSeleccionados);
      _adicionalesCalculados = Set.from(_productosAdicionalesSeleccionados);
      _nivelesSnapshot = {
        for (final p in productosTesteables)
          if (_productosSeleccionados.contains(p.id))
            p.id: double.tryParse(_nivelControllers[p.id]?.text ?? '0') ?? 0,
      };
      _modalidadesSnapshot = Map.from(_modalidadesSeleccionadas);
      _litrosCalculados = litros;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      Scrollable.ensureVisible(context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic);
    });
  }

  void _restablecerCalculadora() {
    setState(() {
      _mostrarResultados = false;
      _productosSeleccionados.clear();
      _productosAdicionalesSeleccionados.clear();
      _productosCalculados.clear();
      _adicionalesCalculados.clear();
      _nivelesSnapshot.clear();
      _modalidadesSnapshot.clear();
      for (final c in _nivelControllers.values) {
        c.text = '0';
      }
      for (final c in _objetivoControllers.values) {
        c.clear();
      }
      _litrosController.text = '100';
      _litrosCalculados = 0;
    });
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _colorDesdeHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  IconData _iconoPorCategoria(String categoria) {
    switch (categoria) {
      case 'Tratamiento':
        return Icons.bug_report_outlined;
      case 'Acondicionador':
        return Icons.water_drop_outlined;
      case 'Biológico':
        return Icons.science_outlined;
      case 'Estimulante':
        return Icons.energy_savings_leaf_outlined;
      default:
        return Icons.local_florist_outlined;
    }
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalCalculados =
        _productosCalculados.length + _adicionalesCalculados.length;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const FertilizaAppBar(
        titulo: 'FERTILIZA ®',
        subtitulo: 'Calculadora de abonado',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── HEADER ───────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.science, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Calculadora de nutrientes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ── LITROS ───────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _litrosController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Litros del acuario',
                      prefixIcon: const Icon(Icons.water_drop),
                      suffixText: 'L',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Ingresa el volumen real: descuenta piedras, troncos, plantas y sustrato (generalmente un 10–20% menos que la capacidad del acuario).',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── PRODUCTOS NPK / HIERROS ───────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.science_outlined),
                      SizedBox(width: 8),
                      Text('Nutrientes (con testeo)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => setState(() {
                          _productosSeleccionados
                              .addAll(productosTesteables.map((e) => e.id));
                        }),
                        child: const Text('Todos'),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => _productosSeleccionados.clear()),
                        child: const Text('Limpiar'),
                      ),
                    ],
                  ),
                  ...productosTesteables.map(
                    (p) => ProductoSelector(
                      producto: p,
                      seleccionado: _productosSeleccionados.contains(p.id),
                      controller: _nivelControllers[p.id],
                      objetivoController: _objetivoControllers[p.id],
                      onToggle: (sel) => setState(() {
                        if (sel) {
                          _productosSeleccionados.add(p.id);
                        } else {
                          _productosSeleccionados.remove(p.id);
                        }
                      }),
                      onChanged: () => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── OTROS PRODUCTOS ───────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.medication_liquid_outlined),
                      SizedBox(width: 8),
                      Text('Otros productos',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'La dosis se calcula automáticamente según los litros',
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 10),
                  ...productosAdicionales.map((p) {
                    final color = _colorDesdeHex(p.color);
                    final seleccionado =
                        _productosAdicionalesSeleccionados.contains(p.id);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          value: seleccionado,
                          onChanged: (v) => setState(() {
                            if (v == true) {
                              _productosAdicionalesSeleccionados.add(p.id);
                              if (p.modalidades.isNotEmpty) {
                                _modalidadesSeleccionadas[p.id] =
                                    p.modalidades.first;
                              }
                            } else {
                              _productosAdicionalesSeleccionados.remove(p.id);
                            }
                          }),
                          title: Row(
                            children: [
                              Icon(_iconoPorCategoria(p.categoria),
                                  color: color, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.nombre,
                                        style: const TextStyle(fontSize: 13)),
                                    Text(p.descripcionCorta,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: cs.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: color,
                        ),
                        if (seleccionado && p.modalidades.length > 1)
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 12, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Modo de uso',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurfaceVariant)),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: p.modalidades.map((m) {
                                    final sel =
                                        (_modalidadesSeleccionadas[p.id] ??
                                                p.modalidades.first) ==
                                            m;
                                    return GestureDetector(
                                      onTap: () => setState(() =>
                                          _modalidadesSeleccionadas[p.id] = m),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 150),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: sel
                                              ? color.withValues(alpha: 0.15)
                                              : cs.surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: sel
                                                ? color
                                                : Colors.transparent,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Text(m,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: sel
                                                  ? FontWeight.w700
                                                  : FontWeight.normal,
                                              color: sel
                                                  ? color
                                                  : cs.onSurfaceVariant,
                                            )),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── BOTÓN CALCULAR ────────────────────────────────────
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _calcular,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.calculate),
            label: Text(_isLoading ? 'Calculando...' : 'Calcular dosis'),
          ),

          const SizedBox(height: 12),

          // ── RESUMEN ───────────────────────────────────────────
          if (_mostrarResultados)
            Card(
              color: cs.primary,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _miniStat(
                        'Litros', '${_litrosCalculados.toStringAsFixed(0)} L'),
                    _miniStat('Productos', '$totalCalculados'),
                    _miniStat('Estado', 'OK'),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 10),

          // ── RESULTADOS NPK / HIERROS ──────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _mostrarResultados
                ? Column(
                    children: productosTesteables
                        .where((p) => _productosCalculados.contains(p.id))
                        .map((p) {
                      final nivelActual = _nivelesSnapshot[p.id] ?? 0;
                      final objetivo = _objetivoEfectivo(p);
                      return ResultadoCard(
                        producto: p,
                        litros: _litrosCalculados,
                        nivelActual: nivelActual,
                        objetivoOverride: objetivo,
                      );
                    }).toList(),
                  )
                : const SizedBox(),
          ),

          // ── RESULTADOS OTROS PRODUCTOS ────────────────────────
          if (_mostrarResultados)
            ...productosAdicionales
                .where((p) => _adicionalesCalculados.contains(p.id))
                .map((p) => _TarjetaProductoAdicional(
                      key: ValueKey(p.id),
                      producto: p,
                      litros: _litrosCalculados,
                      modalidad: _modalidadesSnapshot[p.id] ??
                          (p.modalidades.isNotEmpty ? p.modalidades.first : ''),
                    )),

          // ── BOTÓN RESTABLECER ─────────────────────────────────
          if (_mostrarResultados) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _restablecerCalculadora,
              icon: const Icon(Icons.refresh),
              label: const Text('Restablecer calculadora'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: Colors.red.shade400,
                side: BorderSide(color: Colors.red.shade300),
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _TarjetaProductoAdicional extends StatelessWidget {
  final Producto producto;
  final double litros;
  final String modalidad;

  const _TarjetaProductoAdicional({
    super.key,
    required this.producto,
    required this.litros,
    required this.modalidad,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color =
        Color(int.parse('FF${producto.color.replaceAll('#', '')}', radix: 16));
    final dosis = producto.calcularDosisPorModalidad(litros, modalidad);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication_liquid_outlined, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(producto.nombre,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: color,
                              fontSize: 15)),
                      Text(producto.descripcionCorta,
                          style: TextStyle(
                              fontSize: 11, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            if (producto.modalidades.length > 1) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(modalidad,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                      producto.consejoPorModalidad[modalidad] ??
                          producto.consejo,
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                          height: 1.4)),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text('${dosis.toStringAsFixed(1)} ml',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: color)),
                      Text('para ${litros.toStringAsFixed(0)} L',
                          style: TextStyle(
                              fontSize: 10, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

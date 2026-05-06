// screens/calculadora_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/producto.dart';
import '../widgets/resultado_card.dart';
import '../widgets/producto_selector.dart';
import '../widgets/fertiliza_app_bar.dart';
import '../models/medicion.dart';
import '../services/historial_service.dart';

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  final _litrosController = TextEditingController(text: '100');
  double _litros = 100;

  bool _mostrarResultados = false;
  bool _isLoading = false;

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

  Future<void> _calcular() async {
    FocusScope.of(context).unfocus();

    final litros = double.tryParse(_litrosController.text) ?? 0;

    if (litros <= 0) {
      _mostrarError('Ingresa una cantidad válida de litros');
      return;
    }

    if (_productosSeleccionados.isEmpty) {
      _mostrarError('Selecciona al menos un producto');
      return;
    }

    setState(() {
      _isLoading = true;
      _mostrarResultados = false;
      _litros = litros;
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

    try {
      await HistorialService.guardar(Medicion(
        fecha: DateTime.now(),
        litros: litros,
        niveles: niveles,
        nivelesActuales: nivelesActuales,
        objetivos: objetivosGuardados,
      ));
    } catch (e) {
      debugPrint('❌ Error historial: $e');
    }

    setState(() {
      _isLoading = false;
      _mostrarResultados = true;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      Scrollable.ensureVisible(context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic);
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

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const FertilizaAppBar(
        titulo: 'FERTILIZA ®',
        subtitulo: 'Calculadora de abonado',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔥 HEADER PRO
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

          // 💧 LITROS
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
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
                onChanged: (_) => setState(() => _mostrarResultados = false),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 🧪 PRODUCTOS
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.science_outlined),
                      SizedBox(width: 8),
                      Text(
                        'Productos',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => setState(() {
                          _productosSeleccionados.addAll(
                            productosTesteables.map((e) => e.id),
                          );
                        }),
                        child: const Text('Todos'),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _productosSeleccionados.clear();
                        }),
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
                        _mostrarResultados = false;
                      }),
                      onChanged: () =>
                          setState(() => _mostrarResultados = false),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 🚀 BOTÓN
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

          // 📊 RESUMEN
          if (_mostrarResultados)
            Card(
              color: cs.primary,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _miniStat('Litros', '$_litros L'),
                    _miniStat('Productos', '${_productosSeleccionados.length}'),
                    _miniStat('Estado', 'OK'),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 10),

          // 📈 RESULTADOS
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _mostrarResultados
                ? Column(
                    children: productosTesteables
                        .where((p) => _productosSeleccionados.contains(p.id))
                        .map((p) {
                      final nivelActual = double.tryParse(
                              _nivelControllers[p.id]?.text ?? '0') ??
                          0;
                      final objetivo = _objetivoEfectivo(p);

                      return ResultadoCard(
                        producto: p,
                        litros: _litros,
                        nivelActual: nivelActual,
                        objetivoOverride: objetivo,
                      );
                    }).toList(),
                  )
                : const SizedBox(),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

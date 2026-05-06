// widgets/resultado_card.dart
import 'package:flutter/material.dart';
import '../models/producto.dart';

class ResultadoCard extends StatelessWidget {
  final Producto producto;
  final double litros;
  final double nivelActual;
  final double? objetivoOverride; // NUEVO: objetivo personalizado

  const ResultadoCard({
    super.key,
    required this.producto,
    required this.litros,
    required this.nivelActual,
    this.objetivoOverride,
  });

  /// Objetivo efectivo: el que pasó la pantalla, o el default del producto.
  double get _objetivo => (objetivoOverride != null && objetivoOverride! > 0)
      ? objetivoOverride!
      : producto.objetivoMgL;

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  double get _exceso => nivelActual > _objetivo ? nivelActual - _objetivo : 0;

  double get _porcentajeExceso => _objetivo > 0 ? _exceso / _objetivo : 0;

  bool get _esSobredosis =>
      producto.id == 'potasio' ? nivelActual > 15 : nivelActual > _objetivo;

  bool get _esZonaOkPotasio =>
      producto.id == 'potasio' && nivelActual >= 10 && nivelActual <= 15;

  bool get _esExcesoPotasio => producto.id == 'potasio' && nivelActual > 15;

  String _estadoTexto(double porcentaje) {
    if (_esExcesoPotasio) return 'Exceso detectado';
    if (_esZonaOkPotasio) return 'Nivel óptimo';
    if (producto.id == 'potasio' && nivelActual < 10) {
      return nivelActual >= 5 ? 'Deficiencia  baja' : 'Deficiencia severa';
    }
    if (_esSobredosis) return 'Exceso detectado';
    if (nivelActual >= _objetivo) return 'Nivel óptimo';
    if (porcentaje >= 0.7) return 'Deficiencia  baja';
    if (porcentaje >= 0.3) return 'Deficiencia media';
    return 'Deficiencia severa';
  }

  Color _estadoColor(double porcentaje) {
    if (_esExcesoPotasio) return Colors.red.shade700;
    if (_esZonaOkPotasio) return Colors.green.shade600;
    if (producto.id == 'potasio' && nivelActual < 10) {
      return nivelActual >= 5 ? Colors.orange.shade600 : Colors.red.shade700;
    }
    if (_esSobredosis) return Colors.red.shade700;
    if (nivelActual >= _objetivo) return Colors.green.shade600;
    if (porcentaje >= 0.7) return Colors.orange.shade600;
    if (porcentaje >= 0.3) return Colors.deepOrange.shade600;
    return Colors.red.shade700;
  }

  String _consejoSobredosis() {
    final excesoPct = (_porcentajeExceso * 100).toStringAsFixed(0);
    if (_porcentajeExceso >= 1.0) {
      return 'El nivel está muy por encima del objetivo ($excesoPct% de exceso). '
          'Realiza un cambio de agua del 40–50% para diluir la concentración, '
          'espera 24 horas y vuelve a medir antes de abonar nuevamente.';
    } else if (_porcentajeExceso >= 0.5) {
      return 'El nivel supera el objetivo en un $excesoPct%. '
          'Se recomienda un cambio de agua del 25–30% para ajustar los parámetros. '
          'Vuelve a medir antes del próximo abono.';
    } else {
      return 'El nivel está levemente por encima del objetivo ($excesoPct% de exceso). '
          'Omite la próxima dosis de este producto y vuelve a medir en 2–3 días. '
          'Si persiste, realiza un cambio de agua del 15–20%.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(producto.color);

    // ml necesarios para ir de nivelActual → _objetivo
    final mlNecesarios = producto.calcularMlNecesarios(
      nivelActual,
      litros,
      objetivo: _objetivo,
    );

    final porcentaje =
        _objetivo > 0 ? (nivelActual / _objetivo).clamp(0.0, 2.0) : 0.0;
    final porcentajeNormal = porcentaje.clamp(0.0, 1.0);
    final estadoTexto = _estadoTexto(porcentajeNormal);
    final estadoColor = _estadoColor(porcentajeNormal);
    final optimo = nivelActual >= _objetivo && !_esSobredosis;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: _esSobredosis
            ? BorderSide(color: Colors.red.shade400, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabecera ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _esSobredosis ? Colors.red.shade700 : color,
            ),
            child: Row(
              children: [
                Icon(
                  _esSobredosis ? Icons.warning_rounded : Icons.science,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        producto.descripcionCorta,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estadoTexto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Barra nivel actual → objetivo ──────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nivel actual: ${nivelActual.toStringAsFixed(2)} mg/L',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _esSobredosis ? Colors.red.shade700 : null,
                      ),
                    ),
                    Text(
                      'Objetivo: ${_objetivo.toStringAsFixed(_objetivo < 1 ? 1 : 0)} mg/L',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Container(height: 12, color: Colors.grey.shade200),
                      FractionallySizedBox(
                        widthFactor: porcentajeNormal,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: _esSobredosis
                                ? Colors.red.shade500
                                : optimo
                                    ? Colors.green.shade500
                                    : color,
                          ),
                        ),
                      ),
                      if (_esSobredosis)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor:
                                (_objetivo / nivelActual).clamp(0.0, 1.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                  width: 2, height: 12, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Alerta sobredosis ──────────────────────────────────
                if (_esSobredosis) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.red.shade200, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.water_drop,
                                color: Colors.red.shade700, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '⚠ Nivel por encima del objetivo',
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _ExcesoChip(
                              label: 'Exceso',
                              valor: '+${_exceso.toStringAsFixed(2)} mg/L',
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            _ExcesoChip(
                              label: 'Sobre objetivo',
                              valor:
                                  '+${(_porcentajeExceso * 100).toStringAsFixed(0)}%',
                              color: Colors.red.shade600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💧', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _consejoSobredosis(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade900,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.block,
                                color: Colors.red.shade600, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'No agregar más dosis hasta ajustar el nivel',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Dosis de corrección ────────────────────────────────
                if (!_esSobredosis && !optimo) ...[
                  const SizedBox(height: 16),
                  _DosisRow(
                    label: 'Para alcanzar objetivo',
                    sublabel:
                        'De ${nivelActual.toStringAsFixed(2)} → ${_objetivo.toStringAsFixed(_objetivo < 1 ? 1 : 0)} mg/L',
                    valor: mlNecesarios,
                    color: Colors.red.shade700,
                    icono: Icons.arrow_upward,
                    litros: litros,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Cada 2ml/100L aporta ${producto.aportePor2ml} ${producto.unidadAporte}',
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                _ConsejoTile(texto: producto.consejo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chip de exceso ─────────────────────────────────────────────────────────────

class _ExcesoChip extends StatelessWidget {
  final String label;
  final String valor;
  final Color color;

  const _ExcesoChip(
      {required this.label, required this.valor, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.w500)),
          Text(valor,
              style: TextStyle(
                  fontSize: 14, color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── Fila de dosis ──────────────────────────────────────────────────────────────

class _DosisRow extends StatelessWidget {
  final String label;
  final String sublabel;
  final double valor;
  final Color color;
  final IconData icono;
  final double litros;

  const _DosisRow({
    required this.label,
    required this.sublabel,
    required this.valor,
    required this.color,
    required this.icono,
    required this.litros,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              Text(sublabel,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                '${valor.toStringAsFixed(1)} ml',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                'para ${litros.toStringAsFixed(0)}L',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Consejo expandible ─────────────────────────────────────────────────────────

class _ConsejoTile extends StatefulWidget {
  final String texto;
  const _ConsejoTile({required this.texto});

  @override
  State<_ConsejoTile> createState() => _ConsejoTileState();
}

class _ConsejoTileState extends State<_ConsejoTile> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expandido = !_expandido),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💡', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Consejo Fertiliza',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade800,
                        ),
                      ),
                      Icon(
                        _expandido ? Icons.expand_less : Icons.expand_more,
                        color: Colors.amber.shade700,
                        size: 18,
                      ),
                    ],
                  ),
                  if (_expandido) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.texto,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

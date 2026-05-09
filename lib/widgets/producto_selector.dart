// widgets/producto_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/producto.dart';

class ProductoSelector extends StatelessWidget {
  final Producto producto;
  final bool seleccionado;
  final TextEditingController? controller;
  final TextEditingController? objetivoController;
  final ValueChanged<bool> onToggle;
  final VoidCallback onChanged;

  const ProductoSelector({
    super.key,
    required this.producto,
    required this.seleccionado,
    this.controller,
    this.objetivoController,
    required this.onToggle,
    required this.onChanged,
  });

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  // ── Tolerancia según tipo de producto ─────────────────────────
  static const _hierros = {'hierro_micro', 'hierro_quelatado'};

  double _tolerancia(String id) {
    if (_hierros.contains(id)) return 0.35;
    if (id == 'potasio') return 0.0; // potasio usa su propia lógica
    if (id == 'fosfato') {
      return 1.0; // fosfato: OK hasta objetivo+1, exceso desde 2.1
    }
    return 5.0; // NPK general
  }

  bool _esExceso(String id, double nivelActual, double objetivo) {
    if (id == 'potasio') return nivelActual > 20;
    if (_hierros.contains(id)) {
      return nivelActual > 0.35; // hierros: exceso fijo desde 0.36
    }
    return nivelActual > objetivo + _tolerancia(id);
  }

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(producto.color);
    final cs = Theme.of(context).colorScheme;
    final nivelActual = double.tryParse(controller?.text ?? '0') ?? 0;

    final objetivoIngresado =
        double.tryParse(objetivoController?.text ?? '') ?? 0;
    final objetivoFinal =
        objetivoIngresado > 0 ? objetivoIngresado : producto.objetivoMgL;

    final esSobredosis = _esExceso(producto.id, nivelActual, objetivoFinal);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          // ── Fila del producto ──────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onToggle(!seleccionado),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Checkbox(
                    value: seleccionado,
                    activeColor: color,
                    onChanged: (v) => onToggle(v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: esSobredosis ? Colors.red.shade500 : color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: esSobredosis
                                ? Colors.red.shade700
                                : seleccionado
                                    ? color
                                    : cs.onSurface,
                          ),
                        ),
                        Text(
                          producto.id == 'nitrogeno'
                              ? 'Sugerido: ${objetivoFinal.toStringAsFixed(objetivoFinal < 1 ? 2 : 0)} mg/L  | Relación 10 NO3 → 1 PO4'
                              : producto.id == 'fosfato'
                                  ? 'Sugerido: ${objetivoFinal.toStringAsFixed(objetivoFinal < 1 ? 2 : 0)} mg/L  | Relación 1 PO4 → 10 NO3'
                                  : producto.id == 'potasio'
                                      ? 'Sugerido: ${objetivoFinal.toStringAsFixed(objetivoFinal < 1 ? 2 : 0)} mg/L  | OK entre 10–20 mg/L' // ← CAMBIADO: 10–15 → 10–20
                                      : 'Sugerido: ${objetivoFinal.toStringAsFixed(objetivoFinal < 1 ? 2 : 0)} mg/L',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Campos (si está seleccionado) ──────────────────────────
          if (seleccionado && controller != null) ...[
            Divider(
              height: 1,
              color: esSobredosis
                  ? Colors.red.shade200
                  : color.withValues(alpha: 0.3),
              indent: 16,
              endIndent: 16,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Cuánto marcó tu test?',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                          onChanged: (_) => onChanged(),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: 'Nivel actual',
                            suffixText: 'mg/L',
                            hintText: '0.0',
                            fillColor: esSobredosis
                                ? Colors.red.withValues(alpha: 0.07)
                                : color.withValues(alpha: 0.07),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    esSobredosis ? Colors.red.shade400 : color,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Valor objetivo',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: objetivoController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                          onChanged: (_) => onChanged(),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: 'Objetivo',
                            suffixText: 'mg/L',
                            hintText: producto.objetivoMgL.toStringAsFixed(
                                producto.objetivoMgL < 1 ? 2 : 0),
                            fillColor: color.withValues(alpha: 0.07),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: color, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Si lo dejas vacío se usará ${producto.objetivoMgL.toStringAsFixed(producto.objetivoMgL < 1 ? 1 : 0)} mg/L',
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _NivelIndicador(
                    nivelActual: nivelActual,
                    objetivo: objetivoFinal,
                    color: color,
                    productoId: producto.id,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NivelIndicador extends StatelessWidget {
  final double nivelActual;
  final double objetivo;
  final Color color;
  final String productoId;

  const _NivelIndicador({
    required this.nivelActual,
    required this.objetivo,
    required this.color,
    required this.productoId,
  });

  // ── Tolerancias ────────────────────────────────────────────────
  static const _hierros = {'hierro_micro', 'hierro_quelatado'};

  double get _tolerancia {
    if (_hierros.contains(productoId)) return 0.35;
    if (productoId == 'potasio') return 0.0;
    if (productoId == 'fosfato') return 1.0; // fosfato: exceso desde 2.1
    return 5.0;
  }

  bool get _esExceso {
    if (productoId == 'potasio') return nivelActual > 20;
    if (_hierros.contains(productoId)) {
      return nivelActual > 0.35; // hierros: exceso fijo desde 0.36
    }
    return nivelActual > objetivo + _tolerancia;
  }

  bool get _esZonaOk {
    if (productoId == 'potasio') {
      return nivelActual >= 10 && nivelActual <= 20;
    }
    if (_hierros.contains(productoId)) {
      return nivelActual >= objetivo &&
          nivelActual <= 0.35; // hierros: OK hasta 0.35 fijo
    }
    // Para otros: dentro del rango [objetivo, objetivo + tolerancia] → OK
    return nivelActual >= objetivo && nivelActual <= objetivo + _tolerancia;
  }

  @override
  Widget build(BuildContext context) {
    final porcentajeReal =
        objetivo > 0 ? (nivelActual / objetivo).clamp(0.0, 1.0) : 0.0;

    final Color indicadorColor;
    final Color textColor;
    final String etiqueta;
    final String porcentajeTexto;

    if (_esExceso) {
      indicadorColor = Colors.red.shade500;
      textColor = Colors.red.shade700;
      etiqueta = '⚠ Exceso';
      if (productoId == 'potasio') {
        final excesoPct =
            ((nivelActual - 20) / 20 * 100).round(); // ← CAMBIADO: base 15 → 20
        porcentajeTexto = '+$excesoPct%';
      } else {
        final excesoPct =
            ((nivelActual - objetivo - _tolerancia) / objetivo * 100).round();
        porcentajeTexto = '+$excesoPct%';
      }
    } else if (_esZonaOk) {
      indicadorColor = Colors.green.shade500;
      textColor = Colors.green.shade600;
      etiqueta = '✓ OK';
      if (productoId == 'potasio') {
        porcentajeTexto = '${nivelActual.toStringAsFixed(0)} mg/L';
      } else {
        porcentajeTexto = '${nivelActual.toStringAsFixed(1)} mg/L';
      }
    } else if (productoId == 'potasio' && nivelActual < 10) {
      indicadorColor = color;
      textColor = color;
      etiqueta = 'Déficit';
      porcentajeTexto = '${(nivelActual / 10 * 100).toStringAsFixed(0)}%';
    } else {
      // Déficit normal
      indicadorColor = color;
      textColor = color;
      etiqueta = 'Déficit';
      porcentajeTexto = '${(porcentajeReal * 100).toStringAsFixed(0)}%';
    }

    return SizedBox(
      width: 64,
      child: Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _esExceso ? 1.0 : porcentajeReal,
                  strokeWidth: 5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(indicadorColor),
                ),
                Text(
                  porcentajeTexto,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _esZonaOk ? 8 : (_esExceso ? 9 : 11),
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            etiqueta,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

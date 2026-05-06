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

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(producto.color);
    final cs = Theme.of(context).colorScheme;
    final nivelActual = double.tryParse(controller?.text ?? '0') ?? 0;

    final objetivoIngresado =
        double.tryParse(objetivoController?.text ?? '') ?? 0;
    final objetivoFinal =
        objetivoIngresado > 0 ? objetivoIngresado : producto.objetivoMgL;

    final esSobredosis = nivelActual > objetivoFinal;

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
                                      ? 'Sugerido: ${objetivoFinal.toStringAsFixed(objetivoFinal < 1 ? 2 : 0)} mg/L  | OK entre 10–15 mg/L'
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
                    productoId: producto.id, // ← NUEVO
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
  final String productoId; // ← NUEVO

  const _NivelIndicador({
    required this.nivelActual,
    required this.objetivo,
    required this.color,
    required this.productoId, // ← NUEVO
  });

  @override
  Widget build(BuildContext context) {
    final esSobredosis = nivelActual > objetivo;

    // ── Zona OK para potasio: entre 10 y 15 mg/L ──────────────────
    final bool esZonaOkPotasio =
        productoId == 'potasio' && nivelActual >= 10 && nivelActual <= 15;

    final bool esExcesoPotasio = productoId == 'potasio' && nivelActual > 15;

    final porcentajeReal =
        objetivo > 0 ? (nivelActual / objetivo).clamp(0.0, 1.0) : 0.0;

    final Color indicadorColor;
    final Color textColor;
    final String etiqueta;
    final String porcentajeTexto;

    if (esExcesoPotasio) {
      // Potasio sobre 15 → exceso
      indicadorColor = Colors.red.shade500;
      textColor = Colors.red.shade700;
      etiqueta = '⚠ Exceso';
      final excesoPct = ((nivelActual - 15) / 15 * 100).round();
      porcentajeTexto = '+$excesoPct%';
    } else if (esZonaOkPotasio) {
      // Potasio entre 10 y 15 → OK siempre
      indicadorColor = Colors.green.shade500;
      textColor = Colors.green.shade600;
      etiqueta = '✓ OK';
      porcentajeTexto = '${nivelActual.toStringAsFixed(0)} mg/L';
    } else if (!esZonaOkPotasio &&
        productoId == 'potasio' &&
        nivelActual < 10) {
      // Potasio menor a 10 → déficit
      indicadorColor = color;
      textColor = color;
      etiqueta = 'Déficit';
      porcentajeTexto = '${(nivelActual / 10 * 100).toStringAsFixed(0)}%';
    } else if (esSobredosis) {
      // Otros productos con exceso
      indicadorColor = Colors.red.shade500;
      textColor = Colors.red.shade700;
      etiqueta = '⚠ Exceso';
      final excesoPct = ((nivelActual - objetivo) / objetivo * 100).round();
      porcentajeTexto = '+$excesoPct%';
    } else if (nivelActual >= objetivo) {
      // Otros productos en nivel óptimo
      indicadorColor = Colors.green.shade500;
      textColor = Colors.green.shade600;
      etiqueta = '✓ OK';
      porcentajeTexto = '100%';
    } else {
      // Otros productos con déficit
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
                  value:
                      esSobredosis && !esZonaOkPotasio ? 1.0 : porcentajeReal,
                  strokeWidth: 5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(indicadorColor),
                ),
                Text(
                  porcentajeTexto,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: esZonaOkPotasio ? 8 : (esSobredosis ? 9 : 11),
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

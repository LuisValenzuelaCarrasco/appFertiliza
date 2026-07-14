// widgets/producto_selector.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/producto.dart';

/// Teclado numérico decimal que funciona igual en Android que antes,
/// pero en iOS usa teclado de texto (que sí muestra el punto/coma),
/// ya que en varias versiones de Flutter el teclado numérico decimal
/// nativo de iOS no renderiza la tecla de separador decimal.
TextInputType _tecladoDecimal() {
  if (!kIsWeb && Platform.isIOS) {
    return TextInputType.text;
  }
  return const TextInputType.numberWithOptions(decimal: true);
}

/// Normaliza un texto ingresado (con coma o punto) a un double válido.
double _parseDecimal(String texto) {
  if (texto.isEmpty) return 0;
  return double.tryParse(texto.replaceAll(',', '.')) ?? 0;
}

class ProductoSelector extends StatelessWidget {
  final Producto producto;
  final bool seleccionado;
  final TextEditingController? controller;
  final TextEditingController? objetivoController;
  final ValueChanged<bool> onToggle;
  final VoidCallback onChanged;
  final String? modalidadSeleccionada;
  final ValueChanged<String>? onModalidadChanged;
  final bool modoTesteo;
  final ValueChanged<bool>? onModoTesteoChanged;

  const ProductoSelector({
    super.key,
    required this.producto,
    required this.seleccionado,
    this.controller,
    this.objetivoController,
    required this.onToggle,
    required this.onChanged,
    this.modalidadSeleccionada,
    this.onModalidadChanged,
    this.modoTesteo = false,
    this.onModoTesteoChanged,
  });

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  static const _hierros = {'hierro_micro', 'hierro_quelatado'};
  static const _conModalidad = {
    'potasio',
    'potasio_micro',
    'hierro_micro',
    'hierro_quelatado',
  };

  double _tolerancia(String id) {
    if (_hierros.contains(id)) return 0.35;
    if (id == 'potasio') return 0.0;
    if (id == 'fosfato') return 1.0;
    return 5.0;
  }

  bool _esExceso(String id, double nivelActual, double objetivo) {
    if (id == 'potasio') return nivelActual > 20;
    if (_hierros.contains(id)) return nivelActual > 0.35;
    return nivelActual > objetivo + _tolerancia(id);
  }

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(producto.color);
    final cs = Theme.of(context).colorScheme;
    final nivelActual = _parseDecimal(controller?.text ?? '0');

    final objetivoIngresado = _parseDecimal(objetivoController?.text ?? '');
    final objetivoFinal =
        objetivoIngresado > 0 ? objetivoIngresado : producto.objetivoMgL;

    final esSobredosis = _esExceso(producto.id, nivelActual, objetivoFinal);

    // Para los 4 productos con modalidad, mostrar campos de testeo
    // solo si modoTesteo == true. Para el resto, siempre mostrar.
    final esProductoConModalidad = _conModalidad.contains(producto.id);
    final mostrarCamposTesteo = seleccionado &&
        controller != null &&
        (!esProductoConModalidad || modoTesteo);

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
                                      ? 'Sugerido: ${objetivoFinal.toStringAsFixed(objetivoFinal < 1 ? 2 : 0)} mg/L  | OK entre 10–20 mg/L'
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

          // ── Selector Con/Sin testeo (solo los 4 productos con modalidad) ──
          if (seleccionado && esProductoConModalidad) ...[
            Divider(
              height: 1,
              color: esSobredosis
                  ? Colors.red.shade200
                  : color.withValues(alpha: 0.3),
              indent: 16,
              endIndent: 16,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _ModoChip(
                          label: 'Sin testeo',
                          icono: Icons.straighten_outlined,
                          seleccionado: !modoTesteo,
                          color: color,
                          onTap: () => onModoTesteoChanged?.call(false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ModoChip(
                          label: 'Con testeo',
                          icono: Icons.science_outlined,
                          seleccionado: modoTesteo,
                          color: color,
                          onTap: () => onModoTesteoChanged?.call(true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          // ── Campos de testeo ───────────────────────────────────────
          if (mostrarCamposTesteo) ...[
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
                          keyboardType: _tecladoDecimal(),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*[.,]?\d*')),
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
                          keyboardType: _tecladoDecimal(),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*[.,]?\d*')),
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

          // ── Selector Low Tech / High Tech (sin testeo, solo 4 productos) ──
          if (seleccionado &&
              !modoTesteo &&
              esProductoConModalidad &&
              producto.modalidades.length > 1 &&
              onModalidadChanged != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 1, color: color.withValues(alpha: 0.2)),
                  const SizedBox(height: 10),
                  Text(
                    'Tipo de acuario',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: producto.modalidades.map((m) {
                      final sel = (modalidadSeleccionada ??
                              producto.modalidades.first) ==
                          m;
                      return GestureDetector(
                        onTap: () => onModalidadChanged!(m),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel
                                ? color.withValues(alpha: 0.15)
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: sel ? color : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                m == 'Low Tech'
                                    ? Icons.eco_outlined
                                    : Icons.bolt_outlined,
                                size: 14,
                                color: sel ? color : cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                m,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      sel ? FontWeight.w700 : FontWeight.normal,
                                  color: sel ? color : cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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

// ── _ModoChip ─────────────────────────────────────────────────────────────────

class _ModoChip extends StatelessWidget {
  final String label;
  final IconData icono;
  final bool seleccionado;
  final Color color;
  final VoidCallback onTap;

  const _ModoChip({
    required this.label,
    required this.icono,
    required this.seleccionado,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity, // ocupa todo el ancho disponible
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado
              ? color.withValues(alpha: 0.15)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              icono,
              size: 12,
              color: seleccionado ? color : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: seleccionado ? FontWeight.w700 : FontWeight.normal,
                color: seleccionado ? color : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _NivelIndicador ───────────────────────────────────────────────────────────

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

  static const _hierros = {'hierro_micro', 'hierro_quelatado'};

  double get _tolerancia {
    if (_hierros.contains(productoId)) return 0.35;
    if (productoId == 'potasio') return 0.0;
    if (productoId == 'fosfato') return 1.0;
    return 5.0;
  }

  bool get _esExceso {
    if (productoId == 'potasio') return nivelActual > 20;
    if (_hierros.contains(productoId)) return nivelActual > 0.35;
    return nivelActual > objetivo + _tolerancia;
  }

  bool get _esZonaOk {
    if (productoId == 'potasio') {
      return nivelActual >= 10 && nivelActual <= 20;
    }
    if (_hierros.contains(productoId)) {
      return nivelActual >= objetivo && nivelActual <= 0.35;
    }
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
        final excesoPct = ((nivelActual - 20) / 20 * 100).round();
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

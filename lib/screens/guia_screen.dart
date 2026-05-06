// screens/guia_screen.dart
import 'package:flutter/material.dart';
import '../widgets/fertiliza_app_bar.dart';

class GuiaScreen extends StatelessWidget {
  const GuiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FertilizaAppBar(
        titulo: 'GUÍA NPK',
        subtitulo: 'Referencia rápida de nutrientes',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Equilibrio NPK ────────────────────────────────────────
          const _SeccionTitulo('Equilibrio NPK objetivo'),
          _EquilibrioNPKCard(),
          const SizedBox(height: 8),

          // ── Ley del mínimo ────────────────────────────────────────
          const _SeccionTitulo('Ley del Mínimo de Liebig'),
          _InfoCard(
            icono: Icons.bar_chart,
            color: Colors.purple.shade600,
            titulo: '¿Por qué importa?',
            contenido:
                'El crecimiento de las plantas está limitado por el nutriente más escaso, '
                'sin importar la abundancia de los demás. '
                'Si falta fosfato, aumentar potasio no sirve de nada: '
                'el fosfato siempre será el limitante.',
          ),
          const SizedBox(height: 8),

          // ── Deficiencias visuales ─────────────────────────────────
          const _SeccionTitulo('Deficiencias visuales'),
          ..._deficiencias.map((d) => _DeficienciaCard(
                nombre: d['nombre']!,
                sintomas: d['sintomas']!,
                color: Color(int.parse('FF${d['color']!.replaceAll('#', '')}',
                    radix: 16)),
              )),

          // ── Algas como indicador ──────────────────────────────────
          const _SeccionTitulo('Algas como bioindicadoras'),
          _InfoCard(
            icono: Icons.grass,
            color: Colors.green.shade700,
            titulo: 'Qué nos dicen las algas',
            contenido:
                '• Algas verdes puntuales y filamentosas → exceso de NO3 (nitrógeno)\n'
                '• Algas negras (barba negra) → exceso de PO4 (fosfato)\n'
                '• Algas filamentosas con parámetros en 0 → variaciones en CO2\n\n'
                'Siempre testear antes de actuar.',
          ),
          const SizedBox(height: 8),

          // ── Tabla de dosificaciones ───────────────────────────────
          const _SeccionTitulo('Tabla de dosificaciones rápidas'),
          _TablaDosis(),
          const SizedBox(height: 8),

          // ── Incidencia del pH ─────────────────────────────────────
          const _SeccionTitulo('Incidencia del pH en nutrientes'),
          _InfoCard(
            icono: Icons.science,
            color: Colors.teal.shade700,
            titulo: 'Rango óptimo: pH 6.5 – 7.5',
            contenido:
                'El pH afecta directamente la disponibilidad de nutrientes:\n\n'
                '• pH muy alto (>7.5) → bloquea hierro, manganeso y boro\n'
                '• pH muy bajo (<6.0) → reduce disponibilidad de calcio y magnesio\n'
                '• El KH bajo hace que el pH sea inestable (efecto tampón)\n\n'
                'En el mercado chileno existen sustratos nutritivos que ayudan a estabilizar el pH.',
          ),
          const SizedBox(height: 8),

          // ── Calcio y Magnesio ─────────────────────────────────────
          const _SeccionTitulo('Calcio y Magnesio'),
          _InfoCard(
            icono: Icons.water_drop,
            color: Colors.blue.shade700,
            titulo: 'Presentes en el agua potable',
            contenido:
                'Generalmente vienen en el agua potable. Monitorear dureza del agua.\n\n'
                '• Exceso de Ca → bloquea absorción de K, Mg, Fe y Mn\n'
                '• Exceso de K, Mg o Na → inhibe absorción de Ca\n\n'
                'Deficiencia de Ca: brotes nuevos retorcidos, pálidos y rugosos.\n'
                'Deficiencia de Mg: hojas más claras con venas más oscuras.',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════

final List<Map<String, String>> _deficiencias = [
  {
    'nombre': 'Deficiencia de Nitrógeno (NO3)',
    'sintomas': 'Las puntas de las hojas se vuelven verde pálido/amarillas. '
        'No confundir con deficiencia de PO4. '
        'Reducción general del color verde.',
    'color': '#C0392B',
  },
  {
    'nombre': 'Deficiencia de Fosfato (PO4)',
    'sintomas':
        'Hojas viejas toman coloración amarillenta, pueden tener zonas muertas. '
            'Las hojas se desprenden. Reducción en ramificación y debilidad de raíces.',
    'color': '#2980B9',
  },
  {
    'nombre': 'Deficiencia de Potasio (K)',
    'sintomas':
        'Pequeñas manchas amarillentas a café que se convierten en orificios. '
            'El resto de la hoja se ve normal. Necrosis en puntas de hojas.',
    'color': '#27AE60',
  },
  {
    'nombre': 'Deficiencia de Hierro (Fe)',
    'sintomas': 'Clorosis (amarillamiento) especialmente en hojas jóvenes. '
        'Afecta síntesis de clorofila y fotosíntesis.',
    'color': '#8E44AD',
  },
  {
    'nombre': 'Deficiencia de Manganeso (Mn)',
    'sintomas': 'Manchas amarillas o blancas entre las venas de las hojas. '
        'Deformación en hojas más jóvenes.',
    'color': '#D35400',
  },
  {
    'nombre': 'Deficiencia de Boro (B)',
    'sintomas': 'Necrosis en puntas y bordes de hojas. '
        'Deformidades en hojas jóvenes. Afecta sistema radicular.',
    'color': '#16A085',
  },
  {
    'nombre': 'Deficiencia de Zinc (Zn)',
    'sintomas':
        'Clorosis en nervaduras. Hojas nuevas pequeñas o con deformidades.',
    'color': '#7F8C8D',
  },
  {
    'nombre': 'Deficiencia de Molibdeno (Mo)',
    'sintomas':
        'Amarillamiento general de hojas, especialmente las más jóvenes.',
    'color': '#BDC3C7',
  },
];

// ── Widgets internos ──────────────────────────────────────────────────────────

class _SeccionTitulo extends StatelessWidget {
  final String texto;
  const _SeccionTitulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _EquilibrioNPKCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Mantener estos valores en tu acuario plantado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _NPKBadge(
                    letra: 'N',
                    nombre: 'Nitrógeno NO3',
                    valor: '10',
                    unidad: 'mg/L',
                    color: Colors.red.shade600),
                const SizedBox(width: 8),
                _NPKBadge(
                    letra: 'P',
                    nombre: 'Fosfato PO4',
                    valor: '1',
                    unidad: 'mg/L',
                    color: Colors.blue.shade600),
                const SizedBox(width: 8),
                _NPKBadge(
                    letra: 'K',
                    nombre: 'Potasio',
                    valor: '15',
                    unidad: 'mg/L',
                    color: Colors.green.shade600),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.amber.shade600.withValues(alpha: 0.4)),
              ),
              child: Text(
                '💡 La relación más importante es NO3 : PO4 = 10 : 1. '
                'Si se pierde esta proporción, aparecen las algas.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NPKBadge extends StatelessWidget {
  final String letra;
  final String nombre;
  final String valor;
  final String unidad;
  final Color color;

  const _NPKBadge({
    required this.letra,
    required this.nombre,
    required this.valor,
    required this.unidad,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              letra,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              nombre,
              style:
                  TextStyle(fontSize: 9, color: color.withValues(alpha: 0.8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              unidad,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String titulo;
  final String contenido;

  const _InfoCard({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icono, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              contenido,
              style: const TextStyle(fontSize: 13, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeficienciaCard extends StatefulWidget {
  final String nombre;
  final String sintomas;
  final Color color;

  const _DeficienciaCard({
    required this.nombre,
    required this.sintomas,
    required this.color,
  });

  @override
  State<_DeficienciaCard> createState() => _DeficienciaCardState();
}

class _DeficienciaCardState extends State<_DeficienciaCard> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expandido = !_expandido),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(
                    _expandido ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
              if (_expandido) ...[
                const SizedBox(height: 10),
                Text(
                  widget.sintomas,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TablaDosis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filas = [
      ['Nitrógeno NO3', '2ml/100L', '1 mg/L NO3', '10 mg/L'],
      ['Fosfato PO4', '2ml/100L', '0.25 mg/L PO4', '1 mg/L'],
      ['Potasio K', '2ml/100L', '1 mg/L K', '15 mg/L'],
      ['Hierro Fe', '2ml/100L', '0.05 mg/L Fe', '0.1–0.3 mg/L'],
      ['Micronutrientes', '10ml/100L', 'Dosis completa', '2x semana'],
    ];

    const headers = ['Producto', 'Dosis', 'Aporta', 'Objetivo'];
    // flex por columna
    const flex = [22, 15, 20, 18];

    Widget celda(String texto, int col,
        {bool esHeader = false, Color? bgColor}) {
      return Expanded(
        flex: flex[col],
        child: Container(
          color: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 11,
                fontWeight: esHeader ? FontWeight.w700 : FontWeight.w400,
                color: esHeader ? Colors.white : cs.onSurface,
              ),
              maxLines: 1,
            ),
          ),
        ),
      );
    }

    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Encabezado
            Container(
              color: const Color(0xFF1A5276),
              child: Row(
                children: List.generate(
                  headers.length,
                  (i) => celda(headers[i], i, esHeader: true),
                ),
              ),
            ),
            // Filas de datos
            ...filas.asMap().entries.map((e) {
              final bg = e.key % 2 == 1
                  ? cs.surfaceContainerHighest
                  : cs.surfaceContainer;
              return Row(
                children: List.generate(
                  e.value.length,
                  (i) => celda(e.value[i], i, bgColor: bg),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// screens/guia_screen.dart
import 'package:flutter/material.dart';
import '../widgets/fertiliza_app_bar.dart';
import 'bioindicadores_screen.dart';
import 'ley_minimo_screen.dart'; // ← nuevo

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
          const _SeccionTitulo('¿Cómo estimar el litraje real?'),
          const _TipsLitrajeCard(),
          const SizedBox(height: 8),

          const _SeccionTitulo('Tipos de acuario plantado'),
          const _TipoAcuarioCard(),
          const SizedBox(height: 8),

          const _SeccionTitulo('Equilibrio NPK objetivo'),
          _EquilibrioNPKCard(),
          const SizedBox(height: 8),

          const _SeccionTitulo('Ley del Mínimo de Liebig'),
          const _LeyMinimoCard(),
          const SizedBox(height: 8),

          // ── Ferti-Tips Ediciones: botón Bioindicadores ─────────────
          const _SeccionTitulo(
            'Ferti-Tips  Ediciones',
            color: Color.fromARGB(255, 22, 29, 175),
          ),
          const _BioindicadoresCard(),
          const SizedBox(height: 12),

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

          const _SeccionTitulo('Tabla de dosificaciones rápidas'),
          _TablaDosis(),
          const SizedBox(height: 8),

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
// BIOINDICADORES CARD (botón expandible con deficiencias)
// ══════════════════════════════════════════════════════════════════════════════

class _BioindicadoresCard extends StatelessWidget {
  const _BioindicadoresCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFE8F5E9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.green.shade300,
          width: 1.2,
        ),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashFactory: InkRipple.splashFactory, // ← aquí
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const BioindicadoresScreen(),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.eco, color: Colors.green.shade700, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bioindicadores',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const Text(
                      'Guía visual para identificar deficiencias\nnutricionales en plantas acuáticas',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.green.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LEY DEL MINIMO
// ══════════════════════════════════════════════════════════════════════════════
class _LeyMinimoCard extends StatelessWidget {
  const _LeyMinimoCard();

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF1A5276);

    return Card(
      color: const Color(0xFFE8F0F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashFactory: InkRipple.splashFactory,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LeyMinimoScreen(),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ley del Mínimo de Liebig',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                    Text(
                      'Flyers y guía visual sobre factores limitantes\nen el crecimiento de plantas acuáticas',
                      style: TextStyle(
                        fontSize: 11,
                        color: color.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TIPS DE LITRAJE
// ══════════════════════════════════════════════════════════════════════════════

class _TipsLitrajeCard extends StatelessWidget {
  const _TipsLitrajeCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
                    color: Colors.cyan.shade700.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Icon(Icons.water, color: Colors.cyan.shade700, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'El litraje real no es el del fabricante',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _DiagramaLitraje(),
            const SizedBox(height: 14),
            _TipItem(
              color: Colors.blue.shade600,
              icono: Icons.straighten,
              titulo: 'Mide siempre por dentro',
              contenido:
                  'El vidrio tiene grosor. Mide el interior del acuario, no el exterior. '
                  'Un acuario de 60 cm exterior puede tener solo 57–58 cm interior.',
            ),
            _TipItem(
              color: Colors.brown.shade600,
              icono: Icons.layers,
              titulo: 'El sustrato ocupa volumen',
              contenido:
                  'El litraje útil se mide desde la superficie del sustrato hasta '
                  'la línea de agua, no desde el fondo del vidrio. '
                  'Un sustrato de 5 cm en un acuario de 100 L puede restar 8–12 L reales.',
            ),
            _TipItem(
              color: Colors.grey.shade600,
              icono: Icons.terrain,
              titulo: 'Rocas y piedras desplazan agua',
              contenido:
                  'Cada roca, piedra o trozo de madera ocupa un volumen que reduce '
                  'el agua real del acuario. Una roca mediana puede desplazar 1–3 L fácilmente.',
            ),
            _TipItem(
              color: Colors.green.shade600,
              icono: Icons.eco,
              titulo: 'Las plantas también cuentan',
              contenido:
                  'Las plantas de gran porte (Vallisneria densa, matas de Cryptocoryne) '
                  'reducen el volumen efectivo. Menos agua = parámetros más inestables.',
            ),
            _TipItem(
              color: Colors.orange.shade700,
              icono: Icons.warning_amber_rounded,
              titulo: 'Regla práctica para dosificar',
              contenido:
                  'Usa entre el 70–80% del volumen total del fabricante como referencia '
                  'al calcular dosis de fertilizantes. Es más seguro subdosificar '
                  'y ajustar según parámetros reales.',
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.cyan.shade700.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.cyan.shade700.withValues(alpha: 0.3)),
              ),
              child: Text(
                '💡 Para calcular los litros de un acuario se mide el largo × ancho × alto '
                'en centímetros. Luego se descuenta el espacio ocupado por sustrato, rocas '
                'y plantas para obtener el agua real del acuario.',
                style:
                    TextStyle(fontSize: 12, height: 1.5, color: cs.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final Color color;
  final IconData icono;
  final String titulo;
  final String contenido;

  const _TipItem({
    required this.color,
    required this.icono,
    required this.titulo,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 1),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icono, size: 15, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$titulo\n',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: contenido,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagramaLitraje extends StatelessWidget {
  const _DiagramaLitraje();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 210,
      child: CustomPaint(
        painter: _LitrajePainter(isDark: isDark),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _LitrajePainter extends CustomPainter {
  final bool isDark;
  const _LitrajePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final glassColor = isDark ? Colors.cyan.shade200 : Colors.cyan.shade700;
    final waterColor =
        isDark ? const Color(0x551A3A6B) : const Color(0x55B3D8F5);
    final substrColor =
        isDark ? const Color(0xFF5D4037) : const Color(0xFFBCAAA4);
    final substrDark =
        isDark ? const Color(0xFF3E2723) : const Color(0xFF8D6E63);
    final rockColor =
        isDark ? const Color(0xFF546E7A) : const Color(0xFF90A4AE);
    final rockDark = isDark ? const Color(0xFF37474F) : const Color(0xFF607D8B);
    final plantColor =
        isDark ? const Color(0xFF2E7D32) : const Color(0xFF43A047);
    final plantDark =
        isDark ? const Color(0xFF1B5E20) : const Color(0xFF2E7D32);
    final arrowColor = isDark ? Colors.amber.shade300 : Colors.orange.shade700;
    final labelColor = isDark ? Colors.white70 : Colors.black87;
    final lineColor = isDark ? Colors.white24 : Colors.black26;
    final measureColor = isDark ? Colors.blue.shade200 : Colors.blue.shade700;

    const double lx = 40.0;
    const double rx = 260.0;
    const double ty = 14.0;
    const double by = 190.0;
    const double thick = 4.0;
    const double substrH = 28.0;
    const double substrY = by - substrH;
    const double waterTopY = 30.0;

    canvas.drawRect(
        const Rect.fromLTRB(
            lx + thick / 2, substrY, rx - thick / 2, substrY + substrH * 0.5),
        Paint()..color = substrColor);
    canvas.drawRect(
        const Rect.fromLTRB(lx + thick / 2, substrY + substrH * 0.5,
            rx - thick / 2, by - thick / 2),
        Paint()..color = substrDark);
    final dotPaint = Paint()
      ..color = isDark ? Colors.brown.shade900 : Colors.brown.shade300;
    for (double xi = lx + 12; xi < rx - 10; xi += 14) {
      for (double yi = substrY + 4; yi < by - 6; yi += 8) {
        canvas.drawCircle(Offset(xi + (yi % 7), yi), 2.5, dotPaint);
      }
    }

    final rock = Path()
      ..moveTo(80, substrY)
      ..lineTo(68, substrY - 22)
      ..lineTo(78, substrY - 34)
      ..lineTo(96, substrY - 30)
      ..lineTo(108, substrY - 18)
      ..lineTo(112, substrY)
      ..close();
    canvas.drawPath(rock, Paint()..color = rockColor);
    final rockShadow = Path()
      ..moveTo(68, substrY - 22)
      ..lineTo(78, substrY - 34)
      ..lineTo(82, substrY - 30)
      ..lineTo(72, substrY - 18)
      ..close();
    canvas.drawPath(rockShadow, Paint()..color = rockDark);

    final stemPaint = Paint()
      ..color = plantDark
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final leafPaint = Paint()..color = plantColor;

    void planta(double bx, double bY, double h, int n) {
      canvas.drawLine(Offset(bx, bY), Offset(bx, bY - h), stemPaint);
      final paso = h / (n + 1);
      for (int i = 1; i <= n; i++) {
        final lY = bY - paso * i;
        final d = (i % 2 == 0) ? 1.0 : -1.0;
        final lp = Path()
          ..moveTo(bx, lY)
          ..quadraticBezierTo(bx + d * 18, lY - 6, bx + d * 14, lY + 5)
          ..close();
        canvas.drawPath(lp, leafPaint);
      }
    }

    planta(155, substrY, 55, 4);
    planta(170, substrY, 42, 3);
    planta(143, substrY, 36, 3);

    canvas.drawRect(
      Rect.fromLTRB(lx + thick / 2, waterTopY, rx - thick / 2, substrY),
      Paint()..color = waterColor,
    );

    canvas.drawRRect(
      RRect.fromLTRBR(lx, ty, rx, by, const Radius.circular(5)),
      Paint()
        ..color = glassColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = thick,
    );

    canvas.drawLine(
      Offset(lx + thick / 2, waterTopY),
      Offset(rx - thick / 2, waterTopY),
      Paint()
        ..color = measureColor.withValues(alpha: 0.7)
        ..strokeWidth = 1.5,
    );

    const double ax = rx + 22;
    final ap = Paint()
      ..color = arrowColor
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(ax, waterTopY + 2), Offset(ax, substrY - 2), ap);
    canvas.drawLine(
        const Offset(ax - 5, waterTopY + 8), Offset(ax, waterTopY + 2), ap);
    canvas.drawLine(
        const Offset(ax + 5, waterTopY + 8), Offset(ax, waterTopY + 2), ap);
    canvas.drawLine(Offset(ax - 5, substrY - 8), Offset(ax, substrY - 2), ap);
    canvas.drawLine(Offset(ax + 5, substrY - 8), Offset(ax, substrY - 2), ap);

    void punteada(double y) {
      final lp = Paint()
        ..color = lineColor
        ..strokeWidth = 0.8;
      double x = rx + thick / 2;
      while (x < ax - 2) {
        canvas.drawLine(Offset(x, y), Offset((x + 4).clamp(rx, ax - 2), y), lp);
        x += 7;
      }
    }

    punteada(waterTopY);
    punteada(substrY);

    void t(String text, Offset pos, Color color, double fs,
        {bool bold = false, TextAlign a = TextAlign.center}) {
      final tp = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
                color: color,
                fontSize: fs,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        textAlign: a,
        textDirection: TextDirection.ltr,
      )..layout();
      double ox = a == TextAlign.center
          ? pos.dx - tp.width / 2
          : a == TextAlign.right
              ? pos.dx - tp.width
              : pos.dx;
      tp.paint(canvas, Offset(ox, pos.dy - tp.height / 2));
    }

    t('Litraje', Offset(ax + 14, (waterTopY + substrY) / 2 - 7), arrowColor,
        9.5,
        bold: true, a: TextAlign.left);
    t('real', Offset(ax + 14, (waterTopY + substrY) / 2 + 5), arrowColor, 9.5,
        bold: true, a: TextAlign.left);
    t('Línea de agua', Offset(lx - 4, waterTopY + 1), measureColor, 9,
        a: TextAlign.right);
    t('Sustrato', Offset((lx + rx) / 2, substrY + substrH / 2),
        isDark ? Colors.brown.shade100 : Colors.brown.shade900, 9.5,
        bold: true);
    t('Roca', Offset(90, substrY - 40),
        isDark ? Colors.blueGrey.shade100 : Colors.blueGrey.shade800, 9);
    t('Plantas', Offset(175, waterTopY + 10),
        isDark ? Colors.green.shade200 : Colors.green.shade800, 9,
        a: TextAlign.left);
    t('← medir por dentro del vidrio →', Offset((lx + rx) / 2, by + 14),
        labelColor, 9);
  }

  @override
  bool shouldRepaint(_LitrajePainter old) => old.isDark != isDark;
}

// ══════════════════════════════════════════════════════════════════════════════
// TIPOS DE ACUARIO
// ══════════════════════════════════════════════════════════════════════════════

class _TipoAcuarioCard extends StatelessWidget {
  const _TipoAcuarioCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TipoCard(
          tipo: 'Low Tech',
          subtitulo: 'Bajo requerimiento',
          icono: Icons.eco,
          color: Colors.green.shade600,
          puntos: const [
            (
              '🌿 Elección de plantas',
              'La selección es fundamental. Revisar la ficha de cada planta antes de incorporarla. '
                  'Cryptocoryne, Echinodorus, Myriophyllum, Vallisneria son excelentes opciones. '
                  'También plantas epífitas (no van al sustrato): Anubias, Bucephalandras, Musgos, Helechos.'
            ),
            (
              '💡 Iluminación y fotoperiodo',
              'No requieren iluminación intensa. Entre 10 a 40 lúmenes por litro es suficiente. '
                  'Marcas recomendadas en Chile: Quanlong, Buen Amigo, Sobo, líneas básicas de Week Aqua y Chihiros. '
                  'Fotoperiodo recomendado: 6 a 8 horas. '
                  'Mito: "la luz hace aparecer algas" — la iluminación por sí sola no genera algas si el acuario está equilibrado.'
            ),
            (
              '💊 Abonado',
              'Se debe aportar Potasio sí o sí, ya que no se genera de forma natural. '
                  'Los micronutrientes como el hierro también son fundamentales. '
                  'Usualmente NO3 y PO4 no se abonan ya que el sistema los proporciona a través de los desechos orgánicos, '
                  'pero esto no significa que las plantas no los necesiten. '
                  'TODAS LAS PLANTAS SIN EXCEPCIÓN NECESITAN UNA NUTRICIÓN COMPLETA.'
            ),
            (
              '🧪 CO2',
              'Sin inyección de CO2. Las plantas obtienen el CO2 del ambiente y de los peces. '
                  'Puede o no contar con sustrato nutritivo.'
            ),
            (
              '⚠️ Problemas comunes',
              '• Pocas plantas y muchos peces\n'
                  '• Filtración deficiente (usar filtros que muevan 10× el volumen del agua)\n'
                  '• No abonar\n'
                  '• Incorrecta selección de plantas (ej: plantas rojas como Reineckii se pueden mantener pero no desarrollarán correctamente)\n'
                  '• Mala asesoría: no abonar NO3 y PO4 no significa que las plantas no los necesiten'
            ),
            (
              '✅ Ventajas',
              'Menor costo inicial y de mantenimiento. Más estable y tolerante a errores. Ideal para principiantes.'
            ),
          ],
        ),
        const SizedBox(height: 8),
        _TipoCard(
          tipo: 'High Tech',
          subtitulo: 'Alto requerimiento',
          icono: Icons.bolt,
          color: Colors.orange.shade700,
          puntos: const [
            (
              '🌿 Elección de plantas',
              'La elección es más amplia: todas las plantas de Low Tech se desarrollan correctamente en High Tech. '
                  'Considerar el crecimiento: plantas como Myriophyllum Green de crecimiento rápido, '
                  'si no se podan periódicamente, pueden tapar la iluminación para plantas más exigentes. '
                  'Por otra parte, son aliadas para controlar el nitrato.'
            ),
            (
              '💡 Iluminación y fotoperiodo',
              'Uno de los 4 pilares fundamentales. Entre 90 a 140 lúmenes por litro es lo ideal. '
                  'La tecnología avanzó de Watt/litro a lúmenes/litro y ahora a PAR. '
                  'Fotoperiodo recomendado: 6 a 8 horas.'
            ),
            (
              '💊 Abonado',
              'Existen varias técnicas: por bioindicadores, estimativa, testeo, etc. '
                  'La forma más segura es testeando en función de lo que las plantas consumen. '
                  'Nunca abonar menos de 3 veces por semana.\n\n'
                  'Error más común: abonar una vez a la semana o "al ojo" sin manejar bioindicadores, '
                  'sobrepoblación de peces, no testear.'
            ),
            (
              '🧪 CO2 inyectado',
              'Indispensable. Sistema de CO2 presurizado con difusor. '
                  'La falta de CO2 con alta luz genera algas de forma explosiva. '
                  'Requiere también sustrato nutritivo (comercial o casero).'
            ),
            (
              '🔬 Importancia del testeo',
              'La forma más segura de abonar NO3 y PO4 es testeando. '
                  'No basta con testear una vez: se debe crear una rutina de abonado en función al registro del testeo. '
                  'Para el potasio no es fundamental el test; el exceso se nota en hojas retorcidas como pergamino '
                  'y la deficiencia en pequeñas perforaciones en las hojas.'
            ),
            (
              '⚠️ La trinidad del Hi Tech',
              'Luz + CO2 + nutrientes equilibrados. Si falta uno de los tres, aparecen algas. '
                  'El éxito depende de mantener el balance correcto.'
            ),
          ],
        ),
      ],
    );
  }
}

class _TipoCard extends StatefulWidget {
  final String tipo;
  final String subtitulo;
  final IconData icono;
  final Color color;
  final List<(String, String)> puntos;

  const _TipoCard({
    required this.tipo,
    required this.subtitulo,
    required this.icono,
    required this.color,
    required this.puntos,
  });

  @override
  State<_TipoCard> createState() => _TipoCardState();
}

class _TipoCardState extends State<_TipoCard> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expandido = !_expandido),
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
                      color: widget.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icono, color: widget.color, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tipo,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: widget.color,
                          ),
                        ),
                        Text(
                          widget.subtitulo,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expandido ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (_expandido) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                ...widget.puntos.map((p) => _PuntoTipo(
                      titulo: p.$1,
                      contenido: p.$2,
                      color: widget.color,
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PuntoTipo extends StatelessWidget {
  final String titulo;
  final String contenido;
  final Color color;

  const _PuntoTipo({
    required this.titulo,
    required this.contenido,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$titulo\n',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: contenido,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String texto;
  final Color? color; // ← nuevo parámetro opcional

  const _SeccionTitulo(this.texto, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: color ??
              Theme.of(context)
                  .colorScheme
                  .primary, // ← usa el custom o el del tema
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
      margin: const EdgeInsets.only(bottom: 8),
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
      ['Nitrógeno NO3', '2 ml/100L', '1 mg/L NO3', '10 mg/L'],
      ['Fosfato PO4', '2 ml/100L', '0.25 mg/L PO4', '1 mg/L'],
      ['Potasio K', '2 ml/100L', '1 mg/L K', '15 mg/L'],
      ['Hierro Fe', '2 ml/100L', '0.05 mg/L Fe', '0.1–0.3 mg/L'],
      ['Micronutrientes', '10 ml/100L', 'Dosis completa', '2x semana'],
      [
        'Potenciador crec.',
        '5 ml/100L',
        'Aminoác. + vits.',
        'Diario o 2–3x/sem'
      ],
    ];

    const headers = ['Producto', 'Dosis', 'Aporta', 'Objetivo'];
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                Container(
                  color: const Color(0xFF1A5276),
                  child: Row(
                    children: List.generate(
                      headers.length,
                      (i) => celda(headers[i], i, esHeader: true),
                    ),
                  ),
                ),
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
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _InfoCard(
            icono: Icons.spa,
            color: Colors.green.shade600,
            titulo: 'Potenciador de crecimiento',
            contenido:
                'Producto complementario que aporta aminoácidos, vitaminas y '
                'extractos de algas o citoquininas que estimulan el crecimiento '
                'radicular y foliar de las plantas.\n\n'
                '• Acelera el enraizamiento de plantas recién plantadas o esquejes\n'
                '• Mejora la absorción de nutrientes a nivel celular\n'
                '• Útil tras podas fuertes o cambios de sustrato\n'
                '• No reemplaza la fertilización NPK: es un complemento\n\n'
                'Dosificar según la etiqueta del fabricante. Su uso excesivo '
                'puede favorecer el crecimiento de algas si hay exceso de luz.',
          ),
        ),
      ],
    );
  }
}

// screens/bioindicadores_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart'; // ← NUEVO import
import '../widgets/fertiliza_app_bar.dart';

class BioindicadorItem {
  final String nombre;
  final String imagen;
  const BioindicadorItem(this.nombre, this.imagen);
}

class BioindicadoresScreen extends StatelessWidget {
  const BioindicadoresScreen({super.key});

  static const List<BioindicadorItem> _items = [
    BioindicadorItem(
      'flayer fertiliza deficit',
      'lib/assets/bioindicadoresplantas/flayer fertiliza.jpeg',
    ),
    BioindicadorItem(
      'Indicadores Visuales',
      'lib/assets/bioindicadoresplantas/indicadoresVisuales.jpeg',
    ),
    BioindicadorItem(
      'Macro Nutrientes',
      'lib/assets/bioindicadoresplantas/macroNutrientes.jpeg',
    ),
    BioindicadorItem(
      'Deficit de Nitrogeno (NO3)',
      'lib/assets/bioindicadoresplantas/deficitNitrogerno.jpeg',
    ),
    BioindicadorItem(
      'Deficit de Fosfato (PO4)',
      'lib/assets/bioindicadoresplantas/deficitFosfato.jpeg',
    ),
    BioindicadorItem(
      'Deficit de Potacio (K)',
      'lib/assets/bioindicadoresplantas/deficitPotacio.jpeg',
    ),
    BioindicadorItem(
      'Micronutrientes',
      'lib/assets/bioindicadoresplantas/micronutrientes.jpeg',
    ),
    BioindicadorItem(
      'Deficit Hierro (FE)',
      'lib/assets/bioindicadoresplantas/deficitHierro.jpeg',
    ),
    BioindicadorItem(
      'Deficit Micronutrientes',
      'lib/assets/bioindicadoresplantas/deficitMicronutrientes.jpeg',
    ),
    BioindicadorItem(
      'Deficit Micronutrientes',
      'lib/assets/bioindicadoresplantas/deficitMicronutrientes2.jpeg',
    ),
    BioindicadorItem(
      'Deficit Calcio y Magnecio',
      'lib/assets/bioindicadoresplantas/deficitCalcio.jpeg',
    ),
    BioindicadorItem(
      'APP FERTILIZA',
      'lib/assets/bioindicadoresplantas/Final.jpeg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FertilizaAppBar(
        titulo: 'BIOINDICADORES',
        subtitulo: 'Guía visual de deficiencias nutricionales',
        actions: [
          Text(
            '${_items.length} guías',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return _BioindicadorCard(
            item: item,
            index: index,
            onTap: () => _abrirVisor(context, index),
          );
        },
      ),
    );
  }

  void _abrirVisor(BuildContext context, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: VisorBioindicadorScreen(
            items: _items,
            indexInicial: index,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _BioindicadorCard extends StatelessWidget {
  final BioindicadorItem item;
  final int index;
  final VoidCallback onTap;

  const _BioindicadorCard({
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 3,
        shadowColor: const Color(0xFF1A5276).withValues(alpha: 0.15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: const Color(0xFF1A5276).withValues(alpha: 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Hero(
                  tag: 'bio_${item.imagen}',
                  child: Image.asset(
                    item.imagen,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, __, ___) => _PlaceholderImagen(
                      nombre: item.nombre,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A5276),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.nombre,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A3A4A),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.zoom_in_rounded,
                      size: 18,
                      color: Color(0xFF1A5276),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Placeholder ───────────────────────────────────────────────────────────────

class _PlaceholderImagen extends StatelessWidget {
  final String nombre;
  const _PlaceholderImagen({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A5276).withValues(alpha: 0.08),
            const Color(0xFF0A3D62).withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_search_rounded,
              size: 42,
              color: const Color(0xFF1A5276).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 10),
            Text(
              nombre,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF1A5276).withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Visor principal ───────────────────────────────────────────────────────────
// ELIMINADO: _ZoomAwarePagePhysics   (ya no necesario)
// ELIMINADO: _MultiTouchBlocker      (ya no necesario)
// ELIMINADO: _PaginaVisor            (ya no necesario)

class VisorBioindicadorScreen extends StatefulWidget {
  final List<BioindicadorItem> items;
  final int indexInicial;

  const VisorBioindicadorScreen({
    super.key,
    required this.items,
    required this.indexInicial,
  });

  @override
  State<VisorBioindicadorScreen> createState() =>
      _VisorBioindicadorScreenState();
}

class _VisorBioindicadorScreenState extends State<VisorBioindicadorScreen> {
  late final PageController _pageController;
  late int _indexActual;

  // ELIMINADO: bool _paginaBloqueada  (PhotoViewGallery lo maneja internamente)

  @override
  void initState() {
    super.initState();
    _indexActual = widget.indexInicial;
    _pageController = PageController(initialPage: widget.indexInicial);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Galería con zoom/swipe manejado automáticamente ──────────────
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _indexActual = i),
            scrollPhysics: const ClampingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            builder: (context, index) {
              final item = widget.items[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(item.imagen),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4.0,
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: 'bio_${item.imagen}',
                ),
                errorBuilder: (_, __, ___) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white24,
                      size: 64,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.nombre,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          // ── Barra superior ───────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.items[_indexActual].nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_indexActual + 1} / ${widget.items.length}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ELIMINADO: badge "Zoom activo" (estado ya no existe)
                  ],
                ),
              ),
            ),
          ),

          // ── Indicadores de página ────────────────────────────────────────
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _IndicadoresPagina(
                total: widget.items.length,
                actual: _indexActual,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Indicadores de página ─────────────────────────────────────────────────────

class _IndicadoresPagina extends StatelessWidget {
  final int total;
  final int actual;

  const _IndicadoresPagina({required this.total, required this.actual});

  @override
  Widget build(BuildContext context) {
    if (total > 10) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${actual + 1} de $total',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final esActual = i == actual;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: esActual ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color:
                esActual ? Colors.white : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

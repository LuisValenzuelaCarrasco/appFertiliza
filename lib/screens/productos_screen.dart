// screens/productos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../widgets/fertiliza_app_bar.dart';

class ProductoItem {
  final String nombre;
  final String imagen;
  const ProductoItem(this.nombre, this.imagen);
}

class ProductosScreen extends StatelessWidget {
  const ProductosScreen({super.key});

  static const List<ProductoItem> _productos = [
    ProductoItem('Nitrógeno NO3', 'lib/assets/productos/Nitrogeno.jpeg'),
    ProductoItem('Fosfato PO4', 'lib/assets/productos/Fosfato.jpeg'),
    ProductoItem('Potasio K', 'lib/assets/productos/Potacio.jpeg'),
    ProductoItem('Potasio + Micronutrientes',
        'lib/assets/productos/potacio mas micronutrientes.jpeg'),
    ProductoItem('Potasio + Micronutrientes ',
        'lib/assets/productos/potacio mas micronutrientes 2.jpeg'),
    ProductoItem('Hierro + Micronutrientes',
        'lib/assets/productos/Hierro mas micronutrientes.jpeg'),
    ProductoItem(
        'Hierro Fe Quelatado', 'lib/assets/productos/hierro quelatado.jpeg'),
    ProductoItem(
        'Micronutrientes', 'lib/assets/productos/micronutrientes.jpeg'),
    ProductoItem('Potenciador de Crecimiento',
        'lib/assets/productos/potenciador de crecimiento.jpeg'),
    ProductoItem('Potenciador de Crecimiento (info)',
        'lib/assets/productos/potenciador de crecimiento 2.jpeg'),
    ProductoItem('Potenciador de Crecimiento (tips)',
        'lib/assets/productos/potenciador de crecimiento 3.jpeg'),
    ProductoItem('Potenciador de Crecimiento (contenido)',
        'lib/assets/productos/potenciador de crecimiento 4.jpeg'),
    ProductoItem('Anti-Algas + Carbono CO2',
        'lib/assets/productos/anti algas carbono co2.jpeg'),
    ProductoItem('Anti -Alga H2O', 'lib/assets/productos/anti-alga h2o2.jpeg'),
    ProductoItem('Anticloro', 'lib/assets/productos/anticloro.jpeg'),
    ProductoItem('Acondicionador Multivitamínico',
        'lib/assets/productos/acondicionador multivitaminico.jpeg'),
    ProductoItem(
        'Análisis Cloro y Cloraminas', 'lib/assets/productos/analisis 1 .jpeg'),
    ProductoItem(
        'Análisis Amonio y Metales', 'lib/assets/productos/analisis 2.jpeg'),
    ProductoItem(
        'Bacterias Vivas', 'lib/assets/productos/bacterias vivas.jpeg'),
    ProductoItem('Bacterias Vivas (info)',
        'lib/assets/productos/bacterias vivas 2.jpeg'),
    ProductoItem(
        'Material Filtrante', 'lib/assets/productos/material filtrante.jpeg'),
    ProductoItem('Material Filtrante Biologico talla m ',
        'lib/assets/productos/filtrante biologico talla m.jpeg'),
    ProductoItem('MaterialApp FIltrante biologico Talla l',
        'lib/assets/productos/filtrante biologico talla l.jpeg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FertilizaAppBar(
        titulo: 'PRODUCTOS',
        subtitulo: 'Catálogo Fertiliza',
        actions: [
          Text(
            '${_productos.length} productos',
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
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final p = _productos[index];
          return _ProductoCard(
            producto: p,
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
          child: VisorImagenScreen(
            productos: _productos,
            indexInicial: index,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _ProductoCard extends StatelessWidget {
  final ProductoItem producto;
  final int index;
  final VoidCallback onTap;

  const _ProductoCard({
    required this.producto,
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
                  tag: 'producto_${producto.imagen}',
                  child: Image.asset(
                    producto.imagen,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, __, ___) => _PlaceholderImagen(
                      nombre: producto.nombre,
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
                        producto.nombre,
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
// ELIMINADO: _ZoomAwarePagePhysics  (PhotoViewGallery maneja zoom/swipe solo)
// ELIMINADO: _PaginaVisor           (reemplazado por PhotoViewGalleryPageOptions)
// ELIMINADO: bool _paginaBloqueada  (estado ya no necesario)
// ELIMINADO: _onZoomChanged         (callback ya no necesario)

class VisorImagenScreen extends StatefulWidget {
  final List<ProductoItem> productos;
  final int indexInicial;

  const VisorImagenScreen({
    super.key,
    required this.productos,
    required this.indexInicial,
  });

  @override
  State<VisorImagenScreen> createState() => _VisorImagenScreenState();
}

class _VisorImagenScreenState extends State<VisorImagenScreen> {
  late final PageController _pageController;
  late int _indexActual;

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
            itemCount: widget.productos.length,
            onPageChanged: (i) => setState(() => _indexActual = i),
            scrollPhysics: const ClampingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            builder: (context, index) {
              final item = widget.productos[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(item.imagen),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 5.0,
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: 'producto_${item.imagen}',
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
                            widget.productos[_indexActual].nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_indexActual + 1} / ${widget.productos.length}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ELIMINADO: badge "Zoom activo"
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
                total: widget.productos.length,
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

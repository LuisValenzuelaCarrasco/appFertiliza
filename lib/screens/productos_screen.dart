// screens/productos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      // ── Lista de productos ────────────────────────────────────────────────
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

// ── Card de producto en la lista ─────────────────────────────────────────────

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
              // Imagen
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
              // Footer con nombre
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

// ── Placeholder cuando falla la imagen ───────────────────────────────────────

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

// ── Physics personalizados: se bloquean cuando hay zoom activo ───────────────

class _ZoomAwarePagePhysics extends PageScrollPhysics {
  final bool bloqueado;
  const _ZoomAwarePagePhysics({this.bloqueado = false})
      : super(parent: const ClampingScrollPhysics());

  @override
  _ZoomAwarePagePhysics applyTo(ScrollPhysics? ancestor) {
    return _ZoomAwarePagePhysics(bloqueado: bloqueado);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (bloqueado) return 0.0; // bloquea el desplazamiento del PageView
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (bloqueado) return value - position.pixels;
    return super.applyBoundaryConditions(position, value);
  }
}

// ── Visor de imagen individual con zoom ──────────────────────────────────────

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
  // Cuando alguna página está zoomeada, bloqueamos el swipe del PageView
  bool _paginaBloqueada = false;

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

  void _onZoomChanged(bool zoomeado) {
    if (zoomeado != _paginaBloqueada) {
      setState(() => _paginaBloqueada = zoomeado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── PageView con physics que se bloquean al hacer zoom ──────────
          PageView.builder(
            controller: _pageController,
            // Physics personalizados: si hay zoom activo, no deja swipear
            physics: _ZoomAwarePagePhysics(bloqueado: _paginaBloqueada),
            itemCount: widget.productos.length,
            onPageChanged: (i) => setState(() => _indexActual = i),
            itemBuilder: (context, index) {
              return _PaginaVisor(
                producto: widget.productos[index],
                onZoomChanged: _onZoomChanged,
              );
            },
          ),

          // ── Barra superior ─────────────────────────────────────────────
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
                    // Indicador visual cuando hay zoom activo
                    if (_paginaBloqueada)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in,
                                color: Colors.white70, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'Zoom activo',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Indicadores de página (puntos abajo) ───────────────────────
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

// ── Página individual dentro del visor ───────────────────────────────────────

class _PaginaVisor extends StatefulWidget {
  final ProductoItem producto;
  // Callback que avisa al padre si esta página está zoomeada o no
  final void Function(bool zoomeado) onZoomChanged;

  const _PaginaVisor({
    required this.producto,
    required this.onZoomChanged,
  });

  @override
  State<_PaginaVisor> createState() => _PaginaVisorState();
}

class _PaginaVisorState extends State<_PaginaVisor> {
  final TransformationController _tc = TransformationController();
  bool _zoomeado = false;

  @override
  void dispose() {
    // Asegurarse de desbloquear al destruir la página
    if (_zoomeado) widget.onZoomChanged(false);
    _tc.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _tc.value = Matrix4.identity();
    _setZoom(false);
  }

  void _setZoom(bool valor) {
    if (valor == _zoomeado) return;
    setState(() => _zoomeado = valor);
    widget.onZoomChanged(valor); // notifica al PageView padre
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Doble tap: si hay zoom lo resetea, si no hay zoom hace zoom x2
      onDoubleTapDown: (details) {
        if (_zoomeado) {
          _resetZoom();
        } else {
          // Zoom x2.5 centrado en el punto donde tocó
          final pos = details.localPosition;
          final x = -pos.dx * 1.5;
          final y = -pos.dy * 1.5;
          final m = Matrix4.identity();
          m.setEntry(0, 0, 2.5); // scale X
          m.setEntry(1, 1, 2.5); // scale Y
          m.setEntry(0, 3, x / 2.5); // translate X
          m.setEntry(1, 3, y / 2.5); // translate Y
          _tc.value = m;
          _setZoom(true);
        }
      },
      child: InteractiveViewer(
        transformationController: _tc,
        minScale: 1.0,
        maxScale: 5.0,
        // Con clipBehavior none la imagen puede salir de los bordes al hacer pan
        clipBehavior: Clip.none,
        panEnabled:
            true, // siempre true; el bloqueo lo hace el PageView physics
        scaleEnabled: true,
        onInteractionUpdate: (details) {
          final escala = _tc.value.getMaxScaleOnAxis();
          _setZoom(escala > 1.05);
        },
        onInteractionEnd: (_) {
          final escala = _tc.value.getMaxScaleOnAxis();
          if (escala <= 1.05) _resetZoom();
        },
        child: Center(
          child: Hero(
            tag: 'producto_${widget.producto.imagen}',
            child: Image.asset(
              widget.producto.imagen,
              fit: BoxFit.contain,
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
                    widget.producto.nombre,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Indicadores de página (puntitos) ─────────────────────────────────────────

class _IndicadoresPagina extends StatelessWidget {
  final int total;
  final int actual;

  const _IndicadoresPagina({required this.total, required this.actual});

  @override
  Widget build(BuildContext context) {
    // Si hay muchos productos, mostrar "X / N" en lugar de puntos
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

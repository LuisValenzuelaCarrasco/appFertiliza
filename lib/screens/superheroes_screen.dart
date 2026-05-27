// screens/superheroes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/fertiliza_app_bar.dart';

class SuperheroItem {
  final String nombre;
  final String imagen;
  const SuperheroItem(this.nombre, this.imagen);
}

class SuperheroesScreen extends StatelessWidget {
  const SuperheroesScreen({super.key});

  static const List<SuperheroItem> _superheroes = [
    SuperheroItem('Comic 1', 'lib/assets/superheroes/comic1.jpeg'),
    SuperheroItem('Comic 2', 'lib/assets/superheroes/comic2.jpeg'),
    SuperheroItem('Comic 3', 'lib/assets/superheroes/comic3.jpeg'),
    SuperheroItem('Comic 4', 'lib/assets/superheroes/comic4.jpeg'),
    SuperheroItem('Comic 5', 'lib/assets/superheroes/comic5.jpeg'),
    SuperheroItem('Comic 6', 'lib/assets/superheroes/comic6.jpeg'),
    SuperheroItem('Comic 7', 'lib/assets/superheroes/comic7.jpeg'),
    SuperheroItem('Comic 8', 'lib/assets/superheroes/comic8.jpeg'),
    SuperheroItem('Comic 9', 'lib/assets/superheroes/comic9.jpeg'),
    SuperheroItem('Comic 10', 'lib/assets/superheroes/comic10.jpeg'),
    SuperheroItem('Comic 11', 'lib/assets/superheroes/comic11.jpeg'),
    SuperheroItem('Comic 12', 'lib/assets/superheroes/comic12.jpeg'),
    SuperheroItem('Comic 13', 'lib/assets/superheroes/comic13.jpeg'),
    SuperheroItem('Comic 14', 'lib/assets/superheroes/comic14.jpeg'),
    SuperheroItem('Comic 15', 'lib/assets/superheroes/comic15.jpeg'),
    SuperheroItem('Comic 16', 'lib/assets/superheroes/comic16.jpeg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FertilizaAppBar(
        titulo: 'SUPERHÉROES',
        subtitulo: 'Catálogo Comics',
        actions: [
          Text(
            '${_superheroes.length} comics',
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
        itemCount: _superheroes.length,
        itemBuilder: (context, index) {
          final p = _superheroes[index];
          return _SuperheroCard(
            superhero: p,
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
          child: VisorSuperheroScreen(
            superheroes: _superheroes,
            indexInicial: index,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}

// ── Card ─────────────────────────────────────────────────────────────────────

class _SuperheroCard extends StatelessWidget {
  final SuperheroItem superhero;
  final int index;
  final VoidCallback onTap;

  const _SuperheroCard({
    required this.superhero,
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
                  tag: 'superhero_${superhero.imagen}',
                  child: Image.asset(
                    superhero.imagen,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, __, ___) => _PlaceholderImagen(
                      nombre: superhero.nombre,
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
                        superhero.nombre,
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

// ── Physics ───────────────────────────────────────────────────────────────────

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
    if (bloqueado) return 0.0;
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (bloqueado) return value - position.pixels;
    return super.applyBoundaryConditions(position, value);
  }
}

// ── Visor ─────────────────────────────────────────────────────────────────────

class VisorSuperheroScreen extends StatefulWidget {
  final List<SuperheroItem> superheroes;
  final int indexInicial;

  const VisorSuperheroScreen({
    super.key,
    required this.superheroes,
    required this.indexInicial,
  });

  @override
  State<VisorSuperheroScreen> createState() => _VisorSuperheroScreenState();
}

class _VisorSuperheroScreenState extends State<VisorSuperheroScreen> {
  late final PageController _pageController;
  late int _indexActual;
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
          PageView.builder(
            controller: _pageController,
            physics: _ZoomAwarePagePhysics(bloqueado: _paginaBloqueada),
            itemCount: widget.superheroes.length,
            onPageChanged: (i) => setState(() => _indexActual = i),
            itemBuilder: (context, index) {
              return _PaginaVisor(
                superhero: widget.superheroes[index],
                onZoomChanged: _onZoomChanged,
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            widget.superheroes[_indexActual].nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_indexActual + 1} / ${widget.superheroes.length}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
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
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _IndicadoresPagina(
                total: widget.superheroes.length,
                actual: _indexActual,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Página individual ─────────────────────────────────────────────────────────

class _PaginaVisor extends StatefulWidget {
  final SuperheroItem superhero;
  final void Function(bool zoomeado) onZoomChanged;

  const _PaginaVisor({
    required this.superhero,
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
    widget.onZoomChanged(valor);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) {
        if (_zoomeado) {
          _resetZoom();
        } else {
          final pos = details.localPosition;
          final x = -pos.dx * 1.5;
          final y = -pos.dy * 1.5;
          final m = Matrix4.identity();
          m.setEntry(0, 0, 2.5);
          m.setEntry(1, 1, 2.5);
          m.setEntry(0, 3, x / 2.5);
          m.setEntry(1, 3, y / 2.5);
          _tc.value = m;
          _setZoom(true);
        }
      },
      child: InteractiveViewer(
        transformationController: _tc,
        minScale: 1.0,
        maxScale: 5.0,
        clipBehavior: Clip.none,
        panEnabled: true,
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
            tag: 'superhero_${widget.superhero.imagen}',
            child: Image.asset(
              widget.superhero.imagen,
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
                    widget.superhero.nombre,
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

// ── Indicadores ───────────────────────────────────────────────────────────────

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

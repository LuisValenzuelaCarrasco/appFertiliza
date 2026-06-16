import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../widgets/fertiliza_app_bar.dart';

class LeyMinimoItem {
  final String nombre;
  final String imagen;
  const LeyMinimoItem(this.nombre, this.imagen);
}

class LeyMinimoScreen extends StatelessWidget {
  const LeyMinimoScreen({super.key});

  static const List<LeyMinimoItem> _items = [
    // agrega tus flyers aquí
    LeyMinimoItem('Ley del Minimo de Liebig',
        'lib/assets/leyDelMinimo/leydelminimo1.jpeg'),
    LeyMinimoItem('Ley del Minimo de Liebig',
        'lib/assets/leyDelMinimo/leydelminimo2.jpeg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FertilizaAppBar(
        titulo: 'LEY DEL MÍNIMO',
        subtitulo: 'Factores limitantes en plantas acuáticas',
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
          return _LeyMinimoCard(
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
          child: VisorLeyMinimoScreen(
            items: _items,
            indexInicial: index,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}

class _LeyMinimoCard extends StatelessWidget {
  final LeyMinimoItem item;
  final int index;
  final VoidCallback onTap;

  const _LeyMinimoCard({
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Hero(
                  tag: 'leyminimo_${item.imagen}',
                  child: Image.asset(
                    item.imagen,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: const Color(0xFF1A5276).withValues(alpha: 0.08),
                      child: Center(
                        child: Icon(Icons.image_search_rounded,
                            size: 42,
                            color:
                                const Color(0xFF1A5276).withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(18)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    const Icon(Icons.zoom_in_rounded,
                        size: 18, color: Color(0xFF1A5276)),
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

class VisorLeyMinimoScreen extends StatefulWidget {
  final List<LeyMinimoItem> items;
  final int indexInicial;

  const VisorLeyMinimoScreen({
    super.key,
    required this.items,
    required this.indexInicial,
  });

  @override
  State<VisorLeyMinimoScreen> createState() => _VisorLeyMinimoScreenState();
}

class _VisorLeyMinimoScreenState extends State<VisorLeyMinimoScreen> {
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
                heroAttributes:
                    PhotoViewHeroAttributes(tag: 'leyminimo_${item.imagen}'),
                errorBuilder: (_, __, ___) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image_rounded,
                        color: Colors.white24, size: 64),
                    const SizedBox(height: 12),
                    Text(item.nombre,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 13),
                        textAlign: TextAlign.center),
                  ],
                ),
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
                      Colors.transparent
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.items[_indexActual].nombre,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text('${_indexActual + 1} / ${widget.items.length}',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 11)),
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
                  total: widget.items.length, actual: _indexActual),
            ),
          ),
        ],
      ),
    );
  }
}

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
              color: Colors.black54, borderRadius: BorderRadius.circular(20)),
          child: Text('${actual + 1} de $total',
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
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

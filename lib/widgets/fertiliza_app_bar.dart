// widgets/fertiliza_app_bar.dart
import 'package:flutter/material.dart';

class FertilizaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final String subtitulo;
  final List<Widget>? actions;

  const FertilizaAppBar({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDark
        ? const [Color(0xFF2C2C2C), Color(0xFF1A1A1A)]
        : const [Color(0xFF1E8449), Color(0xFF145A32)];

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight,
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          // ── Logo completo ──────────────────────────────────
          Image.asset(
            'lib/assets/logotipo/fertilizacompletologotipo.png',
            height: 32,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.eco,
              color: Colors.white70,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          // ── Subtítulo ──────────────────────────────────────
          Expanded(
            child: Text(
              subtitulo,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }
}

// services/historial_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicion.dart';

class HistorialService {
  static const _key = 'historial_mediciones';

  static Future<List<Medicion>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    return lista
        .map((e) => Medicion.fromJson(jsonDecode(e)))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> guardar(Medicion medicion) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    lista.add(jsonEncode(medicion.toJson()));
    await prefs.setStringList(_key, lista);
  }

  // ── CORREGIDO: busca por id en lugar de índice invertido ──────
  static Future<void> eliminar(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    lista.removeWhere((e) {
      try {
        return Medicion.fromJson(jsonDecode(e)).id == id;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_key, lista);
  }

  // ── CORREGIDO: busca por id en lugar de índice invertido ──────
  static Future<void> actualizar(String id, Medicion medicion) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    final i = lista.indexWhere((e) {
      try {
        return Medicion.fromJson(jsonDecode(e)).id == id;
      } catch (_) {
        return false;
      }
    });
    if (i >= 0) {
      lista[i] = jsonEncode(medicion.toJson());
      await prefs.setStringList(_key, lista);
    }
  }

  static Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> borrarPorFecha(DateTime fecha) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final filtrados = raw.where((e) {
      try {
        final m = Medicion.fromJson(jsonDecode(e));
        return !(m.fecha.year == fecha.year &&
            m.fecha.month == fecha.month &&
            m.fecha.day == fecha.day);
      } catch (_) {
        return true;
      }
    }).toList();
    await prefs.setStringList(_key, filtrados);
  }
}

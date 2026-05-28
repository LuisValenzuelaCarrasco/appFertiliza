import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicion.dart';

class HistorialService {
  // ✅ Clave única por tanque
  static String _key(String tankId) => 'historial_$tankId';

  static Future<List<Medicion>> cargar(String tankId) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key(tankId)) ?? [];
    return lista
        .map((e) => Medicion.fromJson(jsonDecode(e)))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> guardar(String tankId, Medicion medicion) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key(tankId)) ?? [];
    lista.add(jsonEncode(medicion.toJson()));
    await prefs.setStringList(_key(tankId), lista);
  }

  static Future<void> eliminar(String tankId, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key(tankId)) ?? [];
    lista.removeWhere((e) {
      try {
        return Medicion.fromJson(jsonDecode(e)).id == id;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_key(tankId), lista);
  }

  static Future<void> actualizar(
      String tankId, String id, Medicion medicion) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key(tankId)) ?? [];
    final i = lista.indexWhere((e) {
      try {
        return Medicion.fromJson(jsonDecode(e)).id == id;
      } catch (_) {
        return false;
      }
    });
    if (i >= 0) {
      lista[i] = jsonEncode(medicion.toJson());
      await prefs.setStringList(_key(tankId), lista);
    }
  }

  static Future<void> limpiar(String tankId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(tankId));
  }

  static Future<void> borrarPorFecha(String tankId, DateTime fecha) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key(tankId)) ?? [];
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
    await prefs.setStringList(_key(tankId), filtrados);
  }
}

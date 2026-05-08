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

  static Future<void> eliminar(int indexDesdeElFinal) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    final realIndex = lista.length - 1 - indexDesdeElFinal;
    if (realIndex >= 0) lista.removeAt(realIndex);
    await prefs.setStringList(_key, lista);
  }

  static Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> actualizar(
      int indexDesdeElFinal, Medicion medicion) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    final realIndex = lista.length - 1 - indexDesdeElFinal;
    if (realIndex >= 0) {
      lista[realIndex] = jsonEncode(medicion.toJson());
      await prefs.setStringList(_key, lista);
    }
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

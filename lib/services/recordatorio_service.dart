import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recordatorio.dart';

class RecordatorioService {
  static const _clave = 'recordatorios';

  static Future<List<Recordatorio>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_clave) ?? [];
    return lista.map((e) => Recordatorio.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> guardar(Recordatorio r) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_clave) ?? [];
    lista.add(jsonEncode(r.toJson()));
    await prefs.setStringList(_clave, lista);
  }

  static Future<void> eliminar(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_clave) ?? [];
    lista.removeWhere((e) {
      final r = Recordatorio.fromJson(jsonDecode(e));
      return r.id == id;
    });
    await prefs.setStringList(_clave, lista);
  }

  static Future<void> limpiarVencidos() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_clave) ?? [];
    final hoy = DateTime.now();
    // Solo borra si es de un DÍA anterior, nunca el mismo día
    final inicioDiaHoy = DateTime(hoy.year, hoy.month, hoy.day);
    lista.removeWhere((e) {
      final r = Recordatorio.fromJson(jsonDecode(e));
      final inicioDiaR = DateTime(r.fecha.year, r.fecha.month, r.fecha.day);
      return inicioDiaR.isBefore(inicioDiaHoy);
    });
    await prefs.setStringList(_clave, lista);
  }
}

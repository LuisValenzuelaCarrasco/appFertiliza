import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tank_model.dart';

class TankProvider extends ChangeNotifier {
  List<TankModel> _tanks = [];
  List<TankModel> get tanks => _tanks;

  TankProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tanks');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _tanks = list.map((e) => TankModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'tanks', jsonEncode(_tanks.map((t) => t.toJson()).toList()));
  }

  void addTank(TankModel tank) {
    _tanks.add(tank);
    _save();
    notifyListeners();
  }

  void deleteTank(String id) {
    _tanks.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }

  void updateTank(TankModel updated) {
    final index = _tanks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tanks[index] = updated;
      _save();
      notifyListeners();
    }
  }
}

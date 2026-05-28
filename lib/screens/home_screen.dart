import 'package:flutter/material.dart';
import '../models/tank_model.dart';
import 'calculadora_screen.dart';
import 'guia_screen.dart';
import 'mediciones_screen.dart';
import 'productos_screen.dart';
import 'superheroes_screen.dart';

class HomeScreen extends StatefulWidget {
  final TankModel tank;
  const HomeScreen({super.key, required this.tank});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime? _fechaOverride;

  void _irACalculadoraConFecha(DateTime fecha) {
    setState(() {
      _fechaOverride = fecha;
      _selectedIndex = 0;
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 0) _fechaOverride = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      CalculadoraScreen(
        tank: widget.tank,
        fechaOverride: _fechaOverride,
      ),
      MedicionesScreen(
        tank: widget.tank,
        onIrACalculadoraConFecha: _irACalculadoraConFecha,
      ),
      GuiaScreen(),
      ProductosScreen(),
      SuperheroesScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Calculadora',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Mi Rutina',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Ferti-Tips',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Heroes',
          ),
        ],
      ),
    );
  }
}

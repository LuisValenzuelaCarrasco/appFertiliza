import 'package:flutter/material.dart';
import 'calculadora_screen.dart';
import 'guia_screen.dart';
import 'mediciones_screen.dart';
import 'productos_screen.dart';
import 'superheroes_screen.dart'; // ← así debe quedar, con ;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    CalculadoraScreen(),
    MedicionesScreen(),
    GuiaScreen(),
    ProductosScreen(),
    SuperheroesScreen(), // 👈 NUEVO
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
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
            icon: Icon(Icons.auto_awesome_outlined), // 👈 ícono acorde
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Heroes',
          ),
        ],
      ),
    );
  }
}

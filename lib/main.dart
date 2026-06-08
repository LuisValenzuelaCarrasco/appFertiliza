import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/tank_provider.dart';
import 'screens/tanques_screen.dart';
import 'package:flutter/services.dart';
import 'services/notificacion_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacionService.init();
  runApp(const FertilizaApp());
}

class FertilizaApp extends StatelessWidget {
  const FertilizaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TankProvider(),
      child: MaterialApp(
        title: 'Fertiliza — Calculadora',
        debugShowCheckedModeBanner: false,

        // ← Agrega esto:
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],
        locale: const Locale('es', 'ES'),

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5DADE2), // ← cambiado
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF5DADE2), // ← cambiado
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            systemOverlayStyle: SystemUiOverlayStyle(
              // ← agregado
              statusBarColor: Color(0xFF5DADE2),
              statusBarIconBrightness: Brightness.light,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFF5DADE2), width: 2), // ← cambiado
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5DADE2), // ← cambiado
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        themeMode: ThemeMode.light,
        home: const TanquesScreen(),
      ),
    );
  }
}

// models/producto.dart
class Producto {
  final String id;
  final String nombre;
  final String categoria;
  final String descripcionCorta;
  final double mlPor100L;
  final double aportePor2ml;
  final double objetivoMgL;
  final String unidadAporte;
  final String color;
  final String consejo;
  final bool tieneObjetivo;
  final List<String> formatos;
  final List<String> modalidades;
  final Map<String, double> mlPorModalidad;
  final Map<String, String> consejoPorModalidad; // 👈 NUEVO

  const Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcionCorta,
    required this.mlPor100L,
    required this.aportePor2ml,
    required this.objetivoMgL,
    required this.unidadAporte,
    required this.color,
    required this.consejo,
    this.tieneObjetivo = true,
    this.formatos = const ['125ml', '225ml', '500ml', '1000ml'],
    this.modalidades = const [],
    this.mlPorModalidad = const {},
    this.consejoPorModalidad = const {}, // 👈 NUEVO
  });

  double calcularMlNecesarios(
    double nivelActual,
    double litros, {
    double? objetivo,
  }) {
    final obj = (objetivo != null && objetivo > 0) ? objetivo : objetivoMgL;
    if (nivelActual >= obj) return 0;
    final deficiencia = obj - nivelActual;
    final mlPor100LNecesarios = (deficiencia / aportePor2ml) * 2.0;
    return (mlPor100LNecesarios / 100.0) * litros;
  }

  double dosisBase(double litros) => (mlPor100L / 100.0) * litros;

  double calcularDosisPorModalidad(double litros, String modalidad) {
    final ml = mlPorModalidad[modalidad] ?? mlPor100L;
    return (ml / 100.0) * litros;
  }
}

// ── LISTA DE PRODUCTOS ────────────────────────────────────────────────────────

const List<Producto> productosFerti = [
  // ── MACRONUTRIENTES ──────────────────────────────────────────
  Producto(
    id: 'nitrogeno',
    nombre: 'Nitrógeno NO3',
    categoria: 'Macronutriente',
    descripcionCorta: 'Esencial para crecimiento y clorofila',
    mlPor100L: 2.0,
    aportePor2ml: 1.0,
    objetivoMgL: 10.0,
    unidadAporte: 'mg/L de NO3',
    color: '#C0392B',
    consejo: 'Si está en 0mg/L, añadir 20ml/100L para llegar a 10mg/L. '
        'Mantener relación NO3:PO4 = 10:1 para evitar algas.',
  ),
  Producto(
    id: 'fosfato',
    nombre: 'Fosfato PO4',
    categoria: 'Macronutriente',
    descripcionCorta: 'Fortalece raíces y mejora coloración',
    mlPor100L: 2.0,
    aportePor2ml: 0.25,
    objetivoMgL: 1.0,
    unidadAporte: 'mg/L de PO4',
    color: '#2980B9',
    consejo: 'Si está en 0mg/L, añadir 8ml/100L para llegar a 1mg/L. '
        'Producto 2.5x concentrado desde 2024: ajusta si tienes versión anterior.',
  ),
  Producto(
    id: 'potasio',
    nombre: 'Potasio K',
    categoria: 'Macronutriente',
    descripcionCorta: 'Activa enzimas y mejora resistencia',
    mlPor100L: 5.0,
    aportePor2ml: 1.0,
    objetivoMgL: 15.0,
    unidadAporte: 'mg/L de K',
    color: '#27AE60',
    consejo: 'No presente en agua potable: siempre debe suplementarse. '
        'Si está en 0mg/L, añadir 30ml/100L para llegar a 15mg/L.',
    modalidades: ['Low Tech', 'High Tech'],
    mlPorModalidad: {
      'Low Tech': 5.0,
      'High Tech': 10.0,
    },
    consejoPorModalidad: {
      'Low Tech': 'Aplicar 5 ml cada 100 L, 2 a 3 veces por semana.\n'
          '• Acuarios de bajo requerimiento.\n'
          '• 2 ml cada 100 L aporta 1 mg/L de K.\n'
          '• Si está en 0 mg/L añadir 30 ml/100 L para llegar a 15 mg/L.',
      'High Tech': 'Aplicar 10 ml cada 100 L, 2 a 3 veces por semana.\n'
          '• Acuarios de alto requerimiento.\n'
          '• 2 ml cada 100 L aporta 1 mg/L de K.\n'
          '• No exceder: niveles altos inhiben absorción de otros nutrientes.',
    },
  ),
  Producto(
    id: 'potasio_micro',
    nombre: 'Potasio + Micronutrientes',
    categoria: 'Macronutriente',
    descripcionCorta: 'Ideal para anubias, helechos y rizomas',
    mlPor100L: 5.0,
    aportePor2ml: 1.0,
    objetivoMgL: 15.0,
    unidadAporte: 'mg/L de K',
    color: '#16A085',
    consejo: 'Combinación perfecta para acuarios con plantas de rizoma.',
    modalidades: ['Low Tech', 'High Tech'],
    mlPorModalidad: {
      'Low Tech': 5.0,
      'High Tech': 10.0,
    },
    consejoPorModalidad: {
      'Low Tech': 'Aplicar 5 ml cada 100 L, 2 a 3 veces por semana.\n'
          '• Acuarios de bajo requerimiento: anubias, helechos, musgos , e.t.c.\n'
          '• 2 ml cada 100 L aporta 1 mg/L de K.\n'
          'y 30 ml/100 L aporta 0.1 mg/L de Fe.',
      'High Tech': 'Aplicar 10 ml cada 100 L, 2 a 3 veces por semana.\n'
          '• Acuarios de alto requerimiento con plantas exigentes.\n'
          '• 2 ml cada 100 L aporta 1 mg/L de K.\n'
          '• No exceder: niveles altos de K inhiben otros nutrientes.\n'
          'y 30 ml/100 L aporta 0.1 mg/L de Fe.',
    },
  ),

  // ── MICRONUTRIENTES ──────────────────────────────────────────
  Producto(
    id: 'hierro_micro',
    nombre: 'Hierro+ Micronutrientes',
    categoria: 'Micronutriente',
    descripcionCorta: 'Fe quelatado + Mn, Zn, Cu, B, Mo',
    mlPor100L: 2.0,
    aportePor2ml: 0.05,
    objetivoMgL: 0.2,
    unidadAporte: 'mg/L de Fe',
    color: '#8E44AD',
    consejo: 'Mantener entre 0.1 y 0.3 mg/L de Fe. Testear regularmente.',
    modalidades: ['Low Tech', 'High Tech'],
    mlPorModalidad: {
      'Low Tech': 2.0,
      'High Tech': 4.0,
    },
    consejoPorModalidad: {
      'Low Tech': 'Aplicar 1 a 2 ml cada 100 L, 2 a 3 veces por semana.\n'
          '• Acuarios de bajo requerimiento.\n'
          '• 2 ml cada 100 L aporta 0.05 mg/L de Fe.\n'
          '• Mantener entre 0.1 y 0.3 mg/L de Fe.',
      'High Tech': 'Aplicar 2 a 8 ml cada 100 L, 2 a 3 veces por semana.\n'
          '• Acuarios de alto requerimiento según testeo.\n'
          '• 4 ml cada 100 L aporta 0.1 mg/L de Fe.\n'
          '• Niveles muy altos favorecen algas — testear regularmente.',
    },
  ),
  Producto(
    id: 'hierro_quelatado',
    nombre: 'Hierro Fe Quelatado',
    categoria: 'Micronutriente',
    descripcionCorta: 'Quelatos EDDHA — máxima absorción',
    mlPor100L: 2.0,
    aportePor2ml: 0.05,
    objetivoMgL: 0.2,
    unidadAporte: 'mg/L de Fe',
    color: '#6D4C41',
    consejo:
        'Quelatos EDDHA — funciona en rango amplio de pH. Ideal para clorosis.',
    modalidades: ['Low Tech', 'High Tech'],
    mlPorModalidad: {
      'Low Tech': 2.0,
      'High Tech': 4.0,
    },
    consejoPorModalidad: {
      'Low Tech': 'Aplicar 1 a 2 ml cada 100 L, 2 a 3 veces por semana.\n'
          '• Acuarios de bajo requerimiento.\n'
          '• 2 ml cada 100 L aporta 0.05 mg/L de Fe.\n'
          '• Quelatos EDDHA: estable en amplio rango de pH.',
      'High Tech': 'Aplicar 2 a 8 ml cada 100 L, 2 a 3 veces por semana.\n'
          '• Acuarios de alto requerimiento según testeo.\n'
          '• 4 ml cada 100 L aporta 0.1 mg/L de Fe.\n'
          '• Ideal para corregir clorosis severa. Testear Fe regularmente.',
    },
  ),
  Producto(
    id: 'micronutrientes',
    nombre: 'Micronutrientes',
    categoria: 'Micronutriente',
    descripcionCorta: 'Todos los elementos traza quelatados',
    mlPor100L: 10.0,
    aportePor2ml: 1.0,
    objetivoMgL: 1.0,
    unidadAporte: 'dosis completa',
    color: '#F39C12',
    consejo: 'Aplicar 10ml (una tapa y media) 2 veces por semana '
        'por cada 100 litros, o después de cada cambio de agua. '
        'No recomendable para acuarios con invertebrados.',
    tieneObjetivo: false,
    modalidades: ['Uso general'],
    mlPorModalidad: {'Uso general': 10.0},
  ),

  // ── ESTIMULANTES ─────────────────────────────────────────────
  Producto(
    id: 'potenciador_crecimiento',
    nombre: 'Potenciador de Crecimiento',
    categoria: 'Estimulante',
    descripcionCorta: 'Auxinas, citoquininas y giberelinas naturales',
    mlPor100L: 5.0,
    aportePor2ml: 1.0,
    objetivoMgL: 1.0,
    unidadAporte: 'dosis',
    color: '#7B1FA2',
    consejo: 'Estimula raíces, nuevas hojas y tallos. '
        'Ideal tras podas o en plantas con crecimiento lento.',
    tieneObjetivo: false,
    formatos: ['125ml', '250ml', '500ml', '1000ml', '5000ml'],
    modalidades: ['Mantenimiento', 'Estimulación activa'],
    mlPorModalidad: {
      'Mantenimiento': 5.0,
      'Estimulación activa': 10.0,
    },
    consejoPorModalidad: {
      'Mantenimiento': 'Aplicar 5 ml cada 100 L, de 2 a 3 veces por semana.\n'
          '• Mantiene el crecimiento estable y continuo.\n'
          '• Ideal para rutina semanal de mantenimiento.',
      'Estimulación activa':
          'Aplicar 10 ml cada 100 L, de 2 a 3 veces por semana.\n'
              '🌿 Tras podas: estimula brotación y recuperación rápida.\n'
              '⚡ Activa metabolismo y macollamiento intensivo.',
    },
  ),

  // ── TRATAMIENTOS ─────────────────────────────────────────────
  Producto(
    id: 'antialgas_h2o2',
    nombre: 'Anti-Algas H₂O₂',
    categoria: 'Tratamiento',
    descripcionCorta: 'Elimina algas oxidando',
    mlPor100L: 20.0,
    aportePor2ml: 1.0,
    objetivoMgL: 1.0,
    unidadAporte: 'ml por aplicación',
    color: '#E74C3C',
    consejo: 'Iniciar con dosis baja. Apagar filtro 10-15 min tras aplicar. '
        'Evitar contacto con piel. No para musgos ni tapizantes.',
    tieneObjetivo: false,
    modalidades: ['Dosis inicial', 'Dosis máxima'],
    mlPorModalidad: {
      'Dosis inicial': 10.0,
      'Dosis máxima': 20.0,
    },
    consejoPorModalidad: {
      'Dosis inicial':
          'Aplicar 10 ml cada 100 L con filtro apagado 10-15 min.\n'
              '• Primera aplicación o algas leves.\n'
              '• Repetir cada 2-3 días si es necesario.',
      'Dosis máxima': 'Aplicar 20 ml cada 100 L con filtro apagado 10-15 min.\n'
          '⚠️ Solo si la dosis inicial no tuvo efecto en 2-3 días.\n'
          '• No usar en acuarios con musgos ni tapizantes.\n'
          '• Evitar contacto con piel y ojos.',
    },
  ),
  Producto(
    id: 'antialgas_co2',
    nombre: 'Anti-Algas+ Carbono (CO₂)',
    categoria: 'Tratamiento',
    descripcionCorta: 'Antialgas y fuente de carbono',
    mlPor100L: 5.0,
    aportePor2ml: 2.0,
    objetivoMgL: 2.0,
    unidadAporte: 'ml por aplicación',
    color: '#27AE60',
    consejo: 'No exceder la dosis recomendada. '
        'Uso restringido en musgos y tapizantes.',
    tieneObjetivo: false,
    modalidades: ['Eliminación de algas', 'Aporte de Carbono'],
    mlPorModalidad: {
      'Eliminación de algas': 5.0,
      'Aporte de Carbono': 2.0,
    },
    consejoPorModalidad: {
      'Eliminación de algas':
          'Aplicar 5 ml cada 100 L directamente sobre las algas.\n'
              '• Retirar manualmente la mayoría antes de aplicar.\n'
              '• Apagar filtro 15-20 min y luz durante el tratamiento.\n'
              '• Uso diario por 7 días. No para musgos ni tapizantes.',
      'Aporte de Carbono':
          'Aplicar 2 ml cada 100 L antes de encender las luces.\n'
              '• Uso diario como fuente de carbono orgánico.\n'
              '• Estimula el crecimiento de plantas en acuarios sin CO₂.\n'
              '• Reducir dosis si aparecen algas.',
    },
  ),

  // ── ACONDICIONADORES ─────────────────────────────────────────
  Producto(
    id: 'anticloro',
    nombre: 'Anticloro',
    categoria: 'Acondicionador',
    descripcionCorta: 'Elimina cloro del agua potable en segundos',
    mlPor100L: 2.5,
    aportePor2ml: 1.0,
    objetivoMgL: 1.0,
    unidadAporte: 'dosis',
    color: '#3498DB',
    consejo: '1 gota por cada 2 litros. 5ml para 200L. '
        'No modifica el pH. Usar siempre con agua de la llave.',
    tieneObjetivo: false,
    modalidades: ['Uso normal'],
    mlPorModalidad: {'Uso normal': 2.5},
  ),
  Producto(
    id: 'acondicionador_multivitaminico',
    nombre: 'Acondicionador Multivitamínico',
    categoria: 'Acondicionador',
    descripcionCorta: 'Elimina cloro, cloraminas y metales pesados',
    mlPor100L: 2.5,
    aportePor2ml: 1.0,
    objetivoMgL: 1.0,
    unidadAporte: 'dosis',
    color: '#E65100',
    consejo: '1ml cada 40 litros (1 gota por cada 2L). '
        'Elimina cloro, cloraminas, amonio y nitritos. '
        'Neutraliza metales pesados. Seguro para peces e invertebrados.',
    tieneObjetivo: false,
    formatos: ['125ml', '250ml', '500ml', '1000ml', '5000ml'],
    modalidades: ['Cambio de agua'],
    mlPorModalidad: {
      'Cambio de agua': 2.5,
    },
  ),

  // ── BIOLÓGICO ────────────────────────────────────────────────
  Producto(
    id: 'bacterias_vivas',
    nombre: 'Bacterias Vivas',
    categoria: 'Biológico',
    descripcionCorta: 'Nitrosomonas + Nitrobacter para el ciclo N',
    mlPor100L: 5.0,
    aportePor2ml: 1.0,
    objetivoMgL: 1.0,
    unidadAporte: 'dosis',
    color: '#E91E63',
    consejo: 'Usar siempre después de limpiar el filtro o tratar enfermedades. '
        'Verificar amonio y nitritos 2h después.',
    tieneObjetivo: false,
    formatos: ['50ml', '125ml', '225ml', '500ml', '1000ml'],
    modalidades: ['Acuario nuevo', 'Acuario ciclado'],
    mlPorModalidad: {
      'Acuario nuevo': 10.0,
      'Acuario ciclado': 5.0,
    },
    consejoPorModalidad: {
      'Acuario nuevo': 'Aplicar 10 ml cada 100 L en acuario recién montado.\n'
          '• Acelera el ciclo del nitrógeno desde cero.\n'
          '• Repetir cada 2 días durante la primera semana.\n'
          '• Verificar amonio y nitritos a las 2h de aplicar.',
      'Acuario ciclado': 'Aplicar 5 ml cada 100 L en acuario ya establecido.\n'
          '• Usar tras limpieza de filtro o tratamiento con medicamentos.\n'
          '• Repone las bacterias beneficiosas eliminadas.\n'
          '• Una sola dosis suele ser suficiente.',
    },
  ),
];

// ── GETTERS ───────────────────────────────────────────────────────────────────

List<Producto> get productosTesteables => productosFerti
    .where((p) => p.tieneObjetivo && p.id != 'micronutrientes')
    .toList();

List<Producto> get productosAdicionales =>
    productosFerti.where((p) => !p.tieneObjetivo).toList();

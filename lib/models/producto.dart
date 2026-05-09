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
  final List<String> modalidades; // ← nuevo: para productos con varios modos
  final Map<String, double> mlPorModalidad; // ← nuevo: ml según modalidad

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

  /// Para productos adicionales: calcula según modalidad elegida
  double calcularDosisPorModalidad(double litros, String modalidad) {
    final ml = mlPorModalidad[modalidad] ?? mlPor100L;
    return (ml / 100.0) * litros;
  }
}

final List<Producto> productosFerti = [
  // ── MACRONUTRIENTES ──────────────────────────────────────────
  const Producto(
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
  const Producto(
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
  const Producto(
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
        'Si está en 0mg/L, añadir 30ml/100L para llegar a 15mg/L. '
        'No exceder: inhibe absorción de otros nutrientes.',
  ),

  const Producto(
    id: 'potasio_micro',
    nombre: 'Potasio + Micronutrientes',
    categoria: 'Macronutriente',
    descripcionCorta: 'Ideal para anubias, helechos y rizomas',
    mlPor100L: 5.0,
    aportePor2ml: 1.0,
    objetivoMgL: 15.0,
    unidadAporte: 'mg/L de K',
    color: '#16A085',
    consejo: 'Combinación perfecta para acuarios con plantas de rizoma. '
        'Hierro: 30ml/100L aporta 0.1mg/L de Fe. '
        'Ideal Low Tech con plantas de bajo consumo.',
  ),

  // ── MICRONUTRIENTES ──────────────────────────────────────────
  const Producto(
    id: 'hierro_micro',
    nombre: 'Hierro+ Micronutrientes',
    categoria: 'Micronutriente',
    descripcionCorta: 'Fe quelatado + Mn, Zn, Cu, B, Mo',
    mlPor100L: 2.0,
    aportePor2ml: 0.05,
    objetivoMgL: 0.2,
    unidadAporte: 'mg/L de Fe',
    color: '#8E44AD',
    consejo: 'Mantener entre 0.1 y 0.3mg/L de Fe. '
        'Niveles muy altos favorecen algas. '
        'Testear Fe regularmente. No para acuarios con invertebrados.',
  ),
  const Producto(
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
        'Quelatos EDDHA de alta estabilidad — funciona en rango amplio de pH. '
        'Ideal para corregir clorosis. No contiene nitratos ni fosfatos.',
  ),
  const Producto(
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

  // ── TRATAMIENTOS ─────────────────────────────────────────────
  const Producto(
    id: 'potenciador_crecimiento',
    nombre: 'Potenciador de Crecimiento',
    categoria: 'Estimulante',
    descripcionCorta: 'Auxinas, citoquininas y giberelinas naturales',
    mlPor100L: 5.0,
    aportePor2ml: 1.0,
    objetivoMgL: 1.0,
    unidadAporte: 'dosis',
    color: '#7B1FA2',
    consejo: 'Aplicar 5ml por cada 100 litros, 2 veces por semana. '
        'Estimula raíces, nuevas hojas y tallos. '
        'Ideal tras podas o en plantas con crecimiento lento.',
    tieneObjetivo: false,
    formatos: ['125ml', '250ml', '500ml', '1000ml', '5000ml'],
    modalidades: ['Mantenimiento', 'Estimulación activa'],
    mlPorModalidad: {
      'Mantenimiento': 5.0,
      'Estimulación activa': 10.0,
    },
  ),

  const Producto(
    id: 'antialgas_h2o2',
    nombre: 'Anti-Algas H₂O₂',
    categoria: 'Tratamiento',
    descripcionCorta: 'elimina algas oxidando',
    mlPor100L: 20.0,
    aportePor2ml: 1.0,
    objetivoMgL: 1.0,
    unidadAporte: 'ml por aplicación',
    color: '#E74C3C',
    consejo:
        'Iniciar con dosis baja. Máx. 20ml/100L con filtro apagado 10-15 min. '
        'Puede subir a 40ml/100L si no mejora en 2-3 días. '
        'Evitar contacto con piel. No para musgos ni tapizantes.',
    tieneObjetivo: false,
    modalidades: ['Dosis inicial', 'Dosis máxima'],
    mlPorModalidad: {
      'Dosis inicial': 20.0,
      'Dosis máxima': 40.0,
    },
  ),

  const Producto(
    id: 'antialgas_co2',
    nombre: 'Anti-Algas+ Carbono (CO₂)',
    categoria: 'Tratamiento',
    descripcionCorta: ' antialgas y fuente de carbono',
    mlPor100L: 5.0,
    aportePor2ml: 2.0,
    objetivoMgL: 2.0,
    unidadAporte: 'ml por aplicación',
    color: '#27AE60',
    consejo:
        'Eliminación de algas: retirar manualmente la mayoría, apagar filtro '
        '15-20 min y aplicar con jeringa directo en zona afectada. '
        'Máx. 5ml/100L. Apagar luz o aplicar de noche. Uso diario por 7 días. '
        'Carbono: 2ml/100L antes de encender luces, uso diario. '
        'Uso restringido en musgos y tapizantes (puede quemarlos). '
        'No exceder la dosis recomendada.',
    tieneObjetivo: false,
    modalidades: ['Eliminación de algas', 'Aporte de Carbono'],
    mlPorModalidad: {
      'Eliminación de algas': 5.0,
      'Aporte de Carbono': 2.0,
    },
  ),

  // ── ACONDICIONADORES ─────────────────────────────────────────
  const Producto(
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

  const Producto(
    id: 'acondicionador_multivitaminico',
    nombre: 'Acondicionador Multivitamínico',
    categoria: 'Acondicionador',
    descripcionCorta: 'Elimina cloro, cloraminas y metales pesados',
    mlPor100L: 2.5, // 1ml cada 40L = 2.5ml cada 100L
    aportePor2ml: 1.0,
    objetivoMgL: 1.0,
    unidadAporte: 'dosis',
    color: '#E65100',
    consejo: '1ml cada 40 litros (1 gota por cada 2L). '
        'Elimina cloro, cloraminas, amonio y nitritos. '
        'Neutraliza metales pesados. Seguro para peces e invertebrados.',
    tieneObjetivo: false,
    formatos: ['125ml', '250ml', '500ml', '1000ml', '5000ml'],
    modalidades: [
      'Cambio de agua',
    ],
    mlPorModalidad: {
      'Cambio de agua': 2.5, // dosis normal 1ml/40L
    },
  ),

  // ── BIOLÓGICO ────────────────────────────────────────────────
  const Producto(
    id: 'bacterias_vivas',
    nombre: 'Bacterias Vivas',
    categoria: 'Biológico',
    descripcionCorta: 'Nitrosomonas + Nitrobacter para el ciclo N',
    mlPor100L: 5.0,
    aportePor2ml: 1.0,
    objetivoMgL: 1.0,
    unidadAporte: 'dosis',
    color: '#E91E63',
    consejo: 'Acuario nuevo: 10ml/100L. Acuario ciclado: 5ml/100L. '
        'Usar siempre después de limpiar el filtro o tratar enfermedades. '
        'Verificar amonio y nitritos 2h después.',
    tieneObjetivo: false,
    formatos: ['50ml', '125ml', '225ml', '500ml', '1000ml'],
    modalidades: ['Acuario nuevo', 'Acuario ciclado'],
    mlPorModalidad: {
      'Acuario nuevo': 10.0,
      'Acuario ciclado': 5.0,
    },
  ),
];

/// Productos con testeo de nivel (NPK + hierros)
List<Producto> get productosTesteables => productosFerti
    .where((p) => p.tieneObjetivo && p.id != 'micronutrientes')
    .toList();

/// Productos adicionales: dosis directa sin testeo
List<Producto> get productosAdicionales =>
    productosFerti.where((p) => !p.tieneObjetivo).toList();

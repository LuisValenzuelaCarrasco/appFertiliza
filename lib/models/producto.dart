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
  });

  /// Calcula los ml necesarios para subir de [nivelActual] al [objetivo].
  /// Si no se pasa [objetivo], usa [objetivoMgL] del producto.
  /// Fórmula: deficiencia = objetivo - nivelActual
  ///          ml = (deficiencia / aportePor2ml) * 2.0 * (litros / 100)
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

  double dosisBase(double litros) {
    return (mlPor100L / 100.0) * litros;
  }
}

final List<Producto> productosFerti = [
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
    formatos: ['125ml', '225ml', '500ml', '1000ml'],
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
    formatos: ['125ml', '225ml', '500ml', '1000ml'],
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
    formatos: ['125ml', '225ml', '500ml', '1000ml'],
  ),
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
    formatos: ['125ml', '225ml', '500ml', '1000ml'],
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
    formatos: ['125ml', '225ml', '500ml', '1000ml'],
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
    formatos: ['125ml', '225ml', '500ml', '1000ml'],
  ),
  const Producto(
    id: 'potasio_micro',
    nombre: 'Potasio + Micronutrientes',
    categoria: 'Micronutriente',
    descripcionCorta: 'Ideal para anubias, helechos y rizomas',
    mlPor100L: 5.0,
    aportePor2ml: 1.0,
    objetivoMgL: 15.0,
    unidadAporte: 'mg/L de K',
    color: '#16A085',
    consejo: 'Combinación perfecta para acuarios con plantas de rizoma. '
        'Hierro: 30ml/100L aporta 0.1mg/L de Fe. '
        'Ideal Low Tech con plantas de bajo consumo.',
    formatos: ['125ml', '225ml', '500ml', '1000ml'],
  ),
  const Producto(
    id: 'antialgas_co2',
    nombre: 'Anti-Algas + Carbono CO2',
    categoria: 'Tratamiento',
    descripcionCorta: 'Glutaraldehído 2% — abono de carbono',
    mlPor100L: 2.0,
    aportePor2ml: 1.0,
    objetivoMgL: 1.0,
    unidadAporte: 'dosis diaria',
    color: '#1ABC9C',
    consejo: 'Como carbono: 2ml/100L antes de encender luces, uso diario. '
        'Como antialgas: máx. 5ml/100L con filtro apagado 15-20 min. '
        'Cuidado con musgos y tapizantes frágiles.',
    tieneObjetivo: false,
    formatos: ['125ml', '225ml', '500ml', '1000ml'],
  ),
  const Producto(
    id: 'antialgas_h2o2',
    nombre: 'Anti-Algas H2O2',
    categoria: 'Tratamiento',
    descripcionCorta: 'Peróxido 5% — elimina algas oxidando',
    mlPor100L: 20.0,
    aportePor2ml: 1.0,
    objetivoMgL: 1.0,
    unidadAporte: 'ml por aplicación',
    color: '#E74C3C',
    consejo:
        'Iniciar con dosis bajas. Máx. 20ml/100L con filtro apagado 10-15 min. '
        'Puede llegar hasta 40ml/100L si no mejora en 2-3 días. '
        'Evitar contacto con piel. No para musgos ni tapizantes.',
    tieneObjetivo: false,
    formatos: ['125ml', '225ml', '500ml', '1000ml'],
  ),
  const Producto(
    id: 'anticloro',
    nombre: 'Anticloro',
    categoria: 'Acondicionador',
    descripcionCorta: 'Elimina cloro del agua potable',
    mlPor100L: 2.5,
    aportePor2ml: 1.0,
    objetivoMgL: 1.0,
    unidadAporte: 'dosis',
    color: '#3498DB',
    consejo: '1 gota por cada 2 litros de agua. '
        '5ml para 200 litros. No modifica el pH. '
        'Usar siempre con agua de la llave antes de cambios.',
    tieneObjetivo: false,
    formatos: ['125ml', '225ml', '500ml', '1000ml'],
  ),
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
  ),
];

List<Producto> get productosTesteables => productosFerti
    .where((p) => p.tieneObjetivo && p.id != 'micronutrientes')
    .toList();

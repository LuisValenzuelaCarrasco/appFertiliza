// models/medicion.dart
enum TipoEvento { abono, cambioAgua, poda }

class Medicion {
  final DateTime fecha;
  final double litros;
  final Map<String, double> niveles;
  final Map<String, double> nivelesActuales;
  final Map<String, double> objetivos;
  final TipoEvento tipoEvento;
  final double? porcentajeCambioAgua;
  final String? notasPoda;

  Medicion({
    required this.fecha,
    required this.litros,
    required this.niveles,
    this.nivelesActuales = const {},
    this.objetivos = const {},
    this.tipoEvento = TipoEvento.abono,
    this.porcentajeCambioAgua,
    this.notasPoda,
  });

  Map<String, dynamic> toJson() => {
        'fecha': fecha.toIso8601String(),
        'litros': litros,
        'niveles': niveles,
        'nivelesActuales': nivelesActuales,
        'objetivos': objetivos, // 👈 agregado
        'tipoEvento': tipoEvento.name,
        'porcentajeCambioAgua': porcentajeCambioAgua,
        'notasPoda': notasPoda,
      };

  factory Medicion.fromJson(Map<String, dynamic> json) => Medicion(
        fecha: DateTime.parse(json['fecha']),
        litros: (json['litros'] as num).toDouble(),
        niveles: json['niveles'] != null
            ? Map<String, double>.from((json['niveles'] as Map)
                .map((k, v) => MapEntry(k, (v as num).toDouble())))
            : {},
        nivelesActuales: json['nivelesActuales'] != null
            ? Map<String, double>.from((json['nivelesActuales'] as Map)
                .map((k, v) => MapEntry(k, (v as num).toDouble())))
            : {},
        objetivos: json['objetivos'] != null // 👈 agregado
            ? Map<String, double>.from((json['objetivos'] as Map)
                .map((k, v) => MapEntry(k, (v as num).toDouble())))
            : {},
        tipoEvento: TipoEvento.values.firstWhere(
          (e) => e.name == (json['tipoEvento'] ?? 'abono'),
          orElse: () => TipoEvento.abono,
        ),
        porcentajeCambioAgua: json['porcentajeCambioAgua'] != null
            ? (json['porcentajeCambioAgua'] as num).toDouble()
            : null,
        notasPoda: json['notasPoda'],
      );
}

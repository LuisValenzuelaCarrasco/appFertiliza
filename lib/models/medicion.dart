// models/medicion.dart
enum TipoEvento { abono, cambioAgua, poda, nota, recordatorio }

// Generador de UUID v4 simple sin dependencias externas
String _generarUuid() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final rand = now ^ (now >> 16);
  String hex(int n, int digits) =>
      n.toRadixString(16).padLeft(digits, '0').substring(0, digits);
  return '${hex(rand >> 32, 8)}-${hex(rand >> 16, 4)}-4${hex(rand >> 12, 3)}'
      '-${hex(8 + (rand >> 30) % 4, 1)}${hex(rand >> 28, 3)}-${hex(rand, 12)}';
}

class Medicion {
  final String id;
  final DateTime fecha;
  final double litros;
  final Map<String, double> niveles;
  final Map<String, double> nivelesActuales;
  final Map<String, double> objetivos;
  final TipoEvento tipoEvento;
  final double? porcentajeCambioAgua;
  final String? notasPoda;

  Medicion({
    String? id,
    required this.fecha,
    required this.litros,
    required this.niveles,
    this.nivelesActuales = const {},
    this.objetivos = const {},
    this.tipoEvento = TipoEvento.abono,
    this.porcentajeCambioAgua,
    this.notasPoda,
  }) : id = id ?? _generarUuid();

  Map<String, dynamic> toJson() => {
        'id': id,
        'fecha': fecha.toIso8601String(),
        'litros': litros,
        'niveles': niveles,
        'nivelesActuales': nivelesActuales,
        'objetivos': objetivos,
        'tipoEvento': tipoEvento.name,
        'porcentajeCambioAgua': porcentajeCambioAgua,
        'notasPoda': notasPoda,
      };

  factory Medicion.fromJson(Map<String, dynamic> json) => Medicion(
        id: json['id'] as String?,
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
        objetivos: json['objetivos'] != null
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
        notasPoda: json['notasPoda'] as String?,
      );
}

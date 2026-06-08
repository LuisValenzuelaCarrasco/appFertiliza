class Recordatorio {
  final int id;
  final String titulo;
  final String cuerpo;
  final DateTime fecha;

  Recordatorio({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'cuerpo': cuerpo,
        'fecha': fecha.toIso8601String(),
      };

  factory Recordatorio.fromJson(Map<String, dynamic> json) => Recordatorio(
        id: json['id'],
        titulo: json['titulo'],
        cuerpo: json['cuerpo'],
        fecha: DateTime.parse(json['fecha']),
      );
}

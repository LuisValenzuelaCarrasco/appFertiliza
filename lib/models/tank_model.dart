class TankModel {
  final String id;
  String name;
  double volume;
  DateTime setupDate;
  String? imagePath;

  TankModel({
    required this.id,
    required this.name,
    required this.volume,
    required this.setupDate,
    this.imagePath,
  });

  String get volumeLabel => '${volume.toStringAsFixed(0)} L';

  int get daysSinceSetup => DateTime.now().difference(setupDate).inDays + 1;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'volume': volume,
        'setupDate': setupDate.toIso8601String(),
        'imagePath': imagePath,
      };

  factory TankModel.fromJson(Map<String, dynamic> json) => TankModel(
        id: json['id'],
        name: json['name'],
        volume: (json['volume'] as num).toDouble(),
        setupDate: DateTime.parse(json['setupDate']),
        imagePath: json['imagePath'],
      );
  TankModel copyWith({
    String? name,
    double? volume,
    DateTime? setupDate,
    String? imagePath,
  }) {
    return TankModel(
      id: id,
      name: name ?? this.name,
      volume: volume ?? this.volume,
      setupDate: setupDate ?? this.setupDate,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

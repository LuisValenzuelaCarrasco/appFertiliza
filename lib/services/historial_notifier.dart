// services/historial_notifier.dart
import 'package:flutter/foundation.dart';

/// Notificador global: cada vez que se guarda una medición,
/// se incrementa su valor para que los listeners recarguen.
final historialNotifier = ValueNotifier<int>(0);

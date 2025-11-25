import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/paso_service.dart';

/// ViewModel que maneja el estado y la lógica de la meta de pasos
class PasoMetaViewModel extends ChangeNotifier {
  final PasoService _pasoService;
  StreamSubscription<int>? _subscription;

  int _pasos = 0;
  int _metaDiaria = 10000;
  bool _isExpanded = false;

  PasoMetaViewModel({required PasoService pasoService, int metaDiaria = 10000})
      : _pasoService = pasoService,
        _metaDiaria = metaDiaria {
    _initialize();
  }

  /// Cantidad actual de pasos
  int get pasos => _pasos;

  /// Meta diaria de pasos
  int get metaDiaria => _metaDiaria;

  /// Porcentaje de progreso (0.0 a 1.0)
  double get progressPercent {
    if (_metaDiaria <= 0) return 0.0;
    final progress = _pasos / _metaDiaria;
    return progress > 1.0 ? 1.0 : progress;
  }

  /// Indica si el widget está expandido
  bool get isExpanded => _isExpanded;

  /// Inicializar el ViewModel y escuchar los cambios de pasos
  void _initialize() {
    _subscription = _pasoService.stepsStream.listen(
      (int nuevosPasos) {
        _pasos = nuevosPasos;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error al recibir actualizaciones de pasos: $error');
      },
    );
  }

  /// Alternar entre vista expandida y compacta
  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  /// Establecer una nueva meta diaria
  void setDailyGoal(int goal) {
    if (goal != _metaDiaria && goal > 0) {
      _metaDiaria = goal;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

import 'dart:async';
import 'package:pedometer/pedometer.dart' as pedometer;
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio que proporciona un stream de conteo de pasos.
/// Usa el plugin pedometer cuando está disponible; si no, puede usar datos simulados.
/// Maneja el conteo acumulado guardando un valor base y calculando los pasos diarios.
class PasoService {
  StreamSubscription? _subscription;
  final StreamController<int> _controller = StreamController<int>.broadcast();
  bool _isInitialized = false;
  int? _baselineSteps;
  DateTime? _lastResetDate;
  bool _isFirstValue = true;

  static const String _baselineKey = 'step_baseline';
  static const String _lastResetDateKey = 'step_last_reset_date';

  /// Stream de pasos diarios (no acumulados)
  Stream<int> get stepsStream {
    if (!_isInitialized) {
      _initialize();
    }
    return _controller.stream;
  }

  /// Inicializa el servicio de pasos
  Future<void> _initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Cargar el valor base y la última fecha de reinicio
    await _loadBaseline();

    // Revisar si es un nuevo día y reiniciar si corresponde
    await _checkAndResetForNewDay();

    try {
      // Intentar usar el plugin pedometer
      print('PasoService: Cargando stream del podómetro...');
      final stepStream = pedometer.Pedometer.stepCountStream;

      print('PasoService: Iniciando stream del podómetro...');
      _subscription = stepStream.listen(
        (pedometer.StepCount event) {
          _handleStepCount(event.steps);
        },
        onError: (error) {
          print('PasoService: Error en el stream del podómetro: $error');
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('PasoService: Error al inicializar el podómetro: $e');
    }
  }

  /// Cargar el valor base de pasos y la fecha de reinicio desde almacenamiento
  Future<void> _loadBaseline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _baselineSteps = prefs.getInt(_baselineKey);
      final lastResetDateString = prefs.getString(_lastResetDateKey);

      if (lastResetDateString != null) {
        _lastResetDate = DateTime.parse(lastResetDateString);
      }

      print('PasoService: Baseline cargado: $_baselineSteps, último reinicio: $_lastResetDate');
    } catch (e) {
      print('PasoService: Error cargando baseline: $e');
    }
  }

  /// Guardar el valor base de pasos y la fecha de reinicio
  Future<void> _saveBaseline() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_baselineSteps != null) {
        await prefs.setInt(_baselineKey, _baselineSteps!);
      }

      if (_lastResetDate != null) {
        await prefs.setString(_lastResetDateKey, _lastResetDate!.toIso8601String());
      }

      print('PasoService: Baseline guardado: $_baselineSteps, último reinicio: $_lastResetDate');
    } catch (e) {
      print('PasoService: Error guardando baseline: $e');
    }
  }

  /// Verifica si es un nuevo día; si lo es, reinicia el baseline
  Future<void> _checkAndResetForNewDay() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastResetDate == null) {
      _lastResetDate = today;
      await _saveBaseline();
      return;
    }

    final lastResetDay = DateTime(
      _lastResetDate!.year,
      _lastResetDate!.month,
      _lastResetDate!.day,
    );

    if (today.isAfter(lastResetDay)) {
      print('PasoService: Nuevo día, reiniciando baseline');
      _baselineSteps = null;
      _lastResetDate = today;
      _isFirstValue = true;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_baselineKey);
        await prefs.setString(_lastResetDateKey, _lastResetDate!.toIso8601String());
      } catch (e) {
        print('PasoService: Error al limpiar baseline: $e');
      }
    }
  }

  /// Maneja los eventos del podómetro (pasos acumulados)
  void _handleStepCount(int cumulativeSteps) {
    print('PasoService: Pasos acumulados recibidos: $cumulativeSteps');

    if (_isFirstValue) {
      _baselineSteps = cumulativeSteps;
      _isFirstValue = false;
      _saveBaseline();
      print('PasoService: Nuevo baseline $cumulativeSteps, emitiendo 0 pasos');
      _controller.add(0);
      return;
    }

    if (_baselineSteps == null) {
      _baselineSteps = cumulativeSteps;
      _saveBaseline();
      _controller.add(0);
      return;
    }

    final dailySteps = cumulativeSteps - _baselineSteps!;
    final safeDailySteps = dailySteps < 0 ? 0 : dailySteps;

    print('PasoService: Acumulados: $cumulativeSteps, Baseline: $_baselineSteps, Diarios: $safeDailySteps');
    _controller.add(safeDailySteps);
  }

  /// Libera los recursos usados
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}

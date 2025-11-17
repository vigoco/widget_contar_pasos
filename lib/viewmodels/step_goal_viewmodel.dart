import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/step_service.dart';

/// ViewModel that manages step goal state and business logic
class StepGoalViewModel extends ChangeNotifier {
  final StepService _stepService;
  StreamSubscription<int>? _subscription;
  
  int _steps = 0;
  int _dailyGoal = 10000;
  bool _isExpanded = false;

  StepGoalViewModel({required StepService stepService, int dailyGoal = 10000})
      : _stepService = stepService,
        _dailyGoal = dailyGoal {
    _initialize();
  }

  /// Current step count
  int get steps => _steps;

  /// Daily step goal
  int get dailyGoal => _dailyGoal;

  /// Progress percentage (0.0 to 1.0)
  double get progressPercent {
    if (_dailyGoal <= 0) return 0.0;
    final progress = _steps / _dailyGoal;
    return progress > 1.0 ? 1.0 : progress;
  }

  /// Whether the widget is in expanded mode
  bool get isExpanded => _isExpanded;

  /// Initialize the viewmodel and listen to step updates
  void _initialize() {
    _subscription = _stepService.stepsStream.listen(
      (int newSteps) {
        _steps = newSteps;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error receiving step updates: $error');
      },
    );
  }

  /// Toggle expanded/compact view
  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  /// Set the daily goal
  void setDailyGoal(int goal) {
    if (goal != _dailyGoal && goal > 0) {
      _dailyGoal = goal;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}


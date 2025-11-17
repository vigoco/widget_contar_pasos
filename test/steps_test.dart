import 'package:flutter_test/flutter_test.dart';
import 'package:step_goal_widget/viewmodels/step_goal_viewmodel.dart';
import 'package:step_goal_widget/services/step_service.dart';
import 'dart:async';

void main() {
  group('StepGoalViewModel Tests', () {
    late StepService stepService;
    late StepGoalViewModel viewModel;
    late StreamController<int> mockStreamController;

    setUp(() {
      mockStreamController = StreamController<int>.broadcast();
      stepService = _MockStepService(mockStreamController.stream);
      viewModel = StepGoalViewModel(stepService: stepService, dailyGoal: 10000);
    });

    tearDown(() {
      viewModel.dispose();
      mockStreamController.close();
    });

    test('Progress calculation is correct for 5000 steps with 10000 goal', () async {
      // Arrange
      mockStreamController.add(5000);

      // Wait for the stream to propagate
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Assert
      expect(viewModel.steps, equals(5000));
      expect(viewModel.dailyGoal, equals(10000));
      expect(viewModel.progressPercent, equals(0.5));
    });

    test('Progress calculation is correct for 0 steps', () async {
      mockStreamController.add(0);
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(viewModel.steps, equals(0));
      expect(viewModel.progressPercent, equals(0.0));
    });

    test('Progress calculation caps at 1.0 when steps exceed goal', () async {
      mockStreamController.add(15000);
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(viewModel.steps, equals(15000));
      expect(viewModel.progressPercent, equals(1.0));
    });

    test('Progress calculation is correct for 7500 steps with 10000 goal', () async {
      mockStreamController.add(7500);
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(viewModel.steps, equals(7500));
      expect(viewModel.progressPercent, equals(0.75));
    });

    test('Toggle expanded state works correctly', () {
      expect(viewModel.isExpanded, isFalse);
      
      viewModel.toggleExpanded();
      expect(viewModel.isExpanded, isTrue);
      
      viewModel.toggleExpanded();
      expect(viewModel.isExpanded, isFalse);
    });

    test('Set daily goal updates correctly', () async {
      viewModel.setDailyGoal(15000);
      expect(viewModel.dailyGoal, equals(15000));
      
      mockStreamController.add(7500);
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(viewModel.progressPercent, equals(0.5));
    });
  });
}

/// Mock StepService for testing
class _MockStepService extends StepService {
  final Stream<int> mockStream;

  _MockStepService(this.mockStream);

  @override
  Stream<int> get stepsStream => mockStream;

  @override
  void dispose() {
    // No-op for mock
  }
}


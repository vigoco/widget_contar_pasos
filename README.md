# step_goal_widget

A Flutter package for Wear OS that provides a custom widget to track steps and display progress toward a daily step goal.

## Features

- 📊 Real-time step tracking using the pedometer plugin
- 🎯 Daily step goal visualization
- 📱 Optimized for Wear OS smartwatches
- 🔄 Compact and expanded view modes
- 👆 Tap gesture to toggle between views
- 🎨 Customizable colors and styles

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  step_goal_widget:
    git:
      url: https://github.com/yourusername/step_goal_widget.git
```

Or if published to pub.dev:

```yaml
dependencies:
  step_goal_widget: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:step_goal_widget/step_goal_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const StepGoalPage(),
    );
  }
}

class StepGoalPage extends StatefulWidget {
  const StepGoalPage({super.key});

  @override
  State<StepGoalPage> createState() => _StepGoalPageState();
}

class _StepGoalPageState extends State<StepGoalPage> {
  late final StepService _stepService;
  late final StepGoalViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _stepService = StepService();
    _viewModel = StepGoalViewModel(
      stepService: _stepService,
      dailyGoal: 10000, // Set your daily goal
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _stepService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StepGoalWidget(
        viewModel: _viewModel,
        progressColor: Colors.blue,
        backgroundColor: Colors.black,
      ),
    );
  }
}
```

### Customization

You can customize the widget appearance:

```dart
StepGoalWidget(
  viewModel: _viewModel,
  progressColor: Colors.green,
  backgroundColor: Colors.black,
  stepTextStyle: const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
  goalTextStyle: const TextStyle(
    fontSize: 18,
    color: Colors.white70,
  ),
)
```

## Widget Behavior

- **Tap**: Toggles between compact and expanded view modes
- **Compact View**: Shows circular progress indicator with step count and goal
- **Expanded View**: Shows detailed information including percentage progress

## Platform Support

- ✅ Wear OS (primary target)
- ✅ Android (with pedometer support)
- ✅ iOS (with pedometer support)
- ⚠️ Other platforms (falls back to mock data for development)

## Requirements

- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0

## License

MIT License - see LICENSE file for details.


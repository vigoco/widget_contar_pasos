import 'dart:async';
import 'package:pedometer/pedometer.dart' as pedometer;

/// Service that provides step count data stream.
/// Uses pedometer plugin when available, otherwise provides mock data.
class StepService {
  StreamSubscription? _subscription;
  final StreamController<int> _controller = StreamController<int>.broadcast();
  bool _isInitialized = false;
  Timer? _mockTimer;

  /// Stream of step counts
  Stream<int> get stepsStream {
    if (!_isInitialized) {
      _initialize();
    }
    return _controller.stream;
  }

  /// Initialize the step service
  Future<void> _initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // Try to use pedometer plugin
      final stepStream = pedometer.Pedometer.stepCountStream;
      _subscription = stepStream.listen(
        (pedometer.StepCount event) {
          _controller.add(event.steps);
        },
        onError: (error) {
          // Fallback to mock data on error
          _startMockStream();
        },
        cancelOnError: false,
      );
    } catch (e) {
      // Fallback to mock data if pedometer is not available
      _startMockStream();
    }
  }

  /// Start a mock stream for development/testing
  void _startMockStream() {
    int mockSteps = 0;
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      mockSteps += (10 + (DateTime.now().millisecond % 50));
      _controller.add(mockSteps);
    });
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _mockTimer?.cancel();
    _controller.close();
  }
}


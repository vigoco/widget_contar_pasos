import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pasos_package/pasos_package.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request activity recognition permission for step counting
  final hasPermission = await _requestPermissions();

  runApp(MyApp(hasPermission: hasPermission));
}

Future<bool> _requestPermissions() async {
  final status = await Permission.activityRecognition.request();
  if (status.isGranted) {
    print('Activity recognition permission granted');
    return true;
  } else if (status.isDenied) {
    print('Activity recognition permission denied');
    return false;
  } else if (status.isPermanentlyDenied) {
    print('Activity recognition permission permanently denied');
    // You can show a dialog here to guide the user to app settings
    return false;
  }
  return false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.hasPermission});

  final bool hasPermission;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wear OS Step Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StepGoalPage(hasPermission: hasPermission),
    );
  }
}

class StepGoalPage extends StatefulWidget {
  const StepGoalPage({super.key, required this.hasPermission});

  final bool hasPermission;

  @override
  State<StepGoalPage> createState() => _StepGoalPageState();
}

class _StepGoalPageState extends State<StepGoalPage> {
  late final PasoService? _pasoService;
  late final PasoMetaViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    if (widget.hasPermission) {
      _pasoService = PasoService();
      _viewModel = PasoMetaViewModel(
        pasoService: _pasoService!,
        metaDiaria: 10000,
      );
    } else {
      _pasoService = null;
      _viewModel = null;
    }
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    _pasoService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hasPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 64,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Permission Required',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This app needs activity recognition permission to count your steps. Please grant permission in your device settings.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final status = await Permission.activityRecognition.request();
                    if (status.isGranted) {
                      setState(() {
                        // Permission granted, reinitialize
                      });
                      // You might want to restart the app or reinitialize services here
                    }
                  },
                  child: const Text('Request Permission'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PasoMetaWidget(
        viewModel: _viewModel!,
        progressColor: Colors.blue,
        backgroundColor: Colors.black,
      ),
    );
  }
}

# pasos_package

Un paquete de Flutter para rastrear los pasos diarios con visualización del progreso hacia la meta, optimizado para smartwatches Wear OS. Este paquete proporciona una solución completa para el conteo de pasos con reinicio automático diario, almacenamiento persistente y un widget de interfaz personalizable.

## Características

* 📱 **Conteo de pasos**: Rastreo de pasos en tiempo real usando los sensores del dispositivo a través del plugin `pedometer`.
* 🎯 **Metas diarias**: Configura y rastrea el avance hacia una meta diaria de pasos.
* 🔄 **Reinicio automático**: Reinicia automáticamente el conteo de pasos a medianoche para un seguimiento diario preciso.
* 💾 **Almacenamiento persistente**: Guarda los pasos base mediante SharedPreferences para mantener precisión incluso después de cerrar la app.
* 🎨 **Widget personalizable**: Widget listo para usar, hermoso y optimizado para Wear OS, con vistas compacta y expandida.
* 📊 **Visualización del progreso**: Indicador circular mostrando el porcentaje alcanzado de la meta diaria.
* 🔐 **Manejo de permisos**: Soporte integrado para permisos de reconocimiento de actividad.

## Compatibilidad con plataformas

* ✅ Android (incluido Wear OS)

## Vista previa del widget

<p align="center">
  <img src="![599eeaed-b24c-49a1-b9c8-5400238990ee](https://github.com/user-attachments/assets/72d9a7a9-5587-4319-becc-22d25e082b31)"
       alt="Vista compacta del widget de pasos en Wear OS" 
       width="250">
</p>

<p align="center">
  <img src="/mnt/data/fc66599a-816f-43f9-915c-33dbf9363258.png" 
       alt="Vista expandida del widget en smartphone mostrando pasos y progreso" 
       width="250">
</p>


## Instalación

Agrega esto a tu archivo `pubspec.yaml`:

```yaml
dependencies:
  pasos_package:
    git:
      url: https://github.com/vigoco/widget_contar_pasos.git
```

O si se publica en pub.dev:

```yaml
dependencies:
  pasos_package: ^0.0.1
```![599eeaed-b24c-49a1-b9c8-5400238990ee](https://github.com/user-attachments/assets/d800b49b-f8ed-4c54-a2ea-50256e33db97)


Luego ejecuta:

```<img width="451" height="459" alt="Captura de pantalla 2025-11-25 010036" src="https://github.com/user-attachments/assets/e9a537ed-a70b-4c4b-baf0-a5f6ef950b34" />

flutter pub get
```

## Configuración

### Android

Agrega el siguiente permiso en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

Para Android 10 (API 29) en adelante, también agrega:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

### iOS

Agrega lo siguiente en `ios/Runner/Info.plist`:

```xml
<key>NSMotionUsageDescription</key>
<string>This app needs access to motion data to count your steps.</string>
```

## Uso

### Ejemplo básico

```dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pasos_package/pasos_package.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Solicitar permiso de reconocimiento de actividad
  final hasPermission = await Permission.activityRecognition.request();
  
  runApp(MyApp(hasPermission: hasPermission.isGranted));
}

class MyApp extends StatelessWidget {
  final bool hasPermission;
  
  const MyApp({super.key, required this.hasPermission});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StepCounterPage(hasPermission: hasPermission),
    );
  }
}

class StepCounterPage extends StatefulWidget {
  final bool hasPermission;
  
  const StepCounterPage({super.key, required this.hasPermission});

  @override
  State<StepCounterPage> createState() => _StepCounterPageState();
}

class _StepCounterPageState extends State<StepCounterPage> {
  late final PasoService? _pasoService;
  late final PasoMetaViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    if (widget.hasPermission) {
      _pasoService = PasoService();
      _viewModel = PasoMetaViewModel(
        pasoService: _pasoService!,
        metaDiaria: 10000, // Meta diaria: 10.000 pasos
      );
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
        body: Center(
          child: Text('Se requiere permiso para contar los pasos'),
        ),
      );
    }

    return Scaffold(
      body: PasoMetaWidget(
        viewModel: _viewModel!,
        progressColor: Colors.blue,
        backgroundColor: Colors.black,
      ),
    );
  }
}
```

### Usar el servicio directamente

Si deseas usar el servicio de conteo sin el widget:

```dart
final pasoService = PasoService();

// Escuchar actualizaciones de pasos
pasoService.stepsStream.listen((steps) {
  print('Pasos actuales: $steps');
});

// No olvides liberar recursos
pasoService.dispose();
```

### Personalizar el widget

```dart
PasoMetaWidget(
  viewModel: _viewModel!,
  progressColor: Colors.green,        // Color del anillo de progreso
  backgroundColor: Colors.white,      // Color de fondo
  stepTextStyle: TextStyle(           // Estilo del texto de pasos
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
  goalTextStyle: TextStyle(           // Estilo del texto de la meta
    fontSize: 18,
    color: Colors.grey,
  ),
)
```

## Referencia de API

### PasoService

Un servicio que provee un stream del conteo diario de pasos.

**Métodos:**

* `Stream<int> get stepsStream` – Stream de pasos diarios (se reinicia a medianoche)
* `void dispose()` – Libera recursos

**Características:**

* Maneja automáticamente el reinicio diario
* Guarda pasos base usando SharedPreferences
* Calcula pasos diarios a partir del contador acumulado del dispositivo

### PasoMetaViewModel

Un ChangeNotifier que gestiona la meta y el progreso de pasos.

**Propiedades:**

* `int pasos` – Conteo actual de pasos
* `int metaDiaria` – Meta diaria de pasos
* `double progressPercent` – Porcentaje de progreso (0.0 a 1.0)
* `bool isExpanded` – Si el widget está en vista expandida

**Métodos:**

* `void toggleExpanded()` – Alterna entre vistas compacta y expandida
* `void setDailyGoal(int goal)` – Configura una nueva meta diaria
* `void dispose()` – Libera recursos

### PasoMetaWidget

Widget que muestra el conteo de pasos y el progreso hacia la meta diaria.

**Parámetros:**

* `viewModel` (requerido) – Instancia de `PasoMetaViewModel`
* `progressColor` – Color del indicador de progreso
* `backgroundColor` – Color de fondo
* `stepTextStyle` – Estilo del texto de pasos
* `goalTextStyle` – Estilo del texto de la meta

**Características:**

* Toca para alternar entre vista compacta y expandida
* Indicador circular de progreso
* Optimizado para pantallas Wear OS

## Cómo funciona

1. **Conteo de pasos**: Usa el sensor podómetro del dispositivo mediante el plugin `pedometer`.
2. **Cálculo diario**: Guarda un valor base y calcula los pasos diarios como la diferencia con el valor actual.
3. **Reinicio automático**: Verifica si es un nuevo día y resetea el valor base.
4. **Persistencia**: Guarda el valor base y la fecha de reinicio en SharedPreferences para mantener la precisión.

## Permisos

Este paquete requiere el permiso de reconocimiento de actividad para acceder al conteo de pasos. La app de ejemplo muestra cómo solicitarlo usando `permission_handler`.

## App de ejemplo

Consulta el directorio `/example` para ver un ejemplo completamente funcional, incluido el manejo de permisos.

## Contribuir

¡Contribuciones son bienvenidas! Puedes enviar un Pull Request cuando lo desees.

## Licencia

Consulta el archivo LICENSE para más detalles.

## Información adicional

Para más información sobre este paquete, visita el repositorio en GitHub.


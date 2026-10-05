import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/dependencies.dart';

export 'app.dart' show MiApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // App pensada para teléfono: solo vertical.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Datos de prueba en memoria. Para usar una base de datos real, cambia esta
  // línea por otra implementación de AppDependencies.
  runApp(MiApp(dependencies: AppDependencies.mock()));
}

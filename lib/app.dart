import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/app_scope.dart';
import 'core/dependencies.dart';
import 'core/sesion_controller.dart';
import 'screens/home_shell.dart';
import 'screens/login_page.dart';

class MiApp extends StatefulWidget {
  const MiApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<MiApp> createState() => _MiAppState();
}

class _MiAppState extends State<MiApp> {
  late final _sesion = SesionController(widget.dependencies)..restaurarSesion();

  @override
  void dispose() {
    _sesion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: widget.dependencies,
      sesion: _sesion,
      child: MaterialApp(
        title: 'Mi Primera App',
        debugShowCheckedModeBanner: false,
        theme: _tema(),
        builder: (context, child) => _MarcoMovil(child: child!),
        home: const _Puerta(),
      ),
    );
  }
}

/// Muestra el login o la app según haya sesión, con un fundido entre ambas.
class _Puerta extends StatelessWidget {
  const _Puerta();

  @override
  Widget build(BuildContext context) {
    final sesion = AppScope.of(context).sesion;
    final Widget pantalla;
    if (sesion.restaurando) {
      pantalla = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (sesion.autenticado) {
      pantalla = HomeShell(key: ValueKey(sesion.usuario!.id));
    } else {
      pantalla = const LoginPage();
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: pantalla,
    );
  }
}

/// Ajustes para pantallas de teléfono:
/// - limita el tamaño de letra del sistema para que no rompa el diseño;
/// - en el navegador centra la app con el ancho de un teléfono, así la prueba
///   web se ve igual que en Android. En el teléfono no cambia nada.
class _MarcoMovil extends StatelessWidget {
  const _MarcoMovil({required this.child});

  final Widget child;

  static const anchoTelefono = 430.0;

  @override
  Widget build(BuildContext context) {
    final app = MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: child,
    );
    if (!kIsWeb) return app;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: anchoTelefono),
          child: ClipRect(child: app),
        ),
      ),
    );
  }
}

ThemeData _tema() {
  final colores = ColorScheme.fromSeed(seedColor: Colors.indigo);
  final bordes = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  // 52dp de alto: cómodo de tocar en Android (el mínimo recomendado es 48dp).
  const tamanoBoton = Size(64, 52);
  const textoBoton = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

  return ThemeData(
    colorScheme: colores,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colores.surfaceContainerHighest.withValues(alpha: 0.4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: tamanoBoton,
        shape: bordes,
        textStyle: textoBoton,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: tamanoBoton,
        shape: bordes,
        textStyle: textoBoton,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colores.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

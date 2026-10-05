import 'package:flutter/widgets.dart';

import 'dependencies.dart';
import 'sesion_controller.dart';

/// Pone la sesión y los repositorios al alcance de cualquier widget.
/// Los widgets que usan `AppScope.of(context)` se reconstruyen cuando la
/// sesión cambia (login, logout, perfil o foto actualizados).
class AppScope extends InheritedNotifier<SesionController> {
  const AppScope({
    super.key,
    required this.dependencies,
    required SesionController sesion,
    required super.child,
  }) : super(notifier: sesion);

  final AppDependencies dependencies;

  SesionController get sesion => notifier!;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No hay un AppScope encima de este widget');
    return scope!;
  }

  /// Igual que [of] pero sin suscribirse a cambios; útil dentro de callbacks.
  static AppScope read(BuildContext context) {
    return context.getInheritedWidgetOfExactType<AppScope>()!;
  }
}

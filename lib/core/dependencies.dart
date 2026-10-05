import '../data/mock/memoria_database.dart';
import '../data/mock/mock_repositories.dart';
import '../data/repositories/repositories.dart';

/// Punto único donde se eligen las implementaciones de datos.
///
/// Para conectar una base de datos real, crea por ejemplo
/// `AppDependencies.api(...)` con tus repositorios y úsalo en `main.dart`.
class AppDependencies {
  const AppDependencies({
    required this.auth,
    required this.usuarios,
    required this.cursos,
    required this.archivos,
  });

  /// Datos hardcodeados en memoria. [latencia] simula la red.
  factory AppDependencies.mock({
    Duration latencia = const Duration(milliseconds: 600),
  }) {
    final db = MemoriaDatabase(latencia: latencia);
    return AppDependencies(
      auth: MockAuthRepository(db),
      usuarios: MockUsuarioRepository(db),
      cursos: MockCursoRepository(db),
      archivos: MockArchivoRepository(db),
    );
  }

  final AuthRepository auth;
  final UsuarioRepository usuarios;
  final CursoRepository cursos;
  final ArchivoRepository archivos;
}

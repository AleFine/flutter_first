/// Base de datos en memoria con datos de prueba hardcodeados.
///
/// Guarda cada registro como `Map<String, dynamic>` (igual que una fila o un
/// documento), así los repositorios mock ejercitan `toMap`/`fromMap` como lo
/// haría uno real. Los datos se pierden al cerrar o reiniciar la app.
class MemoriaDatabase {
  MemoriaDatabase({this.latencia = const Duration(milliseconds: 600)});

  /// Retardo artificial para simular la red y ver los estados de carga.
  final Duration latencia;

  Future<void> simularRed() =>
      latencia == Duration.zero ? Future.value() : Future.delayed(latencia);

  /// Sesión abierta (id de usuario) o `null`.
  String? sesionUsuarioId;

  /// email -> contraseña. En producción esto lo maneja el servicio de auth.
  final Map<String, String> credenciales = {
    'alumno@unt.edu.pe': '123456',
    'docente@unt.edu.pe': '123456',
  };

  /// email -> id de usuario.
  final Map<String, String> usuarioIdPorEmail = {
    'alumno@unt.edu.pe': 'u1',
    'docente@unt.edu.pe': 'u2',
  };

  final Map<String, Map<String, dynamic>> usuarios = {
    'u1': {
      'id': 'u1',
      'nombre': 'Kevin Paredes',
      'email': 'alumno@unt.edu.pe',
      'codigo': '1023456789',
      'carrera': 'Ingeniería de Sistemas',
      'telefono': '987 654 321',
      'foto_url': null,
    },
    'u2': {
      'id': 'u2',
      'nombre': 'Ana Torres',
      'email': 'docente@unt.edu.pe',
      'codigo': 'D-0042',
      'carrera': 'Docente · Aplicaciones Móviles',
      'telefono': null,
      'foto_url': null,
    },
  };

  /// id de usuario -> cursos matriculados.
  final Map<String, List<Map<String, dynamic>>> cursosPorUsuario = {
    'u1': [
      {
        'id': 'c1',
        'nombre': 'Aplicaciones Móviles',
        'docente': 'Ana Torres',
        'nota_el': 16,
        'nota_et': 14,
        'nota_pt': 17,
      },
      {
        'id': 'c2',
        'nombre': 'Base de Datos II',
        'docente': 'Luis Mendoza',
        'nota_el': 13,
        'nota_et': 11,
        'nota_pt': 15,
      },
      {
        'id': 'c3',
        'nombre': 'Ingeniería de Software',
        'docente': 'Rosa Salinas',
        'nota_el': 9,
        'nota_et': 10,
        'nota_pt': 8,
      },
      {
        'id': 'c4',
        'nombre': 'Redes y Comunicaciones',
        'docente': 'Jorge Vega',
        'nota_el': 18,
        'nota_et': 17,
        'nota_pt': 19,
      },
    ],
    'u2': [],
  };
}

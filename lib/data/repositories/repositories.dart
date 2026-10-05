// Contratos de acceso a datos. Las pantallas y el SesionController solo
// conocen estas interfaces: para pasar a una base de datos real (Firebase,
// Supabase, una API REST...) se escribe otra implementación de cada una y se
// cambia en `lib/core/dependencies.dart`, sin tocar la UI.

import 'dart:typed_data';

import '../models/curso.dart';
import '../models/usuario.dart';

/// Error con un mensaje listo para mostrar al usuario.
class DataException implements Exception {
  const DataException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

abstract interface class AuthRepository {
  /// Devuelve el id del usuario autenticado o lanza [DataException].
  Future<String> iniciarSesion({required String email, required String password});

  Future<void> cerrarSesion();

  /// Id del usuario con sesión abierta, o `null` si no hay sesión.
  Future<String?> usuarioActualId();
}

abstract interface class UsuarioRepository {
  Future<Usuario> obtener(String id);

  Future<Usuario> actualizar(Usuario usuario);
}

abstract interface class CursoRepository {
  Future<List<Curso>> listarPorUsuario(String usuarioId);
}

abstract interface class ArchivoRepository {
  /// Sube la foto de perfil y devuelve la URL con la que se puede mostrar.
  Future<String> subirFotoPerfil({
    required String usuarioId,
    required Uint8List bytes,
    required String mimeType,
  });

  Future<void> eliminarFotoPerfil(String usuarioId);
}

import 'dart:convert';
import 'dart:typed_data';

import '../models/curso.dart';
import '../models/usuario.dart';
import '../repositories/repositories.dart';
import 'memoria_database.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._db);

  final MemoriaDatabase _db;

  @override
  Future<String> iniciarSesion({
    required String email,
    required String password,
  }) async {
    await _db.simularRed();
    final clave = email.trim().toLowerCase();
    if (_db.credenciales[clave] != password) {
      throw const DataException('Correo o contraseña incorrectos');
    }
    return _db.sesionUsuarioId = _db.usuarioIdPorEmail[clave]!;
  }

  @override
  Future<void> cerrarSesion() async {
    _db.sesionUsuarioId = null;
  }

  @override
  Future<String?> usuarioActualId() async => _db.sesionUsuarioId;
}

class MockUsuarioRepository implements UsuarioRepository {
  MockUsuarioRepository(this._db);

  final MemoriaDatabase _db;

  @override
  Future<Usuario> obtener(String id) async {
    await _db.simularRed();
    final fila = _db.usuarios[id];
    if (fila == null) throw const DataException('Usuario no encontrado');
    return Usuario.fromMap(fila);
  }

  @override
  Future<Usuario> actualizar(Usuario usuario) async {
    await _db.simularRed();
    _db.usuarios[usuario.id] = usuario.toMap();
    return usuario;
  }
}

class MockCursoRepository implements CursoRepository {
  MockCursoRepository(this._db);

  final MemoriaDatabase _db;

  @override
  Future<List<Curso>> listarPorUsuario(String usuarioId) async {
    await _db.simularRed();
    final filas = _db.cursosPorUsuario[usuarioId] ?? const [];
    return filas.map(Curso.fromMap).toList();
  }
}

/// Guarda la imagen como `data:` URI, que cabe en el mismo campo `foto_url`
/// donde un backend real guardaría la URL pública del archivo subido.
class MockArchivoRepository implements ArchivoRepository {
  MockArchivoRepository(this._db);

  final MemoriaDatabase _db;

  @override
  Future<String> subirFotoPerfil({
    required String usuarioId,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    await _db.simularRed();
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  @override
  Future<void> eliminarFotoPerfil(String usuarioId) => _db.simularRed();
}

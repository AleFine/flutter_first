import 'package:flutter/foundation.dart';

import '../data/models/usuario.dart';
import 'dependencies.dart';

/// Estado de la sesión: quién está logueado y las acciones sobre su perfil.
/// Notifica a la UI en cada cambio.
class SesionController extends ChangeNotifier {
  SesionController(this._deps);

  final AppDependencies _deps;

  Usuario? _usuario;
  bool _restaurando = true;
  bool _subiendoFoto = false;

  Usuario? get usuario => _usuario;
  bool get autenticado => _usuario != null;

  /// `true` mientras se comprueba si había una sesión abierta al iniciar.
  bool get restaurando => _restaurando;

  bool get subiendoFoto => _subiendoFoto;

  /// Recupera la sesión guardada. Con los mocks en memoria nunca hay una,
  /// pero un backend real (token, Firebase Auth...) la devolvería aquí.
  Future<void> restaurarSesion() async {
    try {
      final id = await _deps.auth.usuarioActualId();
      if (id != null) _usuario = await _deps.usuarios.obtener(id);
    } finally {
      _restaurando = false;
      notifyListeners();
    }
  }

  /// Lanza `DataException` si las credenciales no son válidas.
  Future<void> iniciarSesion(String email, String password) async {
    final id = await _deps.auth.iniciarSesion(email: email, password: password);
    _usuario = await _deps.usuarios.obtener(id);
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    await _deps.auth.cerrarSesion();
    _usuario = null;
    notifyListeners();
  }

  Future<void> actualizarPerfil({
    required String nombre,
    required String carrera,
    required String telefono,
  }) async {
    final actual = _usuario!;
    // Se construye a mano (no con copyWith) para que un campo vaciado quede
    // en null en vez de conservar el valor anterior.
    final actualizado = Usuario(
      id: actual.id,
      email: actual.email,
      codigo: actual.codigo,
      fotoUrl: actual.fotoUrl,
      nombre: nombre.trim(),
      carrera: _textoONull(carrera),
      telefono: _textoONull(telefono),
    );
    _usuario = await _deps.usuarios.actualizar(actualizado);
    notifyListeners();
  }

  static String? _textoONull(String texto) =>
      texto.trim().isEmpty ? null : texto.trim();

  Future<void> cambiarFoto(Uint8List bytes, {String mimeType = 'image/jpeg'}) {
    return _conSubidaDeFoto(() async {
      final url = await _deps.archivos.subirFotoPerfil(
        usuarioId: _usuario!.id,
        bytes: bytes,
        mimeType: mimeType,
      );
      return _usuario!.copyWith(fotoUrl: url);
    });
  }

  Future<void> quitarFoto() {
    return _conSubidaDeFoto(() async {
      await _deps.archivos.eliminarFotoPerfil(_usuario!.id);
      return _usuario!.copyWith(quitarFoto: true);
    });
  }

  Future<void> _conSubidaDeFoto(Future<Usuario> Function() accion) async {
    _subiendoFoto = true;
    notifyListeners();
    try {
      _usuario = await _deps.usuarios.actualizar(await accion());
    } finally {
      _subiendoFoto = false;
      notifyListeners();
    }
  }
}
